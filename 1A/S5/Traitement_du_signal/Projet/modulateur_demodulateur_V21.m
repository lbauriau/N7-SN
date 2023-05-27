%% Modulateur et d�modulateur selon la norme V21

clear all;
close all;

% D�claration des variables

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

x0_V21_int = reshape (x0_V21,Ns,length(x0_V21)/Ns);
x0_V21_int = sum(x0_V21_int,1)/Ns;

x1_V21_int = reshape (x1_V21,Ns,length(x1_V21)/Ns);
x1_V21_int = sum(x1_V21_int,1)/Ns;

x_V21 = x1_V21_int-x0_V21_int;
y_V21 = x_V21>0;
taux_V21 = sum(abs(x_bits-y_V21),2)/length(x_bits);
