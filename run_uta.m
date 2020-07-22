function[] = run_uta(filename1, filename2)

delta=0.05; % parametros deksioy melous
final_sol=0; % 1 telikh 0 kai gia endiameses luseis
postopt=1; % 1 me metabeltistopoihsh 0 xwris
epsilon=0.0001; %parametros metabeltistopoihshs

[U ,model , sol, weights, xfinal] = utastar_lab(filename1,filename2,delta,epsilon,postopt,final_sol);