close all;
tiledlayout(2,2)
[A, D, ~] = matgen_csad(1, 100);
nexttile
plot(D);
title("type 1");
xlabel("i");
ylabel("D(i)");
[A, D, ~] = matgen_csad(2, 100);
nexttile;
plot(D);
title("type 2");
xlabel("i");
ylabel("D(i)");
[A, D, ~] = matgen_csad(3, 100);
nexttile;
plot(D);
title("type 3");
xlabel("i");
ylabel("D(i)");
[A, D, ~] = matgen_csad(4, 100);
nexttile;
plot(D);
title("type 4");
xlabel("i");
ylabel("D(i)");