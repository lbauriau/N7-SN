%% Partie 1 : Ã©tude de chaines de transmissions en bande de base

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Ãtude des interfÃ©rences entre symbole et du critÃšre de Nyquist

%ParamÃštre
N = 10000; %Nombre de bits
Fe = 24000; %FrÃ©quence d'Ã©chantillonnage
Te = 1/Fe; % PÃ©riode d'Ã©chantillonnage
Rb = 3000; %DÃ©bit binaire en bits/s
Tb = 1/Rb; % DurÃ©e d'un symbole
Ns = Tb/Te; % On dÃ©termine ainsi Ns : le facteur de surÃ©chantillonnage 
Ts = Ns/Fe;
Nb = Fe/Rb;
tps =linspace(0,Ts*N,Ns*N); %temps
V = 1;

n0=8;

% Modulateur utilisÃ©

bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondÃ©rÃ©es
h1 = ones(1, Nb);
h1 = h1/norm(h1);
NRZ1 = filter(h1, 1, signal1);
z = filter(h1, 1, NRZ1);
z_ech = z(n0:Ns:end);


% TracÃ© du signal gÃ©nÃ©rÃ© avec une Ã©chelle temporelle en secondes
figure;
plot(z);
legend('RÃ©ception');
xlabel("Temps en seconde");
ylabel("Signal NRZ en 2-aire");
ylim([-1.1,1.1]);
title("TracÃ© du signal en sortie de filtre de rÃ©ception");

% RÃ©ponse impulsionnelle
figure;
g = conv(h1,h1);
plot(g);
ylabel("g");
title("RÃ©ponse impulsionnelle globale de la chaine de transmission");


% Diagramme de l'oeil
figure;
plot(reshape(z,Ns,length(z)/Ns));
title("Diagramme de l'oeil");

% Taux d'erreur binaire
bits_estimes = (sign(z_ech)+1)/2;
TEB = mean(bits1~=bits_estimes);

% pour n0=3, TEB = 0.48
% pour n0=8, TEB = 0

% Ajout d'un filtre passe bas

%Canal de propagation sans bruit
ordre =161;
echant1 = [-(ordre-1)/2 : (ordre-1)/2];

BW1 = 1000;
hc1 = (2*BW1/Fe) * sinc (2*BW1/Fe * echant1);
z_aux = filter(hc1, 1, NRZ1);
globale1 = filter(h1,1,z_aux);
figure;
plot(globale1);
legend('BW = 1000Hz')
title('RÃ©ponse impulsionnelle globale de la chaine de transmission');

% Diagramme de l'oeil
figure;

plot(reshape(globale1,Ns,length(globale1)/Ns));
title("Diagramme de l'oeil pour Bw = 1000");

% RÃ©ponse en frÃ©quence
h = conv(h1,h1); % en temporelle
H = abs(fft(h,1024)); % en frÃ©quentielle
H = H/max(H);
freqH = linspace(-BW1/2, BW1/2, length(H));
Hc1 = abs(fft(hc1,1024)); % en frÃ©quentielle
Hc1 = Hc1/max(Hc1);
freqC = linspace(-BW1/2, BW1/2, length(Hc1));
Hfinal = Hc1.*H;
freqTot = linspace(-BW1/2, BW1/2, length(Hfinal));

figure;
hold ON;
semilogy(freqH, fftshift(H)); % H(f)*Hr(f)
semilogy(freqC, fftshift(Hc1)); % Hc(f)
semilogy(freqTot, fftshift(Hfinal),'g'); % H(f)*Hr(f)*Hc(f)
legend('H(f)Hr(f)', 'Hc(f)','H(f)Hr(f)Hc(f)');
title ('ReprÃ©sentation frÃ©quentielle pour BW=1000 Hz');

% Taux d'erreur binaire
z_ech1 = globale1(n0:Ns:end);
bits_estimes1 = (sign(z_ech1)+1)/2;
retard= (ordre-1)/(2*Nb);
TEB1000 = mean(bits1(1:end-retard)~=bits_estimes1(retard+1:end)); 
% TEB1000 = 0.09;

% Pour 8 000 Hz
BW2 = 8000;
hc2 = (2*BW2/Fe) * sinc (2*BW2/Fe * echant1);
z_aux2 = filter(hc2, 1, NRZ1);
globale2 = filter(h1,1,z_aux2);
figure;
plot(globale2);
legend('BW = 8000Hz')
title('RÃ©ponse impulsionnelle globale de la chaine de transmission');

% Diagramme de l'oeil
figure;

plot(reshape(globale2,Ns,length(globale2)/Ns)); 
title("Diagramme de l'oeil pour Bw = 8000 Hz");


% RÃ©ponse en frÃ©quence
h = conv(h1,h1); % en temporelle
H = abs(fft(h,1024)); % en frÃ©quentielle
H = H/max(H);
freqH = linspace(-BW2/2, BW2/2, length(H));
Hc2 = abs(fft(hc2,1024)); % en frÃ©quentielle
Hc2 = Hc2/max(Hc2);
freqC = linspace(-BW2/2, BW2/2, length(Hc2));
Hfinal2 = Hc2.*H;
freqTot = linspace(-BW2/2, BW2/2, length(Hfinal2));

figure;
hold ON;
semilogy(freqH, fftshift(H)); % H(f)*Hr(f)
semilogy(freqC, fftshift(Hc2)); % Hc(f)
semilogy(freqTot, fftshift(Hfinal2),'g'); % H(f)*Hr(f)*Hc(f)
legend('H(f)Hr(f)', 'Hc(f)','H(f)Hr(f)Hc(f)');
title ('ReprÃ©sentation frÃ©quentielle pour BW=8000 Hz');

% Taux d'erreur binaire
z_ech2 = globale2(n0:Ns:end);
bits_estimes2 = (sign(z_ech2)+1)/2;
TEB8000 = mean(bits1(1:end-retard)~=bits_estimes2(retard+1:end));
% TEB8000 = 0;

