
% TP1 de Statistiques : fonctions a completer et rendre sur Moodle
% Nom : BAURIAUD
% Prénom : Laura
% Groupe : 1SN-I

function varargout = fonctions_TP1_stat(nom_fonction,varargin)

    switch nom_fonction
        case 'tirages_aleatoires_uniformes'
            varargout{1} = tirages_aleatoires_uniformes(varargin{:});
        case 'estimation_Dyx_MV'
            [varargout{1},varargout{2}] = estimation_Dyx_MV(varargin{:});
        case 'estimation_Dyx_MC'
            [varargout{1},varargout{2}] = estimation_Dyx_MC(varargin{:});
        case 'estimation_Dorth_MV'
            [varargout{1},varargout{2}] = estimation_Dorth_MV(varargin{:});
        case 'estimation_Dorth_MC'
            [varargout{1},varargout{2}] = estimation_Dorth_MC(varargin{:});
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

% Fonction tirages_aleatoires (exercice_1.m) ------------------------------
function tirages_angles = tirages_aleatoires_uniformes(n_tirages)

    tirages_angles = rand(1,n_tirages)*pi-pi/2;
  
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

% Fonction estimation_Dyx_MC (exercice_2.m) -------------------------------
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

% Fonction estimation_Dorth_MV (exercice_3.m) -----------------------------
function [theta_Dorth,rho_Dorth] = ...
         estimation_Dorth_MV(x_donnees_bruitees,y_donnees_bruitees,tirages_theta)
    
    [x_G,y_G,x_donnees_bruitees_centrees,y_donnees_bruitees_centrees]=centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);
    a_x=cos(tirages_theta);
    a_y=sin(tirages_theta);
    X=a_x'*x_donnees_bruitees_centrees;
    Y=a_y'*y_donnees_bruitees_centrees;
    m=length(tirages_theta);
    M = (Y + X).^2;
    A = sum(M,2);
    [mini,indice_mini]=min(A);
    theta_Dorth=tirages_theta(indice_mini);
    rho_Dorth=x_G*cos(theta_Dorth)+y_G*sin(theta_Dorth);

end

% Fonction estimation_Dorth_MC (exercice_4.m) -----------------------------
function [theta_Dorth,rho_Dorth] = ...
                 estimation_Dorth_MC(x_donnees_bruitees,y_donnees_bruitees)

    [x_G,y_G,x_donnees_bruitees_centrees,y_donnees_bruitees_centrees]=centrage_des_donnees(x_donnees_bruitees,y_donnees_bruitees);
    C=[x_donnees_bruitees_centrees;y_donnees_bruitees_centrees]';
    Y=C'*C;
    [V,D]=eig(Y);
    D=sum(D);
    [mini,indice]=min(D);
    Y_etoile=V(:,indice);
    theta_Dorth=atan(Y_etoile(2)/Y_etoile(1));
    rho_Dorth=x_G*cos(theta_Dorth)+y_G*sin(theta_Dorth);

end
