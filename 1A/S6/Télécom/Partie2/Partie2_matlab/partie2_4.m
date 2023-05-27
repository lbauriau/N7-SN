%% Partie 2 :Étude de chaines de transmission sur porteuse : modulateur DVB-S, DVB-S2

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Implantation de la transmission avec transposition de fréquence

% Paramètres
N = 1e5; % nombres de bits générés
Fe = 6e3; % Fréquence d'échantillonnage (Hz)
Rb = 3e3; % Débit binaire (bits/s)
fp = 2e3; % fréquence porteuse (Hz)
Nb = Fe/Rb;
Te = 1/Fe;
Tb = 1/Rb; % Durée d'un symbole
Ns = Tb/Te; % On détermine ainsi Ns : le facteur de suréchantillonnage
Ts = Ns/Fe;
tps =linspace(0,Ts*N, 1/2*Ns*N); %temps
V = 1;


% Modulateur Q-PSK (4-PSK)

% Génération des bits
bits = randi([0 1],1,N);

% Mapping Q-PSK

symb = zeros(1,N/2);
sumB = 0;
for j=1:N/2
    sumB = 2*bits(2*j-1)+bits(2*j);
    if (sumB == 0)
        symb(j) = exp(1i*pi/4);
    end
    if (sumB == 1)
        symb(j) = exp(3*1i*pi/4);
    end
    if (sumB == 2)
        symb(j) = exp(-1i*pi/4);
    end
    if (sumB == 3)
        symb(j) = exp(-3*1i*pi/4);
    end
end

% Génération symboles
dataIn = randi([0 8-1],(N-1)/3,1); % 1 symbole => 3 bits

% Mapping 8-PSK
y = pskmod(dataIn,8,pi/8);


% Somme des diracs pondérés
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac); %somme des diracs pondÃ©rÃ©es


% h(t) filtre en racine cosinus surélevé
SPAN = 8;
alpha = 0.35;
h = rcosdesign (alpha,SPAN, Nb);
xe = filter(h, 1, signal);
retard = SPAN*2;


% Signal avant la transmission
x = real(xe);

%Bruit
Px = mean(abs(x).^2); % Puissance du signal Ã  bruiter
M = 4; % ordre de la modulation

%Filtre passe bas
ordre = 161;
echant1 = [-(ordre-1)/2 : (ordre-1)/2];
BW1 = 8000;
hc1 = (2*BW1/Fe) * sinc (2*BW1/Fe * echant1);
Hc1 = abs(fft(hc1,1024)); % en frÃ©quentielle
Hc1 = Hc1/max(Hc1);

size_max = 6;
step_boucle = 0.5;
TEB_list = zeros(1,1);
TEB_list_8PSK = zeros(1,1);
TEB_theorique_QPSK = zeros(1,1);
TEB_theorique_8PSK = zeros(1,1);

j = 1;

min_boucle = 0;
for Eb_N0_dB = min_boucle:step_boucle:size_max
    % Eb_N0_dB = 2;
    Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
    sigma_n_carre = (Px*Ns*2)/(2*log2(M)*Eb_N0); % Puissance du bruit, Pxe = Px/2
    bruit1 = sqrt(sigma_n_carre)*randn(1,length(x));
    bruit2 = sqrt(sigma_n_carre)*randn(1,length(x));
    bruit_complexe = bruit1 + 1i*bruit2;
    x_bruit = xe + bruit_complexe; %ajout du bruit

    % 8-PSK ajout bruit complexe
    sigma_n_carre = (Px*Ns*2)/(2*log2(8)*Eb_N0); % Puissance du bruit, Pxe = Px/2
    bruit2_1 = sqrt(sigma_n_carre)*randn(length(y),1);
    bruit2_2 = sqrt(sigma_n_carre)*randn(length(y),1);
    bruit_complexe2 = bruit2_1 + 1i*bruit2_2;
    y_bruit = y + bruit_complexe2;

    % Démodulation
    x_demod = filter(h, 1, x_bruit); % filtre de rÃ©ception

    n0=1;

    x_ech = x_demod(n0:Ns:end);

    %% Demapping

    bits_estimes = zeros(1,N);
    % A B : A bit impair, B bit pair
    % Si la partie imaginaire est positive => bit impair = 0;
    % Si la partie réelle est positive => bit pair = 0;
    bits_estimes(1:2:end) = ~(sign(imag(x_ech(1:end))) == ones(1,N/2)); %Bits impairs => partie imaginaire
    bits_estimes(2:2:end) = ~(sign(real(x_ech(1:end))) == ones(1,N/2)); %Bits pairs => partie réelle

    TEB = mean(bits(1:end-retard)~=bits_estimes(retard+1:end));
    TEB_list(j) = TEB;
    TEB_theorique_QPSK(j) = qfunc(sqrt(2*Eb_N0)); % M=4 donc Es = 2 Eb
    [TEB TEB_theorique_QPSK(j) Eb_N0_dB];

    % Demap 8-PSK
    dataOut = pskdemod(y_bruit,8,pi/8);
    [~, TES] = symerr(dataIn,dataOut);
    TEB_2 = TES/(log2(8));
    TEB_list_8PSK(j) = TEB_2;
    TEB_theorique_8PSK(j) = 2/3*qfunc(sqrt(2*3*Eb_N0)*sin(pi/8));

    % Tracé constellations
    % POur tracer la constellation mettre veutTrace à 1
    veutTrace = 0;
    if veutTrace == 1
        scatterplot(y_bruit)
        title("Constellation 8-PSK avec Eb/N0 = " + Eb_N0_dB)

%      scatterplot(x_bruit)
%      title("Constellation QPSK avec Eb/N0 = " + Eb_N0_dB)
    end

    j = j+1;

end

DSP8=pwelch(xe,[],[],[],Fe,'twosided');
freq8 = linspace(-Fe/2,Fe/2,length(DSP8));

% Tracé de la constellation à la sortie du mappping
plot(dataOut, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission");

% Tracé TEB calculé et TEB théorique
figure
title("Tracé du TEB en fonction du rapport Eb/N0")
xlabel("Eb/N0 en dB");
ylabel("TEB");
semilogy(min_boucle:step_boucle:size_max,TEB_list_8PSK)
hold on;
semilogy(min_boucle:step_boucle:size_max,TEB_theorique_8PSK)
legend('TEB calculé 8-PSK', 'TEB théorique 8-PSK')
hold off;

% Tracé TEB calculé et TEB théorique
figure
semilogy(min_boucle:step_boucle:size_max,TEB_list)
title("Tracé du TEB en fonction du rapport Eb/N0")
hold on;
semilogy(min_boucle:step_boucle:size_max,TEB_theorique_QPSK)
xlabel = "Eb/N0 en dB";
ylabel = "TEB";
semilogy(min_boucle:step_boucle:size_max,TEB_list_8PSK)
semilogy(min_boucle:step_boucle:size_max,TEB_theorique_8PSK)
legend('TEB calculé QPSK','TEB théorique QPSK', 'TEB calculé 8-PSK', 'TEB théorique 8-PSK')
hold off;

%Tracé de la DSP
figure;
plot(freq8,fftshift(DSP8/max(DSP8)));
xlabel = "Fréquence en Hz";
ylabel = "Module de la DSP de NRZ";
title('Densité spectrale de puissance des signaux générés')
