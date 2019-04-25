% -- mse(s, b)
%    Compute MSE  
%    (no optimization)
%    Inputs:
%       -s: signal or image
%       -b: border preservation
function val = mse(s, b) 

val = 0;
nb=0;

if(size(s,1) <= 2*b) 	b1 = 0;
else	b1 = b;
end

if(size(s,2) <= 2*b) 	b2 = 0;
else	b2 = b;
end
	
for i=1+b1:size(s,1)-b1
    for j=1+b2:size(s,2)-b2
        val = val + s(i,j)^2; % ou s.*s
        nb = nb + 1;
    end
end
val = val / nb;


% vector version
% p2 = s.*s;
% 
% bi = size(s,1)-b1;
% bj = size(s,2)-b2;
% 
% if(size(s,1)==1)
% 	val = sum(p2(1, b2+1:bj)) / (bj - b2);
% elseif (size(s,2)==1)
% 	val = sum(p2(b1+1:bi, :)) / (bi - b1);
% else
% 	val = sum(p2(b1+1:bi, :));
% 	val = sum(val(1, b2+1:bj)) / (bi - b1) / (bj - b2);
% end

end%function

