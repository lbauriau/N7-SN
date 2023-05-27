%% Partie 3 :Introduction à la syncrhonisation

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% 2 Impact d'une erreur de phase porteuse

% Chaine de transmission avec erreur de phase et sans bruit

N = 1e4; %Nombre de bits
Fe = 24000; %Fréquence d'échantillonnage
Te = 1/Fe; % Période d'échantillonnage
Rb = 6000; %Débit binaire en bits/s
Tb = 1/Rb; % Durée d'un symbole
Ns = Tb/Te; % On détermine ainsi Ns : le facteur de suréchantillonnage 
Ts = Ns/Fe;
Nb = Fe/Rb;
tps =linspace(0,Ts*N,Ns*N); %temps
V = 1;
n0=4;
phi_degre =[0 40 100 180]; %valeur du déphasage en degre
phi = (phi_degre/360)*2*pi; %valeur du déphasage en radian
Iw = 0; %bruit
TEB = zeros(1,1);

bits = randi([0 1],1,N);
symb = 2*bits - 1;
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac);
h1 = ones(1, Nb);
h1 = h1/norm(h1);
xe = filter(h1, 1, signal);


% Ajout du bruit
x_bruit = xe + Iw; %ajout du bruit

for l = 1:4

    % Ajout du dephasage
    hr = exp(i*phi(l))*x_bruit;

    z = filter(h1, 1, hr);
    z = real(z);
    z_ech = z(n0:Ns:end);
    bits_estimes = (sign(z_ech)+1)/2;

    DSP=pwelch(xe,[],[],[],Fe,'twosided');
    freq=linspace(-Fe/2,Fe/2,length(DSP));


%     % Diagramme de l'oeil
%     figure;
%     plot(reshape(z,Ns,length(z)/Ns));
%     title("Diagramme de l'oeil");
       
    if l == 1
        h0 = hr;
    elseif l==2
        h40 = hr;
    elseif l==3
        h100 = hr;
    else
        h180 = hr;
    end
    

    % Taux d'erreur binaire

    TEB(l) = mean(bits~=bits_estimes);

end;
figure;
plot(h180, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission pour phi = 0");

figure;
subplot(2,2,1);
plot(h180, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission pour phi = 0");
subplot(2,2,2);
plot(h40, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission pour phi = 40");
subplot(2,2,3);
plot(h100, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission pour phi = 100");
subplot(2,2,4);
plot(h180, "+");
axis([-1.1 1.1 -1.1 1.1]);
title("Constellation émission pour phi = 180");

figure;
plot(phi_degre, TEB);
title("Tracé du TEB en fonction  des erreurs de phase")

%% Chaine de transmission avec erreur de phase et ajout de bruit

%% pour phi = 0 et phi = 40
close all;
clear all;

N = 1e5; %Nombre de bits
Fe = 24000; %Fréquence d'échantillonnage
Te = 1/Fe; % Période d'échantillonnage
Rb = 6000; %Débit binaire en bits/s
Tb = 1/Rb; % Durée d'un symbole
Ns = Tb/Te; % On détermine ainsi Ns : le facteur de suréchantillonnage 
Ts = Ns/Fe;
Nb = Fe/Rb;
tps =linspace(0,Ts*N,Ns*N); %temps
V = 1;
n0=4;
phi_degre = [0 40]; %valeur du déphasage en degre
phi = (phi_degre/360)*2*pi; %valeur du déphasage en radian



TEB_0 = zeros(1,1);
TEB_40 = zeros(1,1);
TEB_theorique = zeros(1,1);
size = 6;
step = 0.5;

bits = randi([0 1],1,N);
symb = 2*bits - 1;
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac);
h1 = ones(1, Nb);
h1 = h1/norm(h1);
xe = filter(h1, 1, signal);

%Bruit
Px = mean(abs(xe).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Eb_N0_dB =[0:0.02:6]; % rapport signal Ã  bruit en dB

for l = 1:length(Eb_N0_dB)
    for m = 1:2

        %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

        if m==1

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(i*phi(m))*x_bruit;

            z = filter(h1, 1, hr);
            z = real(z);
            z_ech = z(n0:Ns:end);
            bits_estimes = (sign(z_ech)+1)/2;

            DSP=pwelch(xe,[],[],[],Fe,'twosided');
            freq=linspace(-Fe/2,Fe/2,length(DSP));


            %     % Diagramme de l'oeil
            %     figure;
            %     plot(reshape(z,Ns,length(z)/Ns));
            %     title("Diagramme de l'oeil");
            %


            % Taux d'erreur binaire

            TEB_0(l) = mean(bits~=bits_estimes);

        else

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(i*phi(m))*x_bruit;

            z = filter(h1, 1, hr);
            z = real(z);
            z_ech = z(n0:Ns:end);
            bits_estimes = (sign(z_ech)+1)/2;

            DSP=pwelch(xe,[],[],[],Fe,'twosided');
            freq=linspace(-Fe/2,Fe/2,length(DSP));


            %     % Diagramme de l'oeil
            %     figure;
            %     plot(reshape(z,Ns,length(z)/Ns));
            %     title("Diagramme de l'oeil");
            %


            % Taux d'erreur binaire

            TEB_40(l) = mean(bits~=bits_estimes);

        end
    end;

    TEB_theorique(l) = qfunc(sqrt(2*Eb_N0)*sin(pi/M));

end;

figure;
semilogy(Eb_N0_dB, TEB_0);
hold on;
semilogy(Eb_N0_dB, TEB_40);
hold on;
semilogy(Eb_N0_dB, TEB_theorique);
legend("TEB calculté avec phi = 0", "TEB calculté avec phi = 40","TEB théorique");
title("Tracé du TEB en fonction de la puissance du bruit")



%% pour phi = 40 et phi = 100
close all;
clear all;

N = 1e5; %Nombre de bits
Fe = 24000; %Fréquence d'échantillonnage
Te = 1/Fe; % Période d'échantillonnage
Rb = 6000; %Débit binaire en bits/s
Tb = 1/Rb; % Durée d'un symbole
Ns = Tb/Te; % On détermine ainsi Ns : le facteur de suréchantillonnage 
Ts = Ns/Fe;
Nb = Fe/Rb;
tps =linspace(0,Ts*N,Ns*N); %temps
V = 1;
n0=4;
phi_degre = [40 100]; %valeur du déphasage en degre
phi = (phi_degre/360)*2*pi; %valeur du déphasage en radian



TEB_40 = zeros(1,1);
TEB_100 = zeros(1,1);
TEB_theorique = zeros(1,1);
size = 6;
step = 0.5;

bits = randi([0 1],1,N);
symb = 2*bits - 1;
dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac);
h1 = ones(1, Nb);
h1 = h1/norm(h1);
xe = filter(h1, 1, signal);

%Bruit
Px = mean(abs(xe).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Eb_N0_dB =[0:0.02:6]; % rapport signal Ã  bruit en dB

for l = 1:length(Eb_N0_dB)
    for m = 1:2

        %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

        if m==1

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(i*phi(m))*x_bruit;

            z = filter(h1, 1, hr);
            z = real(z);
            z_ech = z(n0:Ns:end);
            bits_estimes = (sign(z_ech)+1)/2;

            DSP=pwelch(xe,[],[],[],Fe,'twosided');
            freq=linspace(-Fe/2,Fe/2,length(DSP));


            %     % Diagramme de l'oeil
            %     figure;
            %     plot(reshape(z,Ns,length(z)/Ns));
            %     title("Diagramme de l'oeil");
            %


            % Taux d'erreur binaire

            TEB_40(l) = mean(bits~=bits_estimes);

        else

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(i*phi(m))*x_bruit;

            z = filter(h1, 1, hr);
            z = real(z);
            z_ech = z(n0:Ns:end);
            bits_estimes = (sign(z_ech)+1)/2;

            DSP=pwelch(xe,[],[],[],Fe,'twosided');
            freq=linspace(-Fe/2,Fe/2,length(DSP));


            %     % Diagramme de l'oeil
            %     figure;
            %     plot(reshape(z,Ns,length(z)/Ns));
            %     title("Diagramme de l'oeil");
            %


            % Taux d'erreur binaire

            TEB_100(l) = mean(bits~=bits_estimes);

        end
    end;

    TEB_theorique(l) = qfunc(sqrt(2*Eb_N0)*sin(pi/M));

end;

figure;
semilogy(Eb_N0_dB, TEB_40);
hold on;
semilogy(Eb_N0_dB, TEB_100);
hold on;
semilogy(Eb_N0_dB, TEB_theorique);
legend("TEB calculé avec phi = 40", "TEB calculé avec phi = 100","TEB théorique");
title("Tracé du TEB en fonction de la puissance du bruit")