clear all;
close all;
clc;

% read data

args = argv();
 filename1 = args{1};
 filename2 = args{2};

% filename1 = 'data/test.txt';
% filename2 = 'data/metatest.txt';

% filename1 = 'data/test_siskos_10x6.txt';
% filename2 = 'data/metatest_siskos_10x6.txt';

delta=0.05; % parametros deksioy melous
final_sol=0; % 1 telikh 0 kai gia endiameses luseis
postopt=1; % 1 me metabeltistopoihsh 0 xwris
epsilon=0.0001; %parametros metabeltistopoihshs

[U ,model , sol, weights, xfinal] = utastar_lab(filename1,filename2,delta,epsilon,postopt,final_sol);

