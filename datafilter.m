function  M = datafilter(M,A)
%check for empty/NaN values monocity
logic1 = isnan(M(:,1));
if any(logic1)
    M(logic1,1) = 0;
end
%check for empty/NaN values non/discrete
logic2 = isnan(M(:,2));
if any(logic2)
    M(logic2,2) = 0;
end

%check for empty/NaN values gworst
logic3 = isnan(M(:,3));
if any(logic3)
    logic=M(:,1)==1 & logic3;
    if any(logic)
        M(logic,3) =max(A(:,logic));
    end
    logic=M(:,1)==0 & logic3;
    if any(logic)
        M(logic,3) =min(A(:,logic));
    end
end

%check for empty/NaN values gbest
logic4 = isnan(M(:,4));
if any(logic4)
    logic=M(:,1)==1 & logic4;
    if any(logic)
        M(logic,4) = min(A(:,logic));
    end
    logic=M(:,1)==0 & logic4;
    if any(logic)
        M(logic,4) = max(A(:,logic));
    end
end

%check for empty/NaN values number of cuts
logic5 = isnan(M(:,5));
if any(logic5)
    logic=M(:,2)==1 & logic5;
    if any(logic)
        logic=(abs(M(:,3)-M(:,4)))<4;
        if any(logic)
            M(logic,5)=3;
        end
        logic=(abs(M(:,3)-M(:,4)))>=4;
        if any(logic)
            M(logic,5)=5;
        end
    end
    logic=M(:,2)==0 & logic5;
    if any(logic)
        M(logic,5)=5;
    end
end
end