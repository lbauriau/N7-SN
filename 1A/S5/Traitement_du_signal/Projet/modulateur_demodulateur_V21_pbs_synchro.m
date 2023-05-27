%% Modulateur et d�modulateur V21 avec un probleme de synchronisation sur la phase porteuse

clear all;
close all;
N = 100 ; %nombre de bits généré

delta_f = 100;
fc = 1080;
f0 = fc + delta_f;
f1 = fc - delta_f;
phi0 = rand*2*pi;
phi1 = rand*2*pi;

Fe = 48000; %fréquence d'échantillonnage, 300 bits par seconde
Te = 1/Fe;
Ts = 1/300; %Durée d'un morceau de cosinus

Ns=Ts*Fe;
tps =(0:Te:(N*Ns-1)*Te); %temps

bruit=50; %Bruit en Db

%% Ajout du bruit blanc Gaussien

x_bits=randi([0 1],1,N);
NRZ = kron(x_bits, ones(1,Ns));
num0 = cos(2*pi*f0*tps+phi0);
num1 = cos(2*pi*f1*tps+phi1);
x = [(1-NRZ).*num0] + [NRZ.*num1];
Px = mean(abs(x).^2);
Pb= Px/10^(bruit/10);
sigma = sqrt(Pb); %sigma ^ 2 est la puissance du bruit gaussien
gaussien = sigma*randn(1,length(x));
x_gaus = gaussien + [(1-NRZ).*num0] + [NRZ.*num1];
DSP_gaus=pwelch(x_gaus,[],[],[],Fe,'twosided');

%% Démodulateur avec des intégrales

%Choix du signal à démoduler
x_demod = x_gaus;

%Déphasage entre les phases de début et de fin
phi0 = rand*2*pi;
phi1 = rand*2*pi;

num0 = cos(2*pi*f0*tps+phi0);
num1 = cos(2*pi*f1*tps+phi1);

x1_V21 = x_demod.*num1;
x0_V21 = x_demod.*num0;

num0_c = cos(2*pi*f0*tps+phi0);
num0_s = sin(2*pi*f0*tps+phi0);
num1_c = cos(2*pi*f1*tps+phi1);
num1_s = sin(2*pi*f1*tps+phi1);

x0_V21_c = x_demod.*num0_c;
x0_V21_s = x_demod.*num0_s;
x1_V21_c = x_demod.*num1_c;
x1_V21_s = x_demod.*num1_s;

x0_V21_int_c = reshape (x0_V21_c,Ns,length(x0_V21_c)/Ns);
x0_V21_int_c = (sum(x0_V21_int_c,1)/Ns).^2;
x0_V21_int_s = reshape (x0_V21_s,Ns,length(x0_V21_s)/Ns);
x0_V21_int_s = (sum(x0_V21_int_s,1)/Ns).^2;
x0_V21_int = x0_V21_int_s+x0_V21_int_c;

x1_V21_int_c = reshape (x1_V21_c,Ns,length(x1_V21_c)/Ns);
x1_V21_int_c = (sum(x1_V21_int_c,1)/Ns).^2;
x1_V21_int_s = reshape (x1_V21_s,Ns,length(x1_V21_s)/Ns);
x1_V21_int_s = (sum(x1_V21_int_s,1)/Ns).^2;
x1_V21_int = x1_V21_int_s+x1_V21_int_c;

x_V21 = x1_V21_int-x0_V21_int;
y_V21 = x_V21>0;
taux_V21 = sum(abs(x_bits-y_V21),2)/length(x_bits);