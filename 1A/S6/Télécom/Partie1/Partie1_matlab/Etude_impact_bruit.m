%% Partie 1 : Ã©tude de chaines de transmissions en bande de base

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Ãtude de l'impact du bruit et du filtrage adaptÃ©, notion d'efficacitÃ© en puissance

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
retard= 0;


%% Chaine 1
% Mapping : symboles binaires Ã  moyenne nulle
n0 =8;
bits1 = randi([0 1],1,N);
symb1 = 2*bits1 - 1;
dirac1 = [1 zeros(1,Nb-1)];
signal1 = kron(symb1,dirac1); %somme des diracs pondÃ©rÃ©es
h1 = ones(1, Nb);
h1 = h1/norm(h1);
NRZ1 = filter(h1, 1, signal1); %application du filtre de mise en forme
z1 = filter(h1, 1, NRZ1); % filtre de rÃ©ception
z_ech1 = z1(n0:Ns:end);
bits_estimes1 = (sign(z_ech1)+1)/2;
TEB1 = mean(bits1(1:end-retard)~=bits_estimes1(retard+1:end));

% Diagramme de l'oeil
figure;
plot(reshape(z1,Ns,length(z1)/Ns));
title("Diagramme de l'oeil pour la chaine 1");
% Instant optimal :8


% Avec le bruit
Px = mean(abs(NRZ1).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Ns = 8; % facteur de surÃ©chantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal Ã  bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
TEB1= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit = sqrt(sigma_n_carre)*randn(size(NRZ1));
    NRZ1_bruit = NRZ1 +bruit; %ajout du bruit
    z1_bruit = filter(h1, 1, NRZ1_bruit); % filtre de rÃ©ception
    z_ech1_bruit = z1_bruit(n0:Ns:end);
    bits_estimes1_bruit = (sign(z_ech1_bruit)+1)/2;
    TEB1(i) = mean(bits1(1:end-retard)~=bits_estimes1_bruit(retard+1:end));
end
TEB1_th = qfunc(sqrt(2*Eb_N0));

% Diagramme de l'oeil
figure;
plot(reshape(z1_bruit,Ns,length(z1_bruit)/Ns));
title("Diagramme de l'oeil pour la chaine 1 avec du bruit");

% TracÃ© des TEB estimÃ©s et thÃ©oriques
figure;
semilogy(Eb_N0_dB,TEB1);
hold on
semilogy(Eb_N0_dB,TEB1_th);
legend("TEB calculÃ©", "TEB thÃ©orique");
title("TracÃ© des TEBs estimÃ©s et thÃ©oriques");


%% Chaine 2
% Mapping : symboles binaires Ã  moyenne nulle
bits2 = randi([0 1],1,N);
symb2 = 2*bits2 - 1;
dirac2 = [1 zeros(1,Nb-1)];
signal2 = kron(symb2,dirac2); %somme des diracs pondÃ©rÃ©es
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

Px = mean(abs(NRZ2).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Ns = 8; % facteur de surÃ©chantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal Ã  bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
TEB2= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit2 = sqrt(sigma_n_carre)*randn(size(NRZ2));
    NRZ2_bruit = NRZ2 + bruit2; %ajout du bruit
    z2_bruit = filter(h2, 1, NRZ2_bruit); % filtre de rÃ©ception
    z_ech2_bruit = z2_bruit(n0:Ns:end);
    bits_estimes2_bruit = (sign(z_ech2_bruit)+1)/2;
    TEB2(i) = mean(bits2(1:end-retard)~=bits_estimes2_bruit(retard+1:end));
end
TEB2_th = qfunc(sqrt(Eb_N0));


% Diagramme de l'oeil
figure;
plot(reshape(z2_bruit,Ns,length(z2_bruit)/Ns));
title("Diagramme de l'oeil pour la chaine 2 avec du bruit");

% TracÃ© des TEB estimÃ©s et thÃ©oriques
figure;
semilogy(Eb_N0_dB,TEB2);
hold on
semilogy(Eb_N0_dB,TEB2_th);
legend("TEB calculÃ©", "TEB thÃ©orique");
title("TracÃ© des TEBs estimÃ©s et thÃ©oriques");



%% Chaine 3
% Mapping : symboles 4-aires Ã  moyenne nulle

Ns    = 2*Nb;
bits3 = randi([0 1],1,N);

% Passage en symbole manuellement
Bits3_1 = reshape(bits3, 2, []) == [0; 0];
Bits3_1 = Bits3_1(1,:) & Bits3_1(2,:);
Bits3_2 = reshape(bits3, 2, []) == [0; 1];
Bits3_2 = Bits3_2(1,:) & Bits3_2(2,:);
Bits3_3 = reshape(bits3, 2, []) == [1; 0];
Bits3_3 = Bits3_3(1,:) & Bits3_3(2,:);
Bits3_4 = reshape(bits3, 2, []) == [1; 1];
Bits3_4 = Bits3_4(1,:) & Bits3_4(2,:);
symb3 = -3*V*Bits3_1 - V*Bits3_2 + 3*V*Bits3_3 + V*Bits3_4;

signal3 = kron(symb3, ones(1,Ns) - [0 ones(1,Ns-1)]);

h1 = ones(1, Ns); %filtre de rÃ©ception
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
Px = mean(abs(NRZ3).^2); % Puissance du signal Ã  bruiter
M = 4; % ordre de la modulation
Ns = 16; % facteur de surÃ©chantillonage;
Eb_N0_dB =[0:0.5:8]; % rapport signal Ã  bruit en dB
Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
TES3= zeros(1,length(Eb_N0_dB));
TEB3= zeros(1,length(Eb_N0_dB));
for i = 1:length(Eb_N0_dB)
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0(i)); % Puissance du bruit
    bruit3 = sqrt(sigma_n_carre)*randn(1,length(NRZ3));
    NRZ3_bruit = NRZ3 + bruit3; %ajout du bruit
    z3_bruit = filter(h1, 1, NRZ3_bruit); % filtre de rÃ©ception
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

% TracÃ© des TEB estimÃ©s et thÃ©oriques
figure;
semilogy(Eb_N0_dB,TEB3);
hold on
semilogy(Eb_N0_dB,TEB3_th);
legend("TEB calculÃ©", "TEB thÃ©orique");
title("TracÃ© des TEBs estimÃ©s et thÃ©oriques pour la chaine 3");

%% Comparaison des chaines de transmissions

%Tracé des TEB pour le 1 et le 2
figure;
semilogy(Eb_N0_dB,TEB1);
hold on;
semilogy(Eb_N0_dB,TEB2);
legend("TEB de la chaine 1", "TEB de la chaine 2");
title("Comparaison des TEB pour la chaine 1 et 2");

%Comparaison des DSP

%Tracé des TEB pour le 1 et le 3
figure;
semilogy(Eb_N0_dB,TEB1);
hold on;
semilogy(Eb_N0_dB,TEB3);
legend("TEB de la chaine 1", "TEB de la chaine 3");
title("Comparaison des TEB pour la chaine 1 et 3");
