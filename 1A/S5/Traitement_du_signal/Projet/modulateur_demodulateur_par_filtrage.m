%% Modulateur et d�modulateur par filtrage

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

%% Génération du signal NRZ
x_bits=randi([0 1],1,N);
NRZ = kron(x_bits, ones(1,Ns));
DSP=pwelch(NRZ,[],[],[],Fe,'twosided');
freq=linspace(0,Fe,length(DSP));
freq2=linspace(0,Fe/2,length(DSP));
DSP_th = [(1/4)*(Ts*(sinc(freq2*Ts).^ 2))]';
DSP_th(1)=DSP_th(1)+1/4;



%% Génération du signal modulé en fréquence
num0 = cos(2*pi*f0*tps+phi0);
num1 = cos(2*pi*f1*tps+phi1);
x = [(1-NRZ).*num0] + [NRZ.*num1];
DSP_x=pwelch(x,[],[],[],Fe,'twosided');
freq_x=linspace(0,Fe,length(DSP_x));
DSP_th_1 = [(1/4)*(Ts*(sinc((freq2-f0)*Ts).^ 2))]';
DSP_th_1(1)=DSP_th(1)+1/4;
DSP_th_2 = [(1/4)*(Ts*(sinc((freq2+f0)*Ts).^ 2))]';
DSP_th_2(1)=DSP_th(1)+1/4;
DSP_th_3 = [(1/4)*(Ts*(sinc((freq2-f1)*Ts).^ 2))]';
DSP_th_3(1)=DSP_th(1)+1/4;
DSP_th_4 = [(1/4)*(Ts*(sinc((freq2+f1)*Ts).^ 2))]';
DSP_th_4(1)=DSP_th(1)+1/4;
DSP_x_th = (1/4)*(DSP_th_1 +DSP_th_2+DSP_th_3+DSP_th_4);


%% Canal de transmission à bruit auditif blanc et Gaussien
Px = mean(abs(x).^2);
Pb= Px/10^(bruit/10);
sigma = sqrt(Pb); %sigma ^ 2 est la puissance du bruit gaussien
gaussien = sigma*randn(1,length(x));
x_gaus = gaussien + [(1-NRZ).*num0] + [NRZ.*num1];
DSP_gaus=pwelch(x_gaus,[],[],[],Fe,'twosided');

%% Démodulation par filtrage

% Synthèse du filtre passe-bas
ordre = 61;
tps_filt =(-(ordre-1)*Te/2:Te:(ordre-1)*Te/2);
f_tilde = fc/Fe;
Hideal_bas=2*f_tilde*sinc(2*fc*tps_filt); % réponse impulsionnelle
y_bas=filter(Hideal_bas,1,x_gaus);  %sortie du filtre en temporelle
Hidel_bas_freq = fft(Hideal_bas);
freq_bas = linspace(0,Fe,length(Hidel_bas_freq));

% Synthèse du filtre passe-haut
ordre = 61;
tps_filt =(-(ordre-1)*Te/2:Te:(ordre-1)*Te/2);
Hideal_haut = -Hideal_bas;
Hideal_haut((ordre+1)/2) = Hideal_haut((ordre+1)/2) +1 ;
y_haut=filter(Hideal_haut,1,x_gaus);
Hidel_haut_freq = fft(Hideal_haut);
freq_haut = linspace(0,Fe,length(Hidel_haut_freq));

% Détection d'énergie

Y_energie = reshape (y_bas,Ns,length(x_gaus)/Ns);
Y_energie = Y_energie.^2;
Y_energie_comp = sum(Y_energie,1);
K = (min(Y_energie_comp)+max(Y_energie_comp))/2;
Y_recup = Y_energie_comp>K;
taux= sum(abs(x_bits-Y_recup),2)/length(x_bits);


%% Tracé
figure;
plot(tps,NRZ);
xlabel("Temps en seconde");
ylabel("Signal NRZ");
ylim([-0.1,1.1]);
title("Tracé de NRZ");

figure;
semilogy(freq,abs(DSP),'m');
hold on;
semilogy(freq2,abs(DSP_th),'b');
legend('Avec Welch','Théorique');
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ')

%3.1
figure;
plot(tps,x,'r');
xlabel('Temps en s');
ylabel('Signal de x');
v=axis;
v(3)=-1.5;
v(4)=1.5;
axis(v);
title('Représentation de x en seconde générée à partir de NRZ')

%3.2
figure;
semilogy(freq_x,abs(DSP_x));
hold on;
semilogy(freq2,abs(DSP_x_th),'k');
hold on;
semilogy(freq_x,abs(DSP_gaus),'m'); %avec le bruit
xlabel('Fréquence en Hz');
ylabel('Module de la DSP de x');
xlim([(-1) 10^ 4]);
title('Densité spectrale de puissance du signal modulé en fréquence')

%4
figure;
semilogy(freq_x,abs(DSP_gaus));
xlabel('Fréquence en Hz');
ylabel('Module de la DSP de x');
xlim([(-1) 10^ 4]);
title('Densité ensité spectrale de puissance du signal modulé en fréquence avec du bruit')

%close all;

%5

%Passe bas
figure;
subplot(2,1,1);
plot(tps_filt,Hideal_bas)
xlabel('Temps en s')
ylabel('Réponse impulsionnelle')
subplot(2,1,2)
plot(tps,y_bas)
xlabel('Temps en s')
ylabel('Sortie du filre ordre 61')

figure;
Y_zero=pwelch(y_bas,[],[],[],Fe,'twosided');
semilogy(freq_x,abs(Y_zero));
xlim([(-1) 10^ 4]);
xlabel('Fréquence en Hz');
ylabel('Densité spectrale');
title('Passe bas, Ordre 61');

%Passe haut
figure;
subplot(2,1,1);
plot(tps_filt,Hideal_haut)
xlabel('Temps en s')
ylabel('Réponse impulsionnelle')
subplot(2,1,2)
plot(tps,y_haut)
xlabel('Temps en s')
ylabel('Sortie du filre ordre 61')

figure;
Y_zero=pwelch(y_haut,[],[],[],Fe,'twosided');
semilogy(freq_x,abs(Y_zero));
xlim([(-1) 10^ 4]);
xlabel('Fréquence en Hz');
ylabel('Densité spectrale');
title('Passe haut, Ordre 61')

%Comparaison des passes haut et bas
figure;
subplot(2,1,1)
plot(tps,y_bas)
xlabel('Temps en s')
ylabel('Passe bas')
subplot(2,1,2)
plot(tps,y_haut)
xlabel('Temps en s')
ylabel('Passe haut')

%close all;

% 5.4 Tracés
% Passe bas
figure;
%Réponse impulsionnelle
subplot(4,1,1);
plot(tps_filt,Hideal_bas);
xlabel('Temps en s');
ylabel('Réponse impulsionnelle');
title('Passe bas')
%Réponse en fréquence
subplot(4,1,2);
semilogy(freq_bas,abs(Hidel_bas_freq),'m'); 
xlabel('Fréquence en Hz');
ylabel('Réponse en fréquence');
%Densité spectrale
subplot(4,1,3);
semilogy(freq_x,abs(DSP_gaus),'k');
hold on;
Y_zero_bas=pwelch(y_bas,[],[],[],Fe,'twosided');
semilogy(freq_x,abs(Y_zero_bas));
legend('Avant le filtre','Avec filtre passe bas')
xlabel('Fréquence en Hz');
ylabel('Module de la DSP');
xlim([(-1) 10^ 4]);
title('Densité spectrale de puissance du signal modulé en fréquence avec du bruit')
%
subplot(4,1,4);
plot(tps,y_bas);
xlabel('Temps en s')
ylabel('Sortie du filre')

% Passe haut
figure;
%Réponse impulsionnelle
subplot(4,1,1);
plot(tps_filt,Hideal_haut);
xlabel('Temps en s');
ylabel('Réponse impulsionnelle');
title('Passe haut')
%Réponse en fréquence
subplot(4,1,2);
semilogy(freq_haut,abs(Hidel_haut_freq),'m'); 
xlabel('Fréquence en Hz');
ylabel('Réponse en fréquence');
%Densité spectrale
subplot(4,1,3);
semilogy(freq_x,abs(DSP_gaus),'k');
hold on;
Y_zero_haut=pwelch(y_haut,[],[],[],Fe,'twosided');
semilogy(freq_x,abs(Y_zero_haut));
legend('Avant le filtre','Avec filtre passe haut')
xlabel('Fréquence en Hz');
ylabel('Module de la DSP');
xlim([(-1) 10^ 4]);
title('Densité spectrale de puissance du signal modulé en fréquence avec du bruit')
%
subplot(4,1,4);
plot(tps,y_haut);
xlabel('Temps en s')
ylabel('Sortie du filre')



