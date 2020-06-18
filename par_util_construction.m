function [intervals par_util par_util1 weights ]=par_util_construction(A,M)

[m,n] = size(A);

%initialization
intervals = zeros(1,sum(M(:,5)));
par_util = zeros(m,sum(M(:,5)));
weights = zeros(m,sum(M(:,5)));
cut_off = zeros(1,n);
for c = 1 : n
    [sumI sumJ] = pointers(c,M(:,5));
    cut_off(c) = sumI;
    if M(c,2) == 0
        %linear interpolation for continuous
        intervals(sumI:sumJ) = M(c,3)+(((1:M(c,5))-1)/((M(c,5)-1)))*(M(c,4)-M(c,3));
    else
        %linear interpolation for discrete
        intervals(sumI:sumJ) = round(M(c,3)+(((1:M(c,5))-1)/((M(c,5)-1)))*(M(c,4)-M(c,3)));
    end
    
    for i=1:m
        
        if M(c,1)==0
            for k=(sumI+1):sumJ
                if intervals(k-1)<A(i,c) && A(i,c)<=intervals(k)
                    frag = (A(i,c)-intervals(k-1))/(intervals(k)-intervals(k-1));
                    par_util(i,k) = frag;
                    par_util(i,k-1) = 1-frag;
                end
            end
        else
            for k=(sumI+1):sumJ
                if intervals(k-1)>A(i,c) && A(i,c)>=intervals(k)
                    frag = (A(i,c)-intervals(k-1))/(intervals(k)-intervals(k-1));
                    par_util(i,k) = frag;
                    par_util(i,k-1) = 1-frag;
                end
            end
        end
    end
    for k=sumI:sumJ
        weights(:,k)=sum(par_util(:,k:sumJ),2);
    end 
end
par_util1=par_util;
par_util1(:,cut_off)=[];
weights(:,cut_off)=[];