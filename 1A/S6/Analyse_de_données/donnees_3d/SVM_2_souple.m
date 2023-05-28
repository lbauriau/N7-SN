function [X_VS, Y_VS, alpha_VS, w, c, code_retour] = SVM_2_souple(X, Y, lambda)


% On calcule la matrice de Gram
Gram = X * X';

% On résout le problème d'optimisation duale
H = diag(Y) * Gram * diag(Y);
f = -ones(size(Y));
Aeq = Y';
beq = 0;
inf = zeros(size(Y));
sup = lambda * ones(size(Y));
[alpha, ~, exitflag] = quadprog(H, f, [], [], Aeq, beq, inf, sup);

% On trouve les vecteurs de support
tolerance = 1e-6;
index = find(alpha >= tolerance & alpha < lambda-tolerance);
X_VS = X(index, :);
Y_VS = Y(index, :);
alpha_VS = alpha(index);

% On calcule le vecteur de poids w
w = sum(alpha(index) .* Y_VS .* X_VS)';

% On calcule le biais c
c = w' * X_VS(1,:)' - 1/Y_VS(1);

code_retour = exitflag;

end