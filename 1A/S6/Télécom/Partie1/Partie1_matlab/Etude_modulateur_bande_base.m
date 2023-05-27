%% Partie 1 : Ã©tude de chaines de transmissions en bande de base

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Ãtude de modulateurs en bande de base

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

% Modulateur 1
bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondÃ©rÃ©es
h1 = ones(1, Nb);
NRZ1 = filter(h1, 1, signal1); %application du filtre de mise en forme

DSP1=pwelch(NRZ1,[],[],[],Fe,'twosided');
freq1=linspace(-Fe/2,Fe/2,length(DSP1));
DSP1_th = V*V*[(1/4)*(Ts*(sinc(freq1*Ts).^ 2))]';

% TracÃ© du signal gÃ©nÃ©rÃ© avec une Ã©chelle temporelle en secondes
figure;
plot(tps,NRZ1);
xlabel("Temps en seconde");
ylabel("Signal NRZ en 2-aire");
ylim([-1.1,1.1]);
title("TracÃ© de NRZ (mod1)");

% TracÃ© de la DSP du signal gÃ©nÃ©rÃ© avec une Ã©chelle frÃ©quentielle en Hz
% pour mod 1
figure;
f1 = linspace(-Fe/2,Fe/2,length(DSP1));
plot(f1,fftshift(DSP1/max(DSP1)));
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 2 aire (mod1)')


% TracÃ© supreposÃ© de la DSP estimÃ©e et thÃ©orique
figure;
plot(f1,fftshift(DSP1/max(DSP1)));
hold ON;
plot(f1,DSP1_th/max(DSP1_th));
legend('Avec Welch','ThÃ©orique');
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 2-aire (mod1)')


% Modulateur 2
bits2 = randi([0 1],1,N);
symb2 = bi2de(reshape(bits2,2,N/2).').';
symb2 = 3*V*(symb2==3) + 1*V*(symb2==2) + (-1)*V*(symb2==0) + (-3)*V*(symb2==1);
dirac2 = [1 zeros(1,2*Nb - 1)];
signal2 = kron(symb2,dirac2);

h2 = ones(1, 2*Nb);
NRZ2 = filter(h2, 1, signal2);

DSP2 = pwelch(NRZ2,[],[],[],Fe,'twosided');
freq2=linspace(-Fe/2,Fe/2,length(DSP2));
DSP2_th = 5*V*V*(1/Ts)*(2*Ts*(sinc(freq2*2*Ts).^ 2));

% TracÃ© du signal gÃ©nÃ©rÃ© avec une Ã©chelle temporelle en secondes
figure;
tps2 = linspace(0,Ts*N,length(NRZ2));
plot(tps2,NRZ2);
xlabel("Temps en seconde");
ylabel("Signal NRZ en 4-aires");
title("TracÃ© de NRZ (mod2)");

% TracÃ© de la DSP du signal gÃ©nÃ©rÃ© avec une Ã©chelle frÃ©quentielle en Hz
% pour mod 2
figure;
f2 = linspace(-Fe/2,Fe/2,length(DSP2));
plot(f2,fftshift(DSP2/max(DSP2)));
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 4 aires (mod2)')


% TracÃ© supreposÃ© de la DSP estimÃ©e et thÃ©orique
figure;
plot(f2,fftshift(DSP2/max(DSP2)));
hold ON;
plot(f2,DSP2_th/max(DSP2_th));
legend('Avec Welch','ThÃ©orique');
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 4-aire (mod2)')

close all;

% Modulateur 3

SPAN = 10;
alpha = 0.25;
bits3 = randi([0 1],1,N);
symb3 = 2*bits3 - 1;
dirac3 = [1 zeros(1,Nb-1)];
signal3 = kron(symb3,dirac3); %somme des diracs pondÃ©rÃ©es
h3 = rcosdesign (alpha,SPAN, Nb);
x3 = filter(h3, 1, signal3);

DSP3 = pwelch(x3,[],[],[],Fe,'twosided');
freq3=linspace(-Fe/2,Fe/2,length(DSP3));
DSP3_th= zeros(1, length(freq3));
DSP3_th(abs(freq3) <= (1-alpha)/(2*Ts)) = 1;
condition = (abs(freq3) <= (1+alpha)/(2*Ts) & abs(freq3) >= (1-alpha)/(2*Ts));
DSP3_th(condition) = 1/2 * (1+cos(pi*Ts/alpha*(abs(freq3(condition)) - (1-alpha)/(2*Ts))));


% TracÃ© du signal gÃ©nÃ©rÃ© avec une Ã©chelle temporelle en secondes
figure;
plot(x3);
xlabel("Temps en seconde");
ylabel("Signal NRZ");
title("TracÃ© de NRZ (mod3)");

% TracÃ© de la DSP du signal gÃ©nÃ©rÃ© avec une Ã©chelle frÃ©quentielle en Hz
% pour mod 3
figure;
plot(freq3,fftshift(DSP3/max(DSP3)));
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 2 aires (mod3)')


% TracÃ© supreposÃ© de la DSP estimÃ©e et thÃ©orique
figure;
plot(freq3,fftshift(DSP3/max(DSP3)));
hold ON;
plot(freq3,DSP3_th/max(DSP3_th));
legend('Avec Welch','ThÃ©orique');
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('DensitÃ© spectrale de puissance de NRZ en 2-aire (mod3)')

% Superposition des 3 DSP
figure;
plot(f1,fftshift(DSP1/max(DSP1)));
hold ON;
plot(f2,fftshift(DSP2/max(DSP2)));
hold ON;
plot(freq3,fftshift(DSP3/max(DSP3)));
legend('Modulateur 1', 'Modulateur 2', 'Modulateur 3');
xlabel('FrÃ©quence en Hz');
ylabel("Module de la DSP de NRZ");
title('Comparaison des 3 DSP');

