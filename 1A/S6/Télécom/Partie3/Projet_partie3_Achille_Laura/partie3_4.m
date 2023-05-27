%% Partie 3 :Introduction à la syncrhonisation

% Ãtudiant : JEANVOINE Achille
% Ãtudiant :BAURIAUD Laura
% Groupe : I

close all;
clear all;

%% 3.Estimation et correction de l'erreur de phase porteuse


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
phi_degre = [40 100]; %valeur du déphasage en degre
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

phi_estime_40 = zeros(1,1);
phi_estime_100 = zeros(1,1);

%Bruit
Px = mean(abs(xe).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Eb_N0_dB =[0:0.02:6]; % rapport signal Ã  bruit en dB

for l = 1:length(Eb_N0_dB)
    for m = 1:2
        if m==1 

            %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(i*phi(m))*x_bruit;

           
            z = filter(h1, 1, hr);
            zm = z(n0:Ns:end);
            somme_zm_carre = sum(zm.^2);

            %estimation de phi
            phi_estime_40(l) = (1/2)*phase(somme_zm_carre);
            z = exp(i*phi_estime_40(l))*zm;

            z_ech = real(z);
            
            bits_estimes = (sign(z_ech)+1)/2;

            % Taux d'erreur binaire

            TEB_40_cor(l) = mean(bits~=bits_estimes);

        else
            %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(1i*phi(m))*x_bruit;

           
            z = filter(h1, 1, hr);
            zm = z(n0:Ns:end);
            somme_zm_carre = sum(zm.^2);

            %estimation de phi
            phi_estime_100(l) = (1/2)*phase(somme_zm_carre);
            z = exp(1i*phi_estime_100(l))*zm;

            z_ech = real(z);

          
            bits_estimes = (sign(z_ech)+1)/2;


            % Taux d'erreur binaire

            TEB_100_cor(l) = mean(bits~=bits_estimes);

        end
    end

    TEB_theorique(l) = qfunc(sqrt(2*Eb_N0)*sin(pi/M));

end

%% 4. Utilisation d'un codage par transition


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
n0=Ns;
phi_degre = [40 100]; %valeur du déphasage en degre
phi = (phi_degre/180)*pi; %valeur du déphasage en radian



TEB_40_transi = zeros(1,1);
TEB_40_transi_phi = zeros(1,1);
TEB_100_transi = zeros(1,1);
TEB_100_transi_phi = zeros(1,1);
TEB_theorique = zeros(1,1);
size = 6;
step = 0.5;

bits = randi([0 1],1,N);
symb = 2*bits - 1;

%Codage
ck=zeros(1,N);
ck(1) = symb(1);
for k=2:length(symb)
    ck(k)=symb(k)*ck(k-1);
end

dirac = [1 zeros(1,Nb-1)];
signal = kron(symb,dirac);
h1 = ones(1, Nb);
h1 = h1/norm(h1);
xe = filter(h1, 1, signal);

phi_estime_40 = zeros(1,1);
phi_estime_100 = zeros(1,1);

%Bruit
Px = mean(abs(xe).^2); % Puissance du signal Ã  bruiter
M = 2; % ordre de la modulation
Eb_N0_dB =[0:0.02:6]; % rapport signal Ã  bruit en dB

for l = 1:length(Eb_N0_dB)
    for m = 1:2
        if m==1 

            %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(1i*phi(m))*x_bruit;

           
            z = filter(h1, 1, hr);
            zm = z(n0:Ns:end);

            % Estimation de phi
            somme_zm_carre = sum(zm.^2);
            phi_estime_40(l) = (1/2)*angle(somme_zm_carre);
            z_phi = exp(-1i*phi_estime_40(l))*zm;
            z_real = real(z_phi);


            %Décodage par transition sans l'estimation de phi
            ck_40 = zeros(1,1);
            ck_40(1) = zm(1);
            for ji = 2:length(zm)
                ck_40(ji) = zm(ji)*zm(ji-1);
            end
            ck_40 = real(ck_40);
            bits_estimes_transi = (sign(ck_40)+1)/2;

            % Décodage et estimation de phi
            ck_40_phi = zeros(1,N);
            ck_40_phi(1) = z_phi(1);
            for jj = 2:length(zm)
                ck_40_phi(jj) = z_phi(jj)*z_phi(jj-1);
            end
            ck_40_phi = real(ck_40_phi);
            bits_estimes_transi_phi = (sign(ck_40_phi)+1)/2;



            % Taux d'erreur binaire

            TEB_40_transi(l) = mean(bits~=bits_estimes_transi);
            TEB_40_transi_phi(l) = mean(bits~=bits_estimes_transi_phi);

        else
            %Ajout du bruit
            Eb_N0 = 10.^(Eb_N0_dB(l)/10); % on repasse en dÃ©cimal
            sigma_n_carre = (Px*Ns)/(2*log2(M)*Eb_N0); % Puissance du bruit
            Iw = sqrt(sigma_n_carre)*randn(1,length(xe));

            x_bruit = xe + Iw;

            % Ajout du dephasage
            hr = exp(1i*phi(m))*x_bruit;

           
            z = filter(h1, 1, hr);
            zm = z(n0:Ns:end);

            % Estimation de phi
            somme_zm_carre = sum(zm.^2);
            phi_estime_100(l) = (1/2)*phase(somme_zm_carre);
            z = exp(1i*phi_estime_100(l))*zm;


            %Décodage par transition sans estimation de phi
            ck_100 = zeros(1,1);
            ck_100(1) = zm(1);
            for ji = 2:length(zm)
                ck_100(ji) = zm(ji)*zm(ji-1);
            end
            ck_100 = real(ck_100);
            bits_estimes_transi = (sign(ck_100)+1)/2;

            % Décodage et estimation de phi
            ck_100_phi = zeros(1,1);
            ck_100_phi(1) = z(1);
            for jj = 2:length(zm)
                ck_100_phi(jj) = z(jj)*z(jj-1);
            end
            ck_100_phi = real(ck_100_phi);
            bits_estimes_transi_phi = (sign(ck_100_phi)+1)/2;



            % Taux d'erreur binaire

            TEB_100_transi(l) = mean(bits~=bits_estimes_transi);
            TEB_100_transi_phi(l) = mean(bits~=bits_estimes_transi_phi);


        end
    end

    TEB_theorique(l) = qfunc(sqrt(2*Eb_N0)*sin(pi/M));

end

% 
% figure;
% semilogy(Eb_N0_dB, TEB_40_cor);
% hold on;
% semilogy(Eb_N0_dB, TEB_40_transi);
% hold on;
% semilogy(Eb_N0_dB, TEB_40_transi_phi);
% hold on;
% semilogy(Eb_N0_dB, TEB_theorique);
% legend("TEB calculé avec correction de phase","TEB calculé avec un codage par transition","TEB calculé avec phi = 40 corrigé et codage par transition", "TEB théorique");
% title("Tracé du TEB en fonction de la puissance du bruit et correction de phase")
% 
% 
% figure;
% semilogy(Eb_N0_dB, TEB_100_cor);
% hold on;
% semilogy(Eb_N0_dB, TEB_100_transi);
% hold on;
% semilogy(Eb_N0_dB, TEB_100_transi_phi);
% hold on;
% semilogy(Eb_N0_dB, TEB_theorique);
% legend("TEB calculé avec correction de phase","TEB calculé avec un codage par transition","TEB calculé avec phi = 100 corrigé et codage par transition", "TEB théorique");
% title("Tracé du TEB en fonction de la puissance du bruit et correction de phase")


phi_estime_40_deg = mean(abs(phi_estime_40))/(2*pi)*360;
phi_estime_100_deg = mean(abs(phi_estime_100))/(2*pi)*360;
