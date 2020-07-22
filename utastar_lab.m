function [U , model, sol, weights, xfinal]=utastar_lab(filename1,filename2,d,epsilon,fpost,final_sol)
% utastar_lab
%      Inputs=====>
%      filename1, file *.txt of Multicriteria Matrix with ranking
%      filename2, file *.txt of description of criteria
%      d, delta of RHS for solving LP's
%      epsilon, f*+e post-optimization
%      fpost, if  1 post-optimization is TRUE else if 0 
%      final_sol, if 1 prints only final solution else if 0
%      
%      Output=====>
%      U, the utility for every alternative   
%      model, the weights of criteria
%      sol, the marginal utility points
%      weights, global utility as functinon of wij
%      xfinal, the solution of LP for the  wij
% 
% See also: linprog

%   Author: Alkaios Sakellaris 
%   Copyright 2016 Decision Support Systems Lab(ERGASYA), DPEM, TUC. 
%   $Revision: 1.1 $  $Date: 2016/04/07 02:22:22 $
warning('off','all')
[data,varnames,casenames] = tblread(filename1,'tab');
tempnm=cellstr(varnames);
Criteria_names=tempnm(1:end-1);
tempnm=cellstr(casenames);
Alternatives_names=tempnm;
A = dlmread(filename1,'\t',1,1);
M = dlmread(filename2,'\t',1,1);


%% check M for empty values



M = datafilter(M,A);
[m,n] = size(A);
n = n-1;
[B,sortindex] = sortrows(A,n+1);
[~, realsort] = sort(sortindex); 

user_ranking = B(:,n+1);

B(:,n+1) = [];
A=B;
text1=['Number of alternatives:', num2str(m)];
disp(text1)
for i=1:m
byrow=[Alternatives_names{i}];
disp(byrow);
end
disp(' ');

text1=['Number of criteria:', num2str(n)];
disp(text1)
for i=1:n
byrow=[Criteria_names{i}];
disp(byrow);
end
disp(' ');
disp('Multicriteria Matrix:');
disp(num2str(A(realsort,:)))
disp(' ');
disp('User Ranking:');
disp(user_ranking(realsort))

k=0;
j=1;
l=1;

[intervals, par_util, par_util1, weights] = par_util_construction(A,M);
if final_sol==0
disp('The intervals:')
disp(num2str(intervals))
disp(' ')
disp('Global Utility as function of marginal utilities:')
disp(num2str(round2(par_util1,0.0001)))
disp(' ')
disp('Global Utility as function of weights:')
disp(num2str(round2(weights,0.0001)))
end

errors=[-1 1 1 -1 zeros(1,m*2-(4))];
for i=1:m-1
     if user_ranking(i)~=user_ranking(i+1)
         b(j,1) = -d;
         delta(j,:)=weights(i,:)-weights(i+1,:);
         sigmas(j,:) = errors([ end-k+1:end 1:end-k ]);
         j=j+1;
     else
        beq(l,1) = 0;
        deltaeq(l,:)=weights(i,:)-weights(i+1,:);
        sigmaseq(l,:) = errors([ end-k+1:end 1:end-k ]);
        l=l+1;
     end
     
    
    k=k+2;
end
if l~=1
    deltaeq=[deltaeq ; ones(1,size(delta,2))];
    sigmaseq=[sigmaseq ; zeros(1,size(sigmas,2))];
    beq=[beq ; 1];
else
    deltaeq=ones(1,size(delta,2));
    sigmaseq=zeros(1,size(sigmas,2));
    beq=1;
end

AA=-[delta sigmas];
AAeq=[deltaeq sigmaseq];

f=[ zeros(1,size(delta,2)) ones(1,size(sigmas,2)) ];
LB=zeros(length(f),1);

disp('Solving initial LP with dual-simplex...')
disp(' ')
text2=['Delta = ', num2str(d)];
disp(text2)
disp(' ')

options = optimset('Algorithm','dual-simplex');
[x,fval,exitflag] = linprog(f',AA,b,AAeq,beq,LB,[],[],options);
xfinal=x(1:size(delta,2),:);

if exitflag==1 && final_sol==0
    disp(' ')
    text1=['Solution found with sum of error = ', num2str(fval)];
    disp(text1)
    disp(' ')
    disp('Solution of LP:')
    disp(num2str(round2(xfinal',0.0001)))
    disp(' ')
end

if fpost==1
    text1=['Starting post-optimization phase with Epsilon = ',num2str(epsilon)];
    disp(text1)
    disp(' ')
    options = optimset('Algorithm','dual-simplex','Display','none');
    AApost=[AA;f];
    bpost=[b;fval+epsilon];
    for c=1:n
    
        fpost=zeros(size(AA,2),1);
        [sumI sumJ]=pointers(c,M(:,5)-1);
        fpost(sumI:sumJ)=1;
        if final_sol==0
        text1=['Solving LP for max[u',num2str(c),'(g',num2str(c),'*)]...'];
        disp(text1)
        end
        [x,fval1,exitflag]=linprog(-fpost,AApost,bpost,AAeq,beq,LB,[],[],options);
        if exitflag==1 && final_sol==0
            disp(num2str(round2(x(1:size(delta,2))',0.0001)))
            
        end
        %[RHO,PVAL] = corr(user_ranking,-round2(weights*x(1:size(delta,2)),epsilon),'type','kendall');
        x_total(:,c)=x;
        U(:,c)=weights*x_total(1:size(delta,2),c);
    end
    xfinal=sum(x_total(1:size(delta,2),:),2)/n;
    if final_sol==0
    disp('Average:')
    disp(num2str(round2(xfinal',0.0001)))
    end
end
U=weights*xfinal;
[RHO,PVAL] = corr(user_ranking,round2(-U,0.0001),'type','kendall');

U=U(realsort);

disp(' ')
disp('Utilities:')
for i=1:m
    text1=['U[g(',Alternatives_names{i},')] = ',num2str(round2(U(i),0.0001))];
    disp(text1)
    
end
disp(' ')
text1=['Tau of Kendall = ', num2str(RHO)];
disp(text1)

final_intervals_u=[];
for i=1:n
    [sumI sumJ]=pointers(i,M(:,5)-1);
    plot_par_util=cumsum(xfinal(sumI:sumJ),1);
    plot_par_util=[0; plot_par_util];
    final_intervals_u=[final_intervals_u plot_par_util'];
    model(i)=max(plot_par_util);
    plot_par_util=plot_par_util/model(i);
    
    [sumI sumJ]=pointers(i,M(:,5));

    figure(i);
    if M(i,1)==1
        temp1=intervals(sumI:sumJ);
        temp=temp1(end:-1:1);
    else
        temp=intervals(sumI:sumJ);
    end
    
    set(gca,'XTick',1:M(i,5))
    set(gca,'YTick',0:0.2:1)
    if M(i,2)==0
       ft1=plot(intervals(sumI:sumJ), plot_par_util,'-+k','LineWidth',1.5);
    else
       ft1=plot(intervals(sumI:sumJ), plot_par_util,'--+k','LineWidth',1.5);
    end
       xlabel(Criteria_names{i})
       ylabel(['U(g_',num2str(i),')'])
       % Get the data for all the bars that were plotted
        x = get(ft1,'XData');
        y = get(ft1,'YData');
        ygap = 0.05;  % Specify vertical gap between the bar and label
        % Create labels to place over bars
        labels = cellstr(num2str(round2(plot_par_util,0.0001))); 
        for i = 2:length(x)-1 % Loop over each bar 
            xpos = x(i);        % Set x position for the text label
            if y(i)>=0.5
                ypos = y(i) -ygap;
            else
                ypos = y(i) +ygap; % Set y position, including gap
            end
            htext = text(xpos,ypos,labels{i});          % Add text label
            set(htext,'VerticalAlignment','middle','HorizontalAlignment','center','Fontweight','bold')
        end
    
    
    axis([temp(1),temp(end),0,1])
    set(gca,'XTick',temp)
    set(gca,'YTick',0:0.2:1)
   
%     axis tight
    %hold all;
    plot_par_util=[];
    title('Marginal Utilities')
    
end
sol=[intervals;final_intervals_u];

    disp(' ')
    disp('marginal utility(final solution):')
    disp(num2str(round2(sol,0.0001)))

disp(' ')
disp('Model:')
disp(' ')
disp('u(g)=')
for i=1:n
    if i==1
        text12=['       ',num2str(round2(model(i),0.0001)),'*u',num2str(i),'(g',num2str(i),')'];
        disp(text12)
    else
        text12=['      +',num2str(round2(model(i),0.0001)),'*u',num2str(i),'(g',num2str(i),')'];
        disp(text12)
    end
end
%% plot Utility
%Alternatives_names=Alternatives_names(sortindex)
specs=Alternatives_names;
figure(n+1);
ax = gca;
set(ax,'XTick',1:m)
set(ax,'YTick',0:0.2:1)
set(ax,'xticklabel',specs)
hold on;
hbar=bar(U',0.6,'FaceColor',[0/255 215/255 215/255],'EdgeColor',[0/255 102/255 102/255],'LineWidth',1);
view(90,90)
axis([0.5,m+0.5,0,1])
% Get the data for all the bars that were plotted
x = get(hbar,'XData');
y = get(hbar,'YData');
ygap = -0.05;  % Specify vertical gap between the bar and label
% Create labels to place over bars
labels = cellstr(num2str(round2(U,epsilon))); 
for i = 1:length(x) % Loop over each bar 
    xpos = x(i);        % Set x position for the text label
    ypos = y(i) +ygap; % Set y position, including gap
    htext = text(xpos,ypos,labels{i});          % Add text label
    set(htext,'VerticalAlignment','middle','HorizontalAlignment','center','Fontweight','bold')
end
title('Utility')

%% plot Weights
figure(n+2);
specs1=Criteria_names;

ax1 = gca;
set(ax1,'XTick',1:n)
set(ax1,'YTick',0:0.2:1)
set(ax1,'xticklabel',specs1)
hold on;
hbar1=bar(model,0.6,'FaceColor',[0/255 215/255 215/255],'EdgeColor',[0/255 102/255 102/255],'LineWidth',1);
%view(90,90)
axis([0.5,n+0.5,0,1])
% Get the data for all the bars that were plotted
x = get(hbar1,'XData');
y = get(hbar1,'YData');
ygap = -0.05;  % Specify vertical gap between the bar and label
% Create labels to place over bars
labels = cellstr(num2str(round2(model',0.001))); 
for i = 1:length(x) % Loop over each bar 
    xpos = x(i);% Set x position for the text label
    if y(i)<=0.07
        ypos = y(i) -ygap;
    else
        ypos = y(i) +ygap; % Set y position, including gap
    end
    htext = text(xpos,ypos,labels{i});          % Add text label
    set(htext,'VerticalAlignment','middle','HorizontalAlignment','center','Fontweight','bold')
end
title('Weights of model')
