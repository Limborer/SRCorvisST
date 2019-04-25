% -- Function file: TaiYang(Im, p, comment)
%    Noise estimator by S.C. Tai, S.M. Yang
%    Shen-Chuan Tai, Shih-Ming Yang, 'A fast method for image noise estimation using Laplacian operator and
%    adaptive edge detection',  Communications, Control and Signal Processing, 2008. ISCCSP 2008
%
% Parameters:
%   sigma = TaiYang(Im, p, comment)
%   Im : image
%   p : percentage of points having low gradient to take into account
%   comment
function [sigma, useful_pixels_percentage] = TaiYang(Im, p, comment)

[H, W] = size(Im);

% Sobel edge detection
hx = [-1 -2 -1; 0 0 0; 1 2 1];
hy = [-1 0 1; -2 0 2; -1 0 1];
gx = conv2(Im, hx, 'same');
gy = conv2(Im, hy, 'same');

g = abs(gx) + abs(gy);

%histogram
[h, xh] = histo(g, 1000, 0);


total = H * W;
if (total == sum(h(1:length(h))))
else
	disp('!!! problem with parameter -- TaiYang method !!!');
end
% accumulative histogram
threshold = h(1);
for q=2:length(h)
	ch(q) = sum(h(1:q));
	if (ch(q) <= p * total / 100)
		threshold = xh(q);
	end
end
if(threshold == h(1))
    disp('TaiYang : percentage dost not permit to set the threshold');
end
taken_percentage = p;
maxiGradient = max(max(g));
thresholdGradient = threshold;
	
gB = binarise(-g, -thresholdGradient);
figure(2), imagesc(gB);
total_pixels = W*H;
useful_pixels = sum(sum(gB));
useful_pixels_percentage = useful_pixels/total_pixels*100;

if (comment)
    disp('points having gradient modulus above this threshold are not taken into account');
    taken_percentage
    maxiGradient
    thresholdGradient
    total_pixels
    useful_pixels
    useful_pixels_percentage
end


% FNVE adapted
N = [ 1 -2 1; -2 4 -2; 1 -2 1];
Ic = conv2(Im, N, 'same');
Ic = gB .* Ic;

IcNE = abs(Ic(2:H-1, 2:W-1));
Sa = sum(sum(IcNE));
nbB = sum(sum(gB(2:H-1, 2:W-1)));
cst = 6*nbB/sqrt(pi/2);
%cst = 6*(W-2)*(H-2)/sqrt(pi/2);

sigma = Sa / cst;

