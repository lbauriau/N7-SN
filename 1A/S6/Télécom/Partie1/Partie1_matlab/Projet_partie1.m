%% Partie 1 : étude de chaines de transmissions en bande de base

% Étudiant : JEANVOINE Achille
% Étudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Étude de modulateurs en bande de base

%Paramètre
N = 10000; %Nombre de bits
Fe = 24000; %Fréquence d'échantillonnage
Te = 1/Fe; % Période d'échantillonnage
Rb = 3000; %Débit binaire en bits/s
Tb = 1/Rb; % Durée d'un symbole
Ns = Tb/Te; % On détermine ainsi Ns : le facteur de suréchantillonnage 
Ts = Ns/Fe;
Nb = Fe/Rb;
tps =linspace(0,Ts*N,Ns*N); %temps
V = 1;

% Modulateur 1
bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondérées
h1 = ones(1, Nb);
NRZ1 = filter(h1, 1, signal1); %application du filtre de mise en forme

DSP1=pwelch(NRZ1,[],[],[],Fe,'twosided');
freq1=linspace(-Fe/2,Fe/2,length(DSP1));
DSP1_th = V*V*[(1/4)*(Ts*(sinc(freq1*Ts).^ 2))]';

% Tracé du signal généré avec une échelle temporelle en secondes
figure;
plot(tps,NRZ1);
xlabel("Temps en seconde");
ylabel("Signal NRZ en 2-aire");
ylim([-1.1,1.1]);
title("Tracé de NRZ (mod1)");

% Tracé de la DSP du signal généré avec une échelle fréquentielle en Hz
% pour mod 1
figure;
f1 = linspace(-Fe/2,Fe/2,length(DSP1));
plot(f1,fftshift(DSP1/max(DSP1)));
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 2 aire (mod1)')


% Tracé supreposé de la DSP estimée et théorique
figure;
plot(f1,fftshift(DSP1/max(DSP1)));
hold ON;
plot(f1,DSP1_th/max(DSP1_th));
legend('Avec Welch','Théorique');
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 2-aire (mod1)')


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

% Tracé du signal généré avec une échelle temporelle en secondes
figure;
tps2 = linspace(0,Ts*N,length(NRZ2));
plot(tps2,NRZ2);
xlabel("Temps en seconde");
ylabel("Signal NRZ en 4-aires");
title("Tracé de NRZ (mod2)");

% Tracé de la DSP du signal généré avec une échelle fréquentielle en Hz
% pour mod 2
figure;
f2 = linspace(-Fe/2,Fe/2,length(DSP2));
plot(f2,fftshift(DSP2/max(DSP2)));
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 4 aires (mod2)')


% Tracé supreposé de la DSP estimée et théorique
figure;
plot(f2,fftshift(DSP2/max(DSP2)));
hold ON;
plot(f2,DSP2_th/max(DSP2_th));
legend('Avec Welch','Théorique');
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 4-aire (mod2)')

close all;

% Modulateur 3

SPAN = 10;
alpha = 0.25;
bits3 = randi([0 1],1,N);
symb3 = 2*bits3 - 1;
dirac3 = [1 zeros(1,Nb-1)];
signal3 = kron(symb3,dirac3); %somme des diracs pondérées
h3 = rcosdesign (alpha,SPAN, Nb);
x3 = filter(h3, 1, signal3);

DSP3 = pwelch(x3,[],[],[],Fe,'twosided');
freq3=linspace(-Fe/2,Fe/2,length(DSP3));
DSP3_th= zeros(1, length(freq3));
DSP3_th(abs(freq3) <= (1-alpha)/(2*Ts)) = 1;
condition = (abs(freq3) <= (1+alpha)/(2*Ts) & abs(freq3) >= (1-alpha)/(2*Ts));
DSP3_th(condition) = 1/2 * (1+cos(pi*Ts/alpha*(abs(freq3(condition)) - (1-alpha)/(2*Ts))));


% Tracé du signal généré avec une échelle temporelle en secondes
figure;
plot(x3);
xlabel("Temps en seconde");
ylabel("Signal NRZ");
title("Tracé de NRZ (mod3)");

% Tracé de la DSP du signal généré avec une échelle fréquentielle en Hz
% pour mod 3
figure;
plot(freq3,fftshift(DSP3/max(DSP3)));
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 2 aires (mod3)')


% Tracé supreposé de la DSP estimée et théorique
figure;
plot(freq3,fftshift(DSP3/max(DSP3)));
hold ON;
plot(freq3,DSP3_th/max(DSP3_th));
legend('Avec Welch','Théorique');
xlabel('Fréquence en Hz');
ylabel("Module de la DSP de NRZ");
title('Densité spectrale de puissance de NRZ en 2-aire (mod3)')

close all;

%% Étude des interférences entre symbole et du critère de Nyquist

Fe = 24000;
Rb = 3000;
Tb = 1/Rb;
n0=8;

% Modulateur utilisé

bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondérées
h1 = ones(1, Nb);
h1 = h1/norm(h1);
NRZ1 = filter(h1, 1, signal1);
z = filter(h1, 1, NRZ1);
z_ech = z(n0:Ns:end);


% Tracé du signal généré avec une échelle temporelle en secondes
figure;
plot(z);
legend('Réception');
xlabel("Temps en seconde");
ylabel("Signal NRZ en 2-aire");
ylim([-1.1,1.1]);
title("Tracé du signal en sortie de filtre de réception");

% Réponse impulsionnelle
figure;
g = conv(h1,h1);
plot(g);
ylabel("g");
title("Réponse impulsionnelle globale de la chaine de transmission");


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
title('Réponse impulsionnelle globale de la chaine de transmission');

% Diagramme de l'oeil
figure;

plot(reshape(globale1,Ns,length(globale1)/Ns));
title("Diagramme de l'oeil pour Bw = 1000");

% Réponse en fréquence
h = conv(h1,h1); % en temporelle
H = abs(fft(h,1024)); % en fréquentielle
H = H/max(H);
freqH = linspace(-BW1/2, BW1/2, length(H));
Hc1 = abs(fft(hc1,1024)); % en fréquentielle
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
title ('Représentation fréquentielle pour BW=1000 Hz');

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
title('Réponse impulsionnelle globale de la chaine de transmission');

% Diagramme de l'oeil
figure;

plot(reshape(globale2,Ns,length(globale2)/Ns)); 
title("Diagramme de l'oeil pour Bw = 8000 Hz");


% Réponse en fréquence
h = conv(h1,h1); % en temporelle
H = abs(fft(h,1024)); % en fréquentielle
H = H/max(H);
freqH = linspace(-BW2/2, BW2/2, length(H));
Hc2 = abs(fft(hc2,1024)); % en fréquentielle
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
title ('Représentation fréquentielle pour BW=8000 Hz');

% Taux d'erreur binaire
z_ech2 = globale2(n0:Ns:end);
bits_estimes2 = (sign(z_ech2)+1)/2;
TEB8000 = mean(bits1(1:end-retard)~=bits_estimes2(retard+1:end));
% TEB8000 = 0;

close all;

%% Étude de l'impact du bruit et du filtrage adapté, notion d'efficacité en puissance


Fe = 24000; % fréquence d'échantillonage
Rb = 3000; % débit binaire 3000 bits par seconde
retard= 0;


% Chaine 1
% Mapping : symboles binaires à moyenne nulle
bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondérées
h1 = ones(1, Nb);
h1 = h1/norm(h1);
NRZ1 = filter(h1, 1, signal1); %application du filtre de mise en forme
z1 = filter(h1, 1, NRZ1); % filtre de réception
z_ech1 = z1(n0:Ns:end);
bits_estimes1 = (sign(z_ech1)+1)/2;
TEB1 = mean(bits1(1:end-retard)~=bits_estimes1(retard+1:end));

% Diagramme de l'oeil
figure;
plot(reshape(z1,Ns,length(z1)/Ns));
title("Diagramme de l'oeil pour la chaine 1");
% Instant optimal :8


% Avec le bruit
n0 = 8;
Px = mean(abs(NRZ1).^2); % Puissance du signal à bruiter
M = 2; % ordre de la modulation
Ns = 8; % facteur de suréchantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal à bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en décimal
TEB1= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit = sqrt(sigma_n_carre)*randn(size(NRZ1));
    NRZ1_bruit = NRZ1 +bruit; %ajout du bruit
    z1_bruit = filter(h1, 1, NRZ1_bruit); % filtre de réception
    z_ech1_bruit = z1_bruit(n0:Ns:end);
    bits_estimes1_bruit = (sign(z_ech1_bruit)+1)/2;
    TEB1(i) = mean(bits1(1:end-retard)~=bits_estimes1_bruit(retard+1:end));
end
TEB1_th = qfunc(sqrt(2*Eb_N0));

% Diagramme de l'oeil
figure;
plot(reshape(z1_bruit,Ns,length(z1_bruit)/Ns));
title("Diagramme de l'oeil pour la chaine 1 avec du bruit");

% Tracé des TEB estimés et théoriques
figure;
semilogy(Eb_N0_dB,TEB1);
hold on
semilogy(Eb_N0_dB,TEB1_th);
legend("TEB calculé", "TEB théorique");
title("Tracé des TEBs estimés et théoriques");


% Chaine 2
% Mapping : symboles binaires à moyenne nulle
bits2 = randi([0 1],1,N);
symb2 = 2*bits2 - 1;
dirac2 = [1 zeros(1,Nb-1)];
signal2 = kron(symb2,dirac2); %somme des diracs pondérées
h1 = ones(1, Nb); %filtre de mise en forme
h2 = ones(1, Nb/2); %filtre de reception
h1 = h1/norm(h1);
h2 = h2/norm(h2);
NRZ2 = filter(h1, 1, signal2); %application du filtre de mise en forme
z2 = filter(h2, 1, NRZ2);
z_ech2 = z2(n0:Ns:end);
bits_estimes2 = (sign(z_ech2)+1)/2;
TEB2 = mean(bits2(1:end-retard)~=bits_estimes2(retard+1:end));

% Diagramme de l'oeil
figure;
plot(reshape(z2,Ns,length(z2)/Ns));
title("Diagramme de l'oeil pour la chaine 2");
% Instant optimal [4, 8]

% Avec le bruit

Px = mean(abs(NRZ2).^2); % Puissance du signal à bruiter
M = 2; % ordre de la modulation
Ns = 8; % facteur de suréchantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal à bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en décimal
TEB2= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit2 = sqrt(sigma_n_carre)*randn(size(NRZ2));
    NRZ2_bruit = NRZ2 + bruit2; %ajout du bruit
    z2_bruit = filter(h2, 1, NRZ2_bruit); % filtre de réception
    z_ech2_bruit = z2_bruit(n0:Ns:end);
    bits_estimes2_bruit = (sign(z_ech2_bruit)+1)/2;
    TEB2(i) = mean(bits2(1:end-retard)~=bits_estimes2_bruit(retard+1:end));
end
TEB2_th = qfunc(sqrt(Eb_N0));


% Diagramme de l'oeil
figure;
plot(reshape(z2_bruit,Ns,length(z2_bruit)/Ns));
title("Diagramme de l'oeil pour la chaine 2 avec du bruit");

% Tracé des TEB estimés et théoriques
figure;
semilogy(Eb_N0_dB,TEB2);
hold on
semilogy(Eb_N0_dB,TEB2_th);
legend("TEB calculé", "TEB théorique");
title("Tracé des TEBs estimés et théoriques");



% Chaine 3
% Mapping : symboles 4-aires à moyenne nulle

Ns    = 2*Nb;
bits3 = randi([0 1],1,N);

% Passage en symbole manuellement
bits3_1 = reshape(bits3, 2, []) == [0; 0];
Bits3_1 = Bits3_1(1,:) & Bits3_1(2,:);
Bits3_2 = reshape(bits3, 2, []) == [0; 1];
Bits3_2 = Bits3_2(1,:) & Bits3_2(2,:);
Bits3_3 = reshape(bits3, 2, []) == [1; 0];
Bits3_3 = Bits3_3(1,:) & Bits3_3(2,:);
Bits3_4 = reshape(bits3, 2, []) == [1; 1];
Bits3_4 = Bits3_4(1,:) & Bits3_4(2,:);
symb3 = -3*V*Bits3_1 - V*Bits3_2 + 3*V*Bits3_3 + V*Bits3_4;

signal3 = kron(symb3, ones(1,Ns) - [0 ones(1,Ns-1)]);

h1 = ones(1, Ns); %filtre de réception
h1 = h1/norm(h1);
NRZ3 = filter(h1, 1, signal3);
z3 = filter(h1, 1, NRZ3);
n0=Ns;

z_ech3 = reshape(z3, [Ns N/2]);
z_ech3 = z_ech3(n0,:);

s3 = 2;
s2 = 0;
s1 = -2;
symb_estimes3= 1*(z_ech3>=s3)+3*(z_ech3<s3 & z_ech3>s2) + (-1)*(z_ech3<=s2 & z_ech3>s1) + (-3)*(z_ech3<=s1);
TES3 = mean(symb3~=symb_estimes3);
bits_estimes3=int2bit((symb_estimes3+3)/2,2);
bits_estimes3=reshape(bits_estimes3,1, N);
TEB3 = mean(bits3~=bits_estimes3);

% Diagramme de l'oeil
figure;
plot(reshape(z3,Ns,length(z3)/Ns));
title("Diagramme de l'oeil pour la chaine 3");
% Instant optimal : 16 = Ns

% Avec bruit
Px = mean(abs(NRZ3).^2); % Puissance du signal à bruiter
M = 4; % ordre de la modulation
Ns = 16; % facteur de suréchantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal à bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en décimal
TES3= zeros(1,length(Eb_N0_dB));
TEB3= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit3 = sqrt(sigma_n_carre)*randn(1,length(NRZ3));
    NRZ3_bruit = NRZ3 + bruit3; %ajout du bruit
    z3_bruit = filter(h1, 1, NRZ3_bruit); % filtre de réception
    z_ech3_bruit = reshape(z3_bruit, [Ns N/2]);
    z_ech3_bruit = z_ech3_bruit(Ns,:);
    symb_estimes3_bis= 1*(z_ech3_bruit>=s3)+3*(z_ech3_bruit<s3 & z_ech3_bruit>s2) + (-1)*(z_ech3_bruit<=s2 & z_ech3_bruit>s1) + (-3)*(z_ech3_bruit<=s1);
    bits_estimes3_bis=int2bit((symb_estimes3_bis+3)/2,2);
    bits_estimes3_bis=reshape(bits_estimes3_bis,[1 N]);
    TEB3(i) = mean(bits3~=bits_estimes3_bis);
end

TEB3_th = (3/4)*qfunc(sqrt((4/5)*Eb_N0)); %exercice 2 TD3
TES3_th = TEB3_th*2;

% Diagramme de l'oeil
figure;
plot(reshape(z3_bruit,Ns,length(z3_bruit)/Ns));
title("Diagramme de l'oeil pour la chaine 3 avec du bruit");

% Tracé des TEB estimés et théoriques
figure;
semilogy(Eb_N0_dB,TEB3);
hold on
semilogy(Eb_N0_dB,TEB3_th);
legend("TEB calculé", "TEB théorique");
title("Tracé des TEBs estimés et théoriques pour la chaine 3");

%% Comparaison des chaines de transmissions

%Trac� des TEB pour le 1 et le 2
figure;
semilogy(Eb_N0_db,TEB1);
hold on;
semilogy(Eb_N0_db,TEB2);
legend("TEB de la chaine 1", "TEB de la chaine 2");
title("Comparaison des TEB pour la chaine 1 et 2");

%Comparaison des DSP

%Trac� des TEB pour le 1 et le 3
figure;
semilogy(Eb_N0_db,TEB1);
hold on;
semilogy(Eb_N0_db,TEB3);
legend("TEB de la chaine 1", "TEB de la chaine 3");
title("Comparaison des TEB pour la chaine 1 et 3");

