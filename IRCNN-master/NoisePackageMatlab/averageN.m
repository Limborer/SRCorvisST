% -- Function file: averageN
%   Noise estimator with the mean, by S.I. Olsen
%   S.I. Olsen, Estimation of Noise in Images: An Evaluation, CVGIP: Graphical Models and Image Processing, Volume 55, Issue 4, 1993, Pages 319-323, ISSN 1049-9652
%
% Parameters:
%   sigma = averageN((Im, p, type_average, comment)
%   Im : image
%   p : percentage of points having low gradient to take into account
%   type_average : 'lms' (Least mean square 3x3) OR 'mean' (3x3) 
%   comment
function [sigma, useful_pixels_percentage] = averageN(Im, p, type_average, comment)


[Ni, Nj] = size(Im);
avIm(1:Ni,1:Nj)=0;
gm(1:Ni,1:Nj)=0;
gx(1:Ni,1:Nj)=0;
gy(1:Ni,1:Nj)=0;
switch(type_average) 
	case {'lms'} %Least mean square 3x3
		for i = 2:Ni-1
			for j = 2:Nj-1
				subIm = Im(i-1:i+1, j-1:j+1); 
				% linear fit (plan) 3x3
				pf = fit1p2d(-1:1, -1:1, subIm);
				avIm(i,j) = pf(3); % car x=0, y=0 (centre)
				gx(i,j) = pf(1)*1 + pf(2)*0 + pf(3) - pf(3);
				gy(i,j) = pf(1)*0 + pf(2)*1 + pf(3) - pf(3);
			end
		end
	case {'mean'} % mean 3x3
		% pour voir si filtrage classique fait mieux que moindres carrés
		avIm = conv2(Im, [1 1 1; 1 1 1; 1 1 1]/9, 'same');
		gx = conv2(Im, [1 -1], 'same');
		gy = conv2(Im, [1; -1], 'same');
	otherwise
		disp('!!! Error option !!!');
		return;
end

g = sqrt(gx.*gx + gy.*gy);
[Ngi, Ngj] = size(g);

figure(1), imagesc(Im);
figure(2), imagesc(avIm);
figure(3), imagesc(g);

%histogramme des modules
[h, xh] = histo(g, 1000, 0);
figure(4), plot(xh, h);

total = Ngi * Ngj;
totalH = sum(h(1:length(h)));
if (total == totalH)
else
	total
	totalH
	disp('!!! problem algo Average !!!');
end

% accumulative histo
rdu = p * total / 100;
threshold = h(1);
for q=2:length(h)
	ch(q) = sum(h(1:q));
	if (ch(q) <= p * total / 100)
		threshold = xh(q);
	end
end
if(threshold == h(1))
    disp('Average : percentage does not permit to set the threshold');
end

taken_percentage = p;
maxiGradient = max(max(g));
thresholdGradient = threshold;

%gT = -thresh(-g, -seuil);
gB = binarise(-g, -thresholdGradient);
useful_pixels = sum(sum(gB));
useful_pixels_percentage = useful_pixels/total*100;
if (comment)
    disp('points having gradient modulus above this threshold are not taken into account');
    taken_percentage
    maxiGradient
    thresholdGradient
    total_pixels = total
    useful_pixels
    useful_pixels_percentage
end


figure(2), imagesc(gB);

% calcul bruit du bruit
diffnoise = Im-avIm;

%  moins les contours
diffnoiseSC = gB .* diffnoise;

% sans les bords
diffnoiseSC = diffnoiseSC(2:Ni-1, 2:Nj-1);	
nbB = sum(sum(gB(2:Ni-1, 2:Nj-1)));

%n2 = size(diffnoiseSC, 1) * size(diffnoiseSC, 2) *;
meannoise = sum(sum(diffnoiseSC))/nbB;
vnoise = sum(sum(diffnoiseSC.*diffnoiseSC))/nbB;%*4

sigma = sqrt(vnoise);











