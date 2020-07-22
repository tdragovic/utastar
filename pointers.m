function [sumI sumJ]=pointers(v,Degree)
%sti lista neighbours vriksei pou ksekinane kai pou teleiwnoun 
%oi geitones tou kathe komvou
%me vasi to Degree kathe komvou

sumJ=0;%to telos twn geitonwn tou komvou sti sumpiesmeni lista
sumI=1;%h arxi twn geitonwn tou komvou sti sumpiesmeni lista

for i=1:v
    sumJ=sumJ+Degree(i);
    if i<v
        sumI=sumI+Degree(i);
    end
end