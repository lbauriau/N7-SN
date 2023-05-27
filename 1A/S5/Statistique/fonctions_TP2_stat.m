
% TP2 de Statistiques : fonctions a completer et rendre sur Moodle
% Nom : Bauriaud
% Prénom : Laura
% Groupe : 1SN-I

function varargout = fonctions_TP2_stat(nom_fonction,varargin)

    switch nom_fonction
        case 'tirages_aleatoires_uniformes'
            [varargout{1},varargout{2}] = tirages_aleatoires_uniformes(varargin{:});
        case 'estimation_Dyx_MV'
            [varargout{1},varargout{2}] = estimation_Dyx_MV(varargin{:});
        case 'estimation_Dyx_MC'
            [varargout{1},varargout{2}] = estimation_Dyx_MC(varargin{:});
        case 'estimation_Dyx_MV_2droites'
            [varargout{1},varargout{2},varargout{3},varargout{4}] = estimation_Dyx_MV_2droites(varargin{:});
        case 'probabilites_classe'
            [varargout{1},varargout{2}] = probabilites_classe(varargin{:});
        case 'classification_points'
            [varargout{1},varargout{2},varargout{3},varargout{4}] = classification_points(varargin{:});
        case 'estimation_Dyx_MCP'
            [varargout{1},varargout{2}] = estimation_Dyx_MCP(varargin{:});
        case 'iteration_estimation_Dyx_EM'
            [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7},varargout{8}] = ...
            iteration_estimation_Dyx_EM(varargin{:});
    end

end

% Fonction centrage_des_donnees (exercice_1.m) ----------------------------
function [x_G, y_G, x_donnees_bruitees_centrees, y_donnees_bruitees_centrees] = ...
                centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees)
    x_G=mean(x_donnees_bruitees);
    y_G=mean(y_donnees_bruitees);
    x_donnees_bruitees_centrees= x_donnees_bruitees- x_G;
    y_donnees_bruitees_centrees= y_donnees_bruitees- y_G;

end

% Fonction tirages_aleatoires_uniformes (exercice_1.m) ------------------------
function [tirages_angles,tirages_G] = tirages_aleatoires_uniformes(n_tirages,taille)
    
    tirages_angles = rand(1,n_tirages)*pi-pi/2;

    %pour l'exercice 1
    %tirages_G = 0;

    % Tirages aleatoires de points pour se trouver sur la droite (sur [-20,20])
    tirages_G_x = rand(1,n_tirages)*2*taille-taille; % A MODIFIER DANS L'EXERCICE 2
    tirages_G_y = rand(1,n_tirages)*2*taille-taille;
    tirages_G = [tirages_G_x;tirages_G_y];

end

% Fonction estimation_Dyx_MV (exercice_1.m) -------------------------------
function [a_Dyx,b_Dyx] = ...
           estimation_Dyx_MV(x_donnees_bruitees,y_donnees_bruitees,tirages_psi)
    [x_G,y_G,x_donnees_bruitees_centrees,y_donnees_bruitees_centrees]=centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);
    a=tan(tirages_psi);
    m=length(tirages_psi);
    Y= repmat(y_donnees_bruitees_centrees,m,1);
    X=a'*x_donnees_bruitees_centrees;
    M = (Y - X).^2;
    A = sum(M,2);
    [mini,indice_mini]=min(A);
    psi_min=tirages_psi(indice_mini);
    a_Dyx=tan(psi_min);
    b_Dyx=y_G-a_Dyx*x_G;

end

% Fonction estimation_Dyx_MC (exercice_1.m) -------------------------------
function [a_Dyx,b_Dyx] = ...
                   estimation_Dyx_MC(x_donnees_bruitees,y_donnees_bruitees)
    
    un = ones(1,length(x_donnees_bruitees));
    A = [x_donnees_bruitees;un]';
    B = y_donnees_bruitees';
    A_plus=inv(A'*A)*A';
    X = A_plus*B;
    %X=A\B;
    a_Dyx=X(1);
    b_Dyx=X(2);
    

end

% Fonction estimation_Dyx_MV_2droites (exercice_2.m) -----------------------------------
function [a_Dyx_1,b_Dyx_1,a_Dyx_2,b_Dyx_2] = ... 
         estimation_Dyx_MV_2droites(x_donnees_bruitees,y_donnees_bruitees,sigma, ...
                                    tirages_G_1,tirages_psi_1,tirages_G_2,tirages_psi_2)    

    n = length(x_donnees_bruitees);
    m = length(tirages_psi_1);

    x_g_1=tirages_G_1(1,:);
    y_g_1=tirages_G_1(2,:);
    Y_1=repmat(y_donnees_bruitees,m,1);
    Y_g_1=repmat(y_g_1',1,n);
    Y_tot_1=Y_1-Y_g_1;
    X_1=repmat(x_donnees_bruitees,m,1);
    X_g_1=repmat(x_g_1',1,n);
    X_tot_1=X_1-X_g_1;
    psi_1=repmat(tirages_psi_1',1,n);
    R_1= Y_tot_1-tan(psi_1).*X_tot_1;


    x_g_2=tirages_G_2(1,:);
    y_g_2=tirages_G_2(2,:);
    Y_2=repmat(y_donnees_bruitees,m,1);
    Y_g_2=repmat(y_g_2',1,n);
    Y_tot_2=Y_2-Y_g_2;
    X_2=repmat(x_donnees_bruitees,m,1);
    X_g_2=repmat(x_g_2',1,n);
    X_tot_2=X_2-X_g_2;
    psi_2=repmat(tirages_psi_2',1,n);
    R_2= Y_tot_2-tan(psi_2).*X_tot_2;

    aux_4 =log(exp(-R_1.^2 /(2*sigma^2)) + exp(-R_2.^2/(2*sigma^2)));
    aux_5 = sum(aux_4,2);
    [~,indice] = max(aux_5);

    a_Dyx_1 = tan(tirages_psi_1(indice));
    b_Dyx_1 = y_g_1(indice) - a_Dyx_1*x_g_1(indice);

    a_Dyx_2 = tan(tirages_psi_2(indice));
    b_Dyx_2 = y_g_2(indice) - a_Dyx_2*x_g_2(indice);


end

% Fonction probabilites_classe (exercice_3.m) ------------------------------------------
function [probas_classe_1,probas_classe_2] = probabilites_classe(x_donnees_bruitees,y_donnees_bruitees,sigma,...
                                                                 a_1,b_1,proportion_1,a_2,b_2,proportion_2)
    B_1=repmat(b_1,1,length(x_donnees_bruitees));
    R_1=y_donnees_bruitees-a_1*x_donnees_bruitees-B_1;

    B_2=repmat(b_2,1,length(x_donnees_bruitees));
    R_2=y_donnees_bruitees-a_2*x_donnees_bruitees-B_2;


    probas_classe_1=proportion_1*exp(-R_1.^2/(2*sigma^2));
    probas_classe_2=proportion_2*exp(-R_2.^2/(2*sigma^2));


end

% Fonction classification_points (exercice_3.m) ----------------------------
function [x_classe_1,y_classe_1,x_classe_2,y_classe_2] = classification_points ...
              (x_donnees_bruitees,y_donnees_bruitees,probas_classe_1,probas_classe_2)

    x_classe_2=x_donnees_bruitees(probas_classe_1<probas_classe_2);
    x_classe_1=x_donnees_bruitees(probas_classe_1>=probas_classe_2);
    y_classe_2=y_donnees_bruitees(probas_classe_1<probas_classe_2);
    y_classe_1=y_donnees_bruitees(probas_classe_1>=probas_classe_2);


end

% Fonction estimation_Dyx_MCP (exercice_4.m) -------------------------------
function [a_Dyx,b_Dyx] = estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe)
    
    B = (probas_classe.*y_donnees_bruitees)';

    un = ones(1,length(x_donnees_bruitees));
    A = [x_donnees_bruitees;un]';
    A = probas_classe'.*A;

    A_plus=inv(A'*A)*A';

    X = A\B;

    a_Dyx=X(1);
    b_Dyx=X(2);
    
end

% Fonction iteration_estimation_Dyx_EM (exercice_4.m) ---------------------
function [probas_classe_1,proportion_1,a_1,b_1,probas_classe_2,proportion_2,a_2,b_2] =...
         iteration_estimation_Dyx_EM(x_donnees_bruitees,y_donnees_bruitees,sigma,...
         proportion_1,a_1,b_1,proportion_2,a_2,b_2)

    R_1 = y_donnees_bruitees- a_1*x_donnees_bruitees - b_1;
    R_2 = y_donnees_bruitees- a_2*x_donnees_bruitees - b_2;

    P_1=proportion_1.*exp(-R_1.^2./(2*sigma^2));
    P_2=(proportion_2.*exp(-R_2.^2./(2*sigma^2)));
    den = P_1+P_2;
    probas_classe_1 = P_1./den;
    probas_classe_2 = P_2./den;

    proportion_1 = mean(probas_classe_1);
    proportion_2 = mean(probas_classe_2);

    [a_1,b_1]=estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe_1);
    [a_2,b_2]=estimation_Dyx_MCP(x_donnees_bruitees,y_donnees_bruitees,probas_classe_2);

end
