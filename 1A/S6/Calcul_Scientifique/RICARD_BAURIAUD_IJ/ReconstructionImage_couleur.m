%%  Application de la SVD : compression d'images

clear all
close all
clc;

% Lecture de l'image
I = imread('BD_Asterix_Colored.jpg');
% I = rgb2gray(I);
% I1 = double(I(:,:,1));
% I2 = double(I(:,:,2));
% I3 = double(I(:,:,3));
I = double(I);

for j=1:3

    [q, p] = size(I(:,:,j));

    % Décomposition par SVD
    fprintf('Décomposition en valeurs singulières\n')
    tic
    [U, S, V] = svd(I(:,:,j));
    toc
    
    l = min(p,q);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % On choisit de ne considérer que 200 vecteurs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % vecteur pour stocker la différence entre l'image et l'image reconstuite
    inter = 1:20:(100+40);
    inter(end) = 100;
    differenceSVD = zeros(size(inter,2), 1);
    
    % images reconstruites en utilisant de 1 à 200 vecteurs (avec un pas de 40)
    ti = 0;
    td = 0;
    for k = inter
    
        % Calcul de l'image de rang k
        Im_k(:,:,j) = U(:, 1:k)*S(1:k, 1:k)*V(:, 1:k)';
    
        % Affichage de l'image reconstruite
%         ti = ti+1;
%         figure(ti)
%         image(Im_k)
        
        % Calcul de la différence entre les 2 images
        td = td + 1;
        differenceSVD(td) = sqrt(sum(sum((I(:,:,j)-Im_k(:,:,j)).^2)));
        % pause
    end
    % Figure des différences entre image réelle et image reconstruite
    ti = ti+1;
    figure(ti)
    hold on 
    plot(inter, differenceSVD, 'rx')
    ylabel('RMSE')
    xlabel('rank k')
    title('difference')
    % pause
    
    
    % Plugger les différentes méthodes : eig, puissance itérée et les 4 versions de la "subspace iteration method" 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % QUELQUES VALEURS PAR DÉFAUT DE PARAMÈTRES, 
    % VALEURS QUE VOUS POUVEZ/DEVEZ FAIRE ÉVOLUER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % tolérance
    eps = 1e-8;
    % nombre d'itérations max pour atteindre la convergence
    maxit = 500;
    
    % taille de l'espace de recherche (m)
    search_space = 200;
    
    % pourcentage que l'on se fixe
    percentage = 0.995;
    
    % p pour les versions 2 et 3 (attention p déjà utilisé comme taille)
    puiss = 1;
    
    %%%%%%%%%%%%%
    % À COMPLÉTER
    %%%%%%%%%%%%%
    
    %%
    % calcul des couples propres
    %if (p < q)
    %    M = I' * I;
    %else 
    %    M = I * I';
    % end
    tic;
    M = I(:,:,j)*I(:,:,j)';
    %[ W1, D, it, flag ] = subspace_iter_v2(M, search_space, percentage, 35, eps, maxit);
    % [W1, D] = power_v11(M);
    clear D;
    clear sort;
    [W1, D] = eig(M);
    D = diag(D);
    
    [D, sort] = sort(D, 'descend');
    W1 = W1(:, sort);
    W1 = W1(:, 1:200);
    %%
    % calcul des valeurs singulières
    Vsing = diag(sqrt(D(1:200)));
    %D = sqrt(D);
    
    %%
    % calcul de l'autre ensemble de vecteurs
    
    %W2 = zeros(p,k);
    for i = 1:200
        W2(:,i) = I(:,:,j)' * W1(:,i) / Vsing(i,i);
    end
    
    
    %%
    % calcul des meilleures approximations de rang faible
    %%
    % if (p > q)
    %     temp = W1;
    %     W2 = W1;
    %     W1 = temp;
    % end
    
    % images reconstruites en utilisant de 1 à 200 vecteurs (avec un pas de 40)
    ti = 0;
    td = 0;
    figure;
%     tiledlayout(2,3);
    for k = inter
        
        % Calcul de l'image de rang k
    
        Im_k_reconstruit(:,:,j,k) = W1(:, 1:k)*S(1:k, 1:k)*W2(:, 1:k)';
        
        % Affichage de l'image reconstruite
%         nexttile;
%         figure;
%         colormap('default')
%         imagesc(Im_k_reconstruit)
%         title('k');
        
        % Calcul de la différence entre les 2 images
        td = td + 1;
        differenceSVD(td) = sqrt(sum(sum((I(:,:,j)-Im_k_reconstruit(:,:,j,k)).^2)));
        %pause
    end
    
    % Figure des différences entre image réelle et image reconstruite
    figure;
    hold on 
    plot(inter, differenceSVD, 'rx')
    ylabel('RMSE')
    xlabel('rank k')
    title('difference')
    toc;
    % pause
end
figure;
% image(Im_k/255)
% figure;
% image(Im_k_reconstruit/255)

tiledlayout(2,3);
for k=inter(1:(end-1))
    nexttile;
    image(Im_k_reconstruit(:,:,:,k)/255);
    title("k = " + k);
end
