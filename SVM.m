% Przygotowanie wektora metek
species=zeros(416,1);
species(1:208,1)=1; %³agodne metka 1
species(209:416,1)=2; %z³oœliwe metka 2

%% Wygenerowanie cech
for i=225:420
IMG1=imread("maska_"+num2str(i)+".png");
D = sfta(IMG1, 1); %Generuje 3 cechy - wymiar fraktalny, œrednie nasycenie (który zostaje wyeliminowany
%przez metodê sequentialfs) oraz powierzchniê

tabela_cech(i,:)=D;

IMG2=imread("obraz "+num2str(i)+".png");
%IMG2=rgb2gray(IMG2);
% Logiczny and obrazu oryginalnego z mask¹
IMG2(IMG1 == 0) = 0;
t=0;
tf=IMG2>t;
Z=mean(IMG2(tf)); % œrednia intensywnoœæ obszaru maski

tabela_cech(i,2)=Z;
end

%% 
rand_num=randperm(416);
% Testowe - 270 
X_train=tabela_cech(rand_num(1:270),:);
y_train=species(rand_num(1:270),:);

% Walidacyjne - 46
X_test=tabela_cech(rand_num(271:316),:);
y_test=species(rand_num(271:316),:)

% Testowe - 100
X_test_nowy=tabela_cech(rand_num(317:416),:);
y_test_nowy=species(rand_num(317:416),:);


%% crossvalidation
c=cvpartition(y_train,'k',5)

%% Wybór cech
opts = statset('display','iter');
classf = @(train_data, train_labels, test_data, test_labels)...
    sum(predict(fitcsvm(train_data, train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);

[fs, history] = sequentialfs(classf, X_train, y_train, 'cv', c, 'options', opts,'nfeatures',2);

%% najlepsza hiperp³aszczyzna

X_train_best=X_train(:,fs);

Md1 = fitcsvm(X_train_best,y_train,'KernelFunction','rbf','OptimizeHyperparameters','auto',...
      'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
      'expected-improvement-plus','ShowPlots',true)); 
%% Test
X_test_best=X_test(:,fs);
accuracy=(sum(predict(Md1, X_test_best)==y_test)/length(y_test))*100

X_test_best_nowy=X_test_nowy(:,fs);
accuracy_nowy=(sum(predict(Md1, X_test_best_nowy)==y_test_nowy)/length(y_test_nowy))*100

tabelawynikow=zeros(125,3);
tabelawynikow(1:100,1)=rand_num(317:416); %Numer maski
tabelawynikow(1:100,2)=y_test_nowy; %Prawid³owa klasyfikacja obrazu
tabelawynikow(1:100,3)=predict(Md1, X_test_best_nowy); %Klasyfikacja SVM

