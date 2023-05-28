clear;
close all;
clc;

% Parametres pour l'affichage des donnees :
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

%Choix de l'affichage ou non des graphiques
affichage = 0;

N = 100;
pourcentage_tab = zeros(N,1);
sigma_tab = zeros(N,1);
sigma = 0;
pas_sigma = 1e-5;


load donnees_app;

% Donnees non filtrees :
X = X_app;
Y = Y_app;

% Parametres d'affichage :
pas = 0.002;
marge = 0.005;
valeurs_carac_1 = min(min(X(:,1)))-marge:pas:max(max(X(:,1)))+marge;
valeurs_carac_2 = min(min(X(:,2)))-marge:pas:max(max(X(:,2)))+marge;
limites_affichage = [valeurs_carac_1(1) valeurs_carac_1(end) ...
                     valeurs_carac_2(1) valeurs_carac_2(end)];
nom_carac_1 = 'Compacite';
nom_carac_2 = 'Contraste';

for J= 1:N
    
    %Choix du sigma
    sigma = sigma + pas_sigma;
    sigma_tab(J) = sigma;
    
    % Estimation du SVM avec noyau gaussien :
    [X_VS,Y_VS,Alpha_VS,c,code_retour] = SVM_3(X,Y,sigma);
    
    
    % Si l'optimisation n'a pas converge :
    if code_retour ~= 1
        return;
    end
    
    % Regle de decision du SVM :
    nb_1 = length(valeurs_carac_1);
    nb_2 = length(valeurs_carac_2);
    SVM_predict = zeros(nb_2,nb_1);
    for i = 1:nb_1
        for j = 1:nb_2
            x_ij = [valeurs_carac_1(i) ; valeurs_carac_2(j)];
            SVM_predict(j,i) = sign(exp(-sum((X_VS-x_ij').^2,2)/(2*sigma^2))'*diag(Y_VS)*Alpha_VS-c);
        end
    end
    
    if (J == 1) || (J == 25) || (J == 50) || (J == 75) || (sigma == 1.5e-4)
        affichage = 1;
    else
        affichage = 0;
    end
    
    if affichage == 1
        
        % Affichage des classes predites par le SVM :
        figure('Name','Classification par SVM avec noyau gaussien','Position',[0.2*L,0.1*H,0.6*L,0.7*H]);
        surface(valeurs_carac_1,valeurs_carac_2,SVM_predict,'EdgeColor','none');
        carte_couleurs = [.65 .65 .85 ; .85 .65 .65];
        colormap(carte_couleurs);
        xlabel(nom_carac_1,'FontSize',30);
        ylabel(nom_carac_2,'FontSize',30);
        title(sigma);
        set(gca,'FontSize',20);
        axis(limites_affichage);
        hold on;
        
        % Affichage des points de l'ensemble d'apprentissage :
        nb_carac = size(X,2);
        ind_moins_1 = Y==-1;
        ind_plus_1 = Y==1;
        plot3(X(ind_moins_1,1),X(ind_moins_1,2),(nb_carac+1)*ones(sum(ind_moins_1),1),...
            'bx','MarkerSize',10,'LineWidth',3);
        plot3(X(ind_plus_1,1),X(ind_plus_1,2),(nb_carac+1)*ones(sum(ind_plus_1),1),...
            'ro','MarkerSize',10,'LineWidth',3);
        
        % Les vecteurs de support sont entoures en noir :
        plot3(X_VS(:,1),X_VS(:,2),(nb_carac+1)*ones(size(X_VS,1)),'ko','MarkerSize',20,'LineWidth',3);
    end
    
    % Pourcentage de bonnes classifications des donnees de test :
    load donnees_test;
    nb_donnees_test = size(X_test,1);
    nb_classif_OK = 0;
    for i = 1:nb_donnees_test
        x_i = X_test(i,:);
        prediction = sign(exp(-sum((X_VS-x_i).^2,2)/(2*sigma^2))'*diag(Y_VS)*Alpha_VS-c);
        if prediction==Y_test(i)
            nb_classif_OK = nb_classif_OK+1;
        end
    end
    pourcentage = nb_classif_OK/nb_donnees_test*100;
    if affichage == 1
        fprintf('Pourcentage de bonnes classifications des donnes de test : %.1f %%\n',pourcentage);
    end
    pourcentage_tab(J) = pourcentage;
end

figure;
plot(sigma_tab,pourcentage_tab);
ylabel ("Pourcentage de bonne classification");
xlabel("Sigma");
title("Pourcentage de bonne classification en fonction de sigma");


