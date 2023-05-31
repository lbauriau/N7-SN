%% Partie 2 :Étude de chaines de transmission sur porteuse : modulateur DVB-S, DVB-S2

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% Implantation de la transmission avec transposition de fréquence

% Paramètres
N = 1e5; % nombres de bits générés
Fe = 24e3; % Fréquence d'échantillonnage (Hz)
Rb = 3e3; % Débit binaire (bits/s)
fp = 2e3; % fréquence porteuse (Hz)
Nb = Fe/Rb;
Te = 1/Fe;
Tb = 1/Rb; % DurÃ©e d'un symbole
Ns = Tb/Te; % On dÃ©termine ainsi Ns : le facteur de surÃ©chantillonnage 
Ts = Ns/Fe;
tps =linspace(0,Ts*N, 1/2*Ns*N); %temps
V = 1;


% Modulateur Q-PSK (4-PSK)

% Génération des bits
bits = randi([0 1],1,N);

% Mapping

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


% Somme des diracs pondérés
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac); %somme des diracs pondÃ©rÃ©es


% h(t) filtre en racine cosinus surélevé 
SPAN = 10;
alpha = 0.35;
h = rcosdesign (alpha,SPAN, Nb);
xe = filter(h, 1, signal);

% Multiplication par l'exponentielle
xe_sep = xe.*exp(2*i*pi*fp*tps);

% Signal avant la transmission
x = real(xe_sep);

%Bruit
Px = mean(abs(x).^2); % Puissance du signal Ã  bruiter
M = 4; % ordre de la modulation
%Eb_N0_dB =[0:0.5:6]; % rapport signal Ã  bruit en dB

size = 6;
step = 0.05;
TEB_list = zeros(1,1);
TES_theorique = zeros(1,1);
j = 1;

for Eb_N0_dB = 0:step:size

    Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
    sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
    bruit = sqrt(sigma_n_carre)*randn(1,length(x));
    %bruit = 0;
    x_bruit = x + bruit; %ajout du bruit

   
    %Filtre passe bas
    ordre = 161;
    echant1 = [-(ordre-1)/2 : (ordre-1)/2];
    BW1 = 8000;
    hc1 = (2*BW1/Fe) * sinc (2*BW1/Fe * echant1);
    Hc1 = abs(fft(hc1,1024)); % en frÃ©quentielle
    Hc1 = Hc1/max(Hc1);

    %Filtre passe bande
    %hc_bande = (2*BW1/Fe) * sinc (2*BW1/Fe .* echant1) .* cos(2*pi*fp.*tps);


    % Signal complexe équilavent
    %x_bruit = filter(hc_bande,1,x_bruit);
    x_cos = 2*cos(2*pi*fp.*tps).*x_bruit;
    x_sin = 2*sin(2*pi*fp.*tps).*x_bruit;
    x_cos_bas = filter(hc1, 1, x_cos);
    x_sin_bas = filter(hc1, 1, x_sin);
    x_somme = x_cos_bas - 1i*x_sin_bas;

    % Démodulation
    x_demod = filter(h, 1, x_somme); % filtre de rÃ©ception

    n0=1;
    % x_ech = reshape(x_demod, [Ns N/2]);
    % x_ech = x_ech(n0,:);
    x_ech = x_demod(n0:Ns:end);
    retard= (ordre-1)/(2*Nb);
    retard = (retard+SPAN)*2; % retard binaire = (retard symbole + SPAN)*2


    bits_estimes = zeros(1,N);
    % A B : A bit impair, B bit pair
    % Si la partie imaginaire est positive => bit impair = 0;
    % Si la partie réelle est positive => bit pair = 0;
    bits_estimes(1:2:end) = ~(sign(imag(x_ech(1:end))) == ones(1,N/2)); %Bits impairs => partie imaginaire
    bits_estimes(2:2:end) = ~(sign(real(x_ech(1:end))) == ones(1,N/2)); %Bits pairs => partie réelle

    TEB = mean(bits(1:end-retard)~=bits_estimes(retard+1:end));
    TEB_list(j) = TEB;
    TES_theorique(j) = qfunc(sqrt(2*Eb_N0));
    j = j+1;

end



DSP_phase=pwelch(x_cos_bas,[],[],[],Fe,'twosided');
DSP_quadrature = pwelch(x_sin_bas,[],[],[],Fe,'twosided');
DSP_porteuse = pwelch(x_demod,[],[],[],Fe,'twosided');
freq = linspace(-Fe/2,Fe/2,length(DSP_phase));

% Pour tracer, mettre à 1
trace1 = 0;

if trace1==1

    % Tracé des signaux avant la transmission
    figure;
    plot(tps,x);
    hold on;
    title('Tracé du signal avant la transmission');


    % Tracé des signaux en phase et en quadrature
    figure;
    plot(tps,x_cos);
    hold on;
    plot(tps,x_sin);
    legend('Tracé du cosinus', 'Tracé du sinus');
    title('Tracé des signaux en phase et en quadrature');

    % Tracé des signaux après le filtre passe bas
    figure;
    plot(tps,x_cos_bas);
    hold on;
    plot(tps,x_sin_bas);
    legend('Tracé du cosinus après le filtre', 'Tracé du sinus après le filtre');
    title('Tracé des signaux en phase et en quadrature après le filtre');

    % Tracé des diagrammes de l'oeil
    figure;
    subplot(2,1,1);
    plot(real(reshape(x_demod,Ns,N/2)));
    title("Tracé du diagramme de l'oeil de la partie réelle");
    subplot(2,1,2);
    plot(imag(reshape(x_demod,Ns,N/2)));
    title("Tracé du diagramme de l'oeil de la partie imaginaire");

    % Tracé des DSP

    % Diagramme des constellations
    figure;
    subplot(2,1,1);
    plot(symb, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation émission");
    subplot(2,1,2);
    plot(x_ech(100:end), "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception");

    %Tracé des TEB en fonction du rapport Eb/N0
    figure
    semilogy(0:step:size,TEB_list)
    xlabel = "Eb/N0 en dB";
    ylabel = "TEB";
    hold on;
    semilogy(0:step:size,TES_theorique)
    legend('TEB estimé', 'TEB théorique');
    title("Tracé du TEB en fonction du rapport Eb/N0")


    %Fonction d'autocorrélation pour obtenir le retard
    figure;
    plot(xcorr(bits_estimes,bits));
    title("Fonction d'autocorrélation")

    %Tracé de la DSP
    % Tracé supreposé de la DSP en phase et en quadrature
    figure;
    plot(freq,fftshift(DSP_phase/max(DSP_phase)));
    hold ON;
    plot(freq,fftshift(DSP_quadrature/max(DSP_quadrature)));
    legend('En phase','En quadrature');
    xlabel = "Fréquence en Hz";
    ylabel = "Module de la DSP de NRZ";
    title('Densité spectrale de puissance des signaux générés')

    %Tracé de la DSP
    % Tracé supreposé de la DSP en phase et en quadrature
    figure;
    plot(freq,fftshift(DSP_porteuse/max(DSP_porteuse)));
    legend('DSP sur fréquence porteuse')
    xlabel = "Fréquence en Hz";
    ylabel = "Module de la DSP de NRZ";
    title('Densité spectrale de puissance sur fréquence porteuse')
end

%% Implantation de la chaine passe-bas équivalente à la chaine de transmission sur porteuse

close all;


% Paramètres
N = 1000; % nombres de bits générés
Fe = 24e3; % Fréquence d'échantillonnage (Hz)
Rb = 3e3; % Débit binaire (bits/s)
fp = 2e3; % fréquence porteuse (Hz)
Nb = Fe/Rb;
Te = 1/Fe;
Tb = 1/Rb; % DurÃ©e d'un symbole
Ns = Tb/Te; % On dÃ©termine ainsi Ns : le facteur de surÃ©chantillonnage 
Ts = Ns/Fe;
tps =linspace(0,Ts*N, 1/2*Ns*N); %temps
V = 1;



% Modulateur Q-PSK (4-PSK)

% Génération des bits
bits = randi([0 1],1,N);

% Mapping

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


% Somme des diracs pondérés
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac); %somme des diracs pondÃ©rÃ©es


% h(t) filtre en racine cosinus surélevé 
SPAN = 8;
alpha = 0.35;
h = rcosdesign (alpha,SPAN, Nb);
xe = filter(h, 1, signal);

% Multiplication par l'exponentielle
xe_sep = xe.*exp(2*i*pi*fp*tps);

% Signal avant la transmission
x = real(xe_sep);

%Bruit
Px = mean(abs(x).^2); % Puissance du signal Ã  bruiter
M = 4; % ordre de la modulation
%Eb_N0_dB =[0:0.5:6]; % rapport signal Ã  bruit en dB

size = 6;
step = 0.05;
TEB_list2 = zeros(1,1);
TES_theorique = zeros(1,1);
j = 1;

for Eb_N0_dB = 0:step:size

    Eb_N0 = 10.^(Eb_N0_dB/10); % on repasse en dÃ©cimal
    sigma_n_carre = (Px*2*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
    bruit1 = sqrt(sigma_n_carre)*randn(1,length(x));
    bruit2 = sqrt(sigma_n_carre)*randn(1,length(x));
    bruit_complexe = bruit1 + i*bruit2;
    %bruit = 0;
    x_bruit = xe + bruit_complexe; %ajout du bruit

   
    %Filtre passe bas
    ordre = 161;
    echant1 = [-(ordre-1)/2 : (ordre-1)/2];
    BW1 = 8000;
    hc1 = (2*BW1/Fe) * sinc (2*BW1/Fe * echant1);
    Hc1 = abs(fft(hc1,1024)); % en frÃ©quentielle
    Hc1 = Hc1/max(Hc1);


    % Démodulation
    x_demod = filter(h, 1, x_bruit); % filtre de rÃ©ception

    n0=1;
    % x_ech = reshape(x_demod, [Ns N/2]);
    % x_ech = x_ech(n0,:);
    x_ech = x_demod(n0:Ns:end);
    retard= (ordre-1)/(2*Nb);
    retard = SPAN*2; % retard binaire = (retard symbole + SPAN)*2

    if Eb_N0_dB == 0
        x_ech0 = x_ech(100:end);
    elseif Eb_N0_dB == 1
        x_ech1 = x_ech(100:end);
    elseif Eb_N0_dB == 2
        x_ech2 = x_ech(100:end);
    elseif Eb_N0_dB == 3
        x_ech3 = x_ech(100:end);
    elseif Eb_N0_dB == 4
        x_ech4 = x_ech(100:end);
    elseif Eb_N0_dB == 5
        x_ech5 = x_ech(100:end);
    elseif Eb_N0_dB == 6
        x_ech6 = x_ech(100:end);
    end


    bits_estimes = zeros(1,N);
    % A B : A bit impair, B bit pair
    % Si la partie imaginaire est positive => bit impair = 0;
    % Si la partie réelle est positive => bit pair = 0;
    bits_estimes(1:2:end) = ~(sign(imag(x_ech(1:end))) == ones(1,N/2)); %Bits impairs => partie imaginaire
    bits_estimes(2:2:end) = ~(sign(real(x_ech(1:end))) == ones(1,N/2)); %Bits pairs => partie réelle

    TEB = mean(bits(1:end-retard)~=bits_estimes(retard+1:end));
    TEB_list2(j) = TEB;
    TES_theorique(j) = qfunc(sqrt(2*Eb_N0));
    j = j+1;

end



DSP=pwelch(xe,[],[],[],Fe,'twosided');
DSP_porteuse2 = pwelch(x_demod,[],[],[],Fe,'twosided');
freq = linspace(-Fe/2,Fe/2,length(DSP));
freq2 = linspace(-Fe/2,Fe/2,length(DSP_porteuse2));

%Pour tracer, mettre à 1
trace2 = 0;
if trace2 == 1

    % Tracé des signaux avant la transmission
    figure;
    plot(tps,x);
    hold on;
    title('Tracé du signal avant la transmission');


    % Tracé des signaux en phase et en quadrature
    figure;
    plot(tps,real(x_bruit));
    hold on;
    plot(tps,imag(x_bruit));
    legend('Tracé du cosinus', 'Tracé du sinus');
    title('Tracé des signaux en phase et en quadrature');


    % Tracé des diagrammes de l'oeil
    figure;
    subplot(2,1,1);
    plot(real(reshape(x_bruit,Ns,N/2)));
    title("Tracé du diagramme de l'oeil de la partie réelle");
    subplot(2,1,2);
    plot(imag(reshape(x_bruit,Ns,N/2)));
    title("Tracé du diagramme de l'oeil de la partie imaginaire");


    % Diagramme des constellations
    figure;
    subplot(3,3,1);
    plot(symb, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation émission");
    subplot(3,3,2);
    plot(x_ech0, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =0");
    subplot(3,3,3);
    plot(x_ech1, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =1");
    subplot(3,3,4);
    plot(x_ech2, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =2");
    subplot(3,3,5);
    plot(x_ech3, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =3");
    subplot(3,3,6);
    plot(x_ech4, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =4");
    subplot(3,3,7);
    plot(x_ech5, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =5");
    subplot(3,3,8);
    plot(x_ech6, "+");
    axis([-1.1 1.1 -1.1 1.1]);
    title("Constellation reception Eb/N0 =6");

    %Tracé des TEB en fonction du rapport Eb/N0
    figure
    semilogy(0:step:size,TEB_list2)
    xlabel = "Eb/N0 en dB";
    ylabel = "TEB";
    hold on;
    semilogy(0:step:size,TES_theorique)
    legend('TEB estimé', 'TEB théorique');
    title("Tracé du TEB en fonction du rapport Eb/N0")



    %Tracé de la DSP
    % Tracé supreposé de la DSP en phase et en quadrature
    figure;
    plot(freq,fftshift(DSP/max(DSP)));
    xlabel = "Fréquence en Hz";
    ylabel = "Module de la DSP de NRZ";
    title('Densité spectrale de puissance des signaux générés')

    %Tracé de la DSP
    % Tracé supreposé de la DSP en phase et en quadrature
    figure;
    plot(freq2,fftshift(DSP_porteuse2/max(DSP_porteuse2)));
    hold on;
    plot(freq,fftshift(DSP_porteuse/max(DSP_porteuse)));
    legend("DSP sur fréquence porteuse de l'envelope complexe", "DSP du signal sur fréquence porteuse")
    xlabel = "Fréquence en Hz";
    ylabel = "Module de la DSP de NRZ";
    title('Comparaison DSP')

    %Superposition des tracés des TEB en fonction du rapport Eb/N0
    figure
    semilogy(0:step:size,TEB_list2)
    hold on;
    semilogy(0:step:size,TEB_list)
    hold on;
    plot(0:step:size,TES_theorique)
    legend('TEB estimé avec la chaine équivalente','TEB estimé', 'théorique');
    title("Tracé du TEB en fonction du rapport Eb/N0")

end

%% Implantation de la modulation DVB_S2
close all;

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

    % TES = 2*Q(sqrt(2*Es/N0*sin(pi/M))
    % TEB = TES/log2(M)
    % TEB = 2/2*Q(sqrt(2*2*Eb_N0)*sin(pi/4))
    % = Q(2sqrt(Eb/N0)*sqrt(2)/2)) = Q(sqrt(2*Eb/N0))

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

%         scatterplot(x_bruit)
%         title("Constellation QPSK avec Eb/N0 = " + Eb_N0_dB)
    end

    j = j+1;

end

DSP8=pwelch(xe,[],[],[],Fe,'twosided');
freq8 = linspace(-Fe/2,Fe/2,length(DSP8));

% Pour tracer, mettre à 1
trace3 = 1;

if trace3 == 1

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
    xlabel("Eb/N0 en dB");
    ylabel("TEB");
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

    %%Comparaison des modulateurs en puissance

    figure;
    plot(freq,fftshift(DSP));
    hold on;
    plot(freq8, fftshift(DSP8));
    legend('DSP DVB-S', 'DSP DVB-S2');
    title('Densité spectrale de puissance des signaux générés')
    hold off;
end