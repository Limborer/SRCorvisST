% [h, xh] = histo(s, N, bord)
% h: histogram 
% xh : values
% s : signal or image
% N : nbr of beans 
% border preservation
function [h, xh] = histo(s, N, bord);
b=0;
if(N==0) N=100;
end
if(bord==0) b=0;
end

nb=0;

%b=2;
if(size(s,1) <= 2*b) 
	b1 = 0;
else
	b1 = b;
end

if(size(s,2) <= 2*b) 
	b2 = 0;
else
	b2 = b;
end

mini = min(min(s));
maxi = max(max(s));

if ((maxi-mini) == 0)
	h=1;
	xh=0;
	return;
end
	

h(N) = 0;
xh =[mini:(maxi-mini)/N:maxi-(maxi-mini)/N];
for i=b1+1:size(s,1)-b1
    for j=b2+1:size(s,2)-b2
    	indexL = 1+floor((s(i,j)-mini) * (N-1) / (maxi-mini));
        h(indexL) = h(indexL) + 1;
        nb = nb + 1;
    end
end
