%WYN = zeros(210, 4);
%%
close all;

nr = 14; %numer obrazu w bazie 
Img = imread("malignant ("+num2str(nr)+").png"); 
%wczytanie obrazu do pami�ci
%figure('Name','wej�cie');
subplot(2,3,1), imshow(Img), title('Obraz wej�ciowy'); hold on;
Obrys = imread("malignant ("+num2str(nr)+")_mask.png");
%wczytanie obrysu eksperckiego do pami�ci

SE = [0 1 0
   1 1 1
   0 1 0];


 I2 = Img;  
 I2 = medfilt2(rgb2gray(I2), [9 9]);
 %przetworzenie obrazu z przestrzeni rgb do odcieni szaro�ci
 %nast�pnie przepwrowadzenie filtracji medianowej w celu 
 %usuni�cia szum�w z obrazu USG
 

I2 = 255-I2; %stworzenie negatywu obrazu
% w celu poprawy widoczno�ci ubszaru guza dla ludzkiego oka
%figure;
subplot(2,3,2), imshow(I2),  title('Odr�czny obrys');
rect = drawfreehand('FaceSelectable',false);
%zaznaczenie r�cznie na obrazie obszaru na kt�rym znajduje si� guz
mask = createMask(rect); 
%stworzenie maski na podstawie zaznaczonego obszaru
%figure
subplot(2,3,3), imshow(mask)
title('niebieski: ekspercki, nasz: czerwony');
hold on;
bw = activecontour(I2,mask,200,'edge', 'ContractionBias', 1); 
%segmentacja zmiany z obszaru za pomoc� metody aktwnego konturu 
% z warunkiem kurczenia si� obszaru pocz�wszy od narysowanego r�cznie
% obrysu. Maksymalna przyj�ta ilo�� iteracji = 200
visboundaries(bw,'Color','r'); 
visboundaries(Obrys,'Color','b');
%uwidocznienie kontur�w wysegmentowanego obszaru
% oraz obrysu eksperckiego
hold off;
%figure('Name','overlay')
subplot(2,3,4), imshow(labeloverlay(I2,bw))
title('Obszar na obrazie'); 
%pokazanie na jednym rysunku obu obrys�w
bw = imopen(bw, SE);
bw = imclose(bw, SE);
% przeprowadzenie operacji zamkni�cia i otwarcia 
% w celu wyg�adzenia przeg�w maski
 Imga = imdilate(bw, SE); 
 Imgb = imerode(bw, SE); 
 ImgK = Imga - Imgb; 
 subplot(2,3,6), imshow(ImgK),  title('Uzyskany kontur');
 subplot(2,3,5), imshow(bw), title('Uzyskana maska');
 hold off;
 % operacje dylacji,erozji oraz ich r�nica
 % kt�ra tworzy kont�r maski

  Obrysa = imdilate(Obrys, SE); 
  % te same operacje przeprowadzone 
  % na obrysie eksperckim
 Obrysb = imerode(Obrys, SE); 
 ImgKobr = Obrysa - Obrysb;

similarityJacc = jaccard(Obrys,bw)
%wyznaczanie podobie�stwa metod� Jaccarda
%obrysu eksperckiego oraz wysegmentowanej w programie zmiany
similarityDice = dice(Obrys,bw)  
%wyznaczanie podobie�stwa metod� Dice
%obrysu eksperckiego oraz wysegmentowanej w programie zmiany

figure;
[n,r] = boxcount(ImgKobr,'slope');
%przeprowadzenie algorytmu wyznaczania
% wymiaru pude�kowego obrysu eksperckiego
df = -diff(log(n))./diff(log(r)); %obliczenie warto�ci
% wymiaru pude�kowego dla poszczeg�lnych rozmiar�w pude�ek 

dfObr = mean(df(4:8))%obliczenie �redniej
% warto�ci wymiaru pude�kowego w zakresie
% wyst�powania jego minimum

figure;
[n,r] = boxcount(ImgK,'slope');
%przeprowadzenie algorytmu wyznaczania
%wymiaru pude�kowego obrysu uzyskanego programowo

df = -diff(log(n))./diff(log(r));  %obliczenie warto�ci
% wymiaru pude�kowego dla poszczeg�lnych rozmiar�w pude�ek 
dfNasz = mean(df(4:8))%obliczenie �redniej
%warto�ci wymiaru pude�kowego w zakresie 
%wyst�powania jego minimum

  %%
  % imwrite(bw, "mal_"+num2str(nr)+".png")
  % disp("zapisano: "+num2str(nr))
   