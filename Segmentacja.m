%WYN = zeros(210, 4);
%%
close all;

nr = 14; %numer obrazu w bazie 
Img = imread("malignant ("+num2str(nr)+").png"); 
%wczytanie obrazu do pamiêci
%figure('Name','wejœcie');
subplot(2,3,1), imshow(Img), title('Obraz wejœciowy'); hold on;
Obrys = imread("malignant ("+num2str(nr)+")_mask.png");
%wczytanie obrysu eksperckiego do pamiêci

SE = [0 1 0
   1 1 1
   0 1 0];


 I2 = Img;  
 I2 = medfilt2(rgb2gray(I2), [9 9]);
 %przetworzenie obrazu z przestrzeni rgb do odcieni szaroœci
 %nastêpnie przepwrowadzenie filtracji medianowej w celu 
 %usuniêcia szumów z obrazu USG
 

I2 = 255-I2; %stworzenie negatywu obrazu
% w celu poprawy widocznoœci ubszaru guza dla ludzkiego oka
%figure;
subplot(2,3,2), imshow(I2),  title('Odrêczny obrys');
rect = drawfreehand('FaceSelectable',false);
%zaznaczenie rêcznie na obrazie obszaru na którym znajduje siê guz
mask = createMask(rect); 
%stworzenie maski na podstawie zaznaczonego obszaru
%figure
subplot(2,3,3), imshow(mask)
title('niebieski: ekspercki, nasz: czerwony');
hold on;
bw = activecontour(I2,mask,200,'edge', 'ContractionBias', 1); 
%segmentacja zmiany z obszaru za pomoc¹ metody aktwnego konturu 
% z warunkiem kurczenia siê obszaru pocz¹wszy od narysowanego rêcznie
% obrysu. Maksymalna przyjêta iloœæ iteracji = 200
visboundaries(bw,'Color','r'); 
visboundaries(Obrys,'Color','b');
%uwidocznienie konturów wysegmentowanego obszaru
% oraz obrysu eksperckiego
hold off;
%figure('Name','overlay')
subplot(2,3,4), imshow(labeloverlay(I2,bw))
title('Obszar na obrazie'); 
%pokazanie na jednym rysunku obu obrysów
bw = imopen(bw, SE);
bw = imclose(bw, SE);
% przeprowadzenie operacji zamkniêcia i otwarcia 
% w celu wyg³adzenia przegów maski
 Imga = imdilate(bw, SE); 
 Imgb = imerode(bw, SE); 
 ImgK = Imga - Imgb; 
 subplot(2,3,6), imshow(ImgK),  title('Uzyskany kontur');
 subplot(2,3,5), imshow(bw), title('Uzyskana maska');
 hold off;
 % operacje dylacji,erozji oraz ich ró¿nica
 % która tworzy kontór maski

  Obrysa = imdilate(Obrys, SE); 
  % te same operacje przeprowadzone 
  % na obrysie eksperckim
 Obrysb = imerode(Obrys, SE); 
 ImgKobr = Obrysa - Obrysb;

similarityJacc = jaccard(Obrys,bw)
%wyznaczanie podobieñstwa metod¹ Jaccarda
%obrysu eksperckiego oraz wysegmentowanej w programie zmiany
similarityDice = dice(Obrys,bw)  
%wyznaczanie podobieñstwa metod¹ Dice
%obrysu eksperckiego oraz wysegmentowanej w programie zmiany

figure;
[n,r] = boxcount(ImgKobr,'slope');
%przeprowadzenie algorytmu wyznaczania
% wymiaru pude³kowego obrysu eksperckiego
df = -diff(log(n))./diff(log(r)); %obliczenie wartoœci
% wymiaru pude³kowego dla poszczególnych rozmiarów pude³ek 

dfObr = mean(df(4:8))%obliczenie œredniej
% wartoœci wymiaru pude³kowego w zakresie
% wystêpowania jego minimum

figure;
[n,r] = boxcount(ImgK,'slope');
%przeprowadzenie algorytmu wyznaczania
%wymiaru pude³kowego obrysu uzyskanego programowo

df = -diff(log(n))./diff(log(r));  %obliczenie wartoœci
% wymiaru pude³kowego dla poszczególnych rozmiarów pude³ek 
dfNasz = mean(df(4:8))%obliczenie œredniej
%wartoœci wymiaru pude³kowego w zakresie 
%wystêpowania jego minimum

  %%
  % imwrite(bw, "mal_"+num2str(nr)+".png")
  % disp("zapisano: "+num2str(nr))
   