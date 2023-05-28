function [X_VS, Y_VS, alpha_VS, c, code_retour] = SVM_3(X, Y, sigma)

% On calcule la matrice de Gram
n = size(X, 1);
K = zeros(n, n);

for i=1:n
    for j=1:n
        K(i, j) = exp(-norm(X(i, :) - X(j, :))^2 / (2 * sigma^2));
    end
end

% On résout le problème
H = diag(Y) * K * diag(Y);
f = -ones(size(Y));
Aeq = Y';
beq = 0;
inf = zeros(size(Y));
[alpha, ~, exitflag] = quadprog(H, f, [], [], Aeq, beq, inf);

% On trouve les vecteurs de support
tolerance = 1e-6;
index = find(alpha >= tolerance);
X_VS = X(index, :);
Y_VS = Y(index);
alpha_VS = alpha(index);

% On calcule le biais c
c = sum(alpha(index).* Y_VS .* K(index, index(1))) - Y_VS(1);


code_retour = exitflag;

end






