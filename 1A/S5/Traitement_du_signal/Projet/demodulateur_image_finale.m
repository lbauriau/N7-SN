%% Démodulateur de l'image finale

close all;
clear all;

load fichier6.mat
pcode reconstitution_image.m

fc = 1080;
delta = 100;
f0 = fc + delta;
f1 = fc - delta;
Fe = 48e3;
Te =1/Fe;
Debit = 300;
Ns = Fe / Debit;
N = length(signal);
nb_bits = N/Ns;
Ts = 1 / Debit;
tps = (0:Te:(N-1)*Te); %temps

phi0 = rand*2*pi;
phi1 = rand*2*pi;

num0_c = cos(2*pi*f0*tps+phi0);
num0_s = sin(2*pi*f0*tps+phi0);
num1_c = cos(2*pi*f1*tps+phi1);
num1_s = sin(2*pi*f1*tps+phi1);

x_demod = signal;

x0_V21_c = x_demod.*num0_c;
x0_V21_s = x_demod.*num0_s;
x1_V21_c = x_demod.*num1_c;
x1_V21_s = x_demod.*num1_s;

x0_V21_int_c = reshape (x0_V21_c,Ns,length(x0_V21_c)/Ns);
x0_V21_int_c = (sum(x0_V21_int_c,1)/Ns).^2;
x0_V21_int_s = reshape (x0_V21_s,Ns,length(x0_V21_s)/Ns);
x0_V21_int_s = (sum(x0_V21_int_s,1)/Ns).^2;
x0_V21_int = x0_V21_int_s+x0_V21_int_c;

x1_V21_int_c = reshape (x1_V21_c,Ns,length(x1_V21_c)/Ns);
x1_V21_int_c = (sum(x1_V21_int_c,1)/Ns).^2;
x1_V21_int_s = reshape (x1_V21_s,Ns,length(x1_V21_s)/Ns);
x1_V21_int_s = (sum(x1_V21_int_s,1)/Ns).^2;
x1_V21_int = x1_V21_int_s+x1_V21_int_c;

x_V21 = x1_V21_int-x0_V21_int;
y_V21 = x_V21>0;

im_fin = reconstitution_image(y_V21);

figure(1);
imshow(uint8(im_fin));

