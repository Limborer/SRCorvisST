% -- mad(I)
%    estimator of Donoho - Haar analysis
%    I: image
%    return the result of the MAD estimator
% source: Gabriel Peyré ( www.ceremade.dauphine.fr/~peyre/ )
function esti_variance = mad(I)  

n1=max(size(I,1));
n2=max(size(I,2));
if((n1 >1) & (n2 > 1))
	I = I(2:n1-1, 2:n2-1);
end
H=I;
n=max(size(I));
% noise estimate on the first scale (Haar analysis)
if (size(I,1) ==1)
	H = (H(:,1:n-1) - H(:,2:n))/sqrt(2);
	v = median(abs(H));
elseif (size(I,2) ==1)
	H = (H(1:n-1,:) - H(2:n,:))/sqrt(2);
	v = median(abs(H));
else	
	n1=max(size(I,1));
	n2=max(size(I,2));
	H = (H(1:n1-1,:) - H(2:n1,:))/sqrt(2);
	H = (H(:,1:n2-1) - H(:,2:n2))/sqrt(2);
		
	v = median(median(abs(H)));
end%if

esti_std = v/0.6745;
esti_variance = esti_std^2;

