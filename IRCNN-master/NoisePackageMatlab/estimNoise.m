% -- estimNoise(Im, type_noise)
%    Inputs: -Im the noisy image
%            -type_noise in { 'gaussian', 'salt & pepper', 'exponential', 'poisson', 'speckle' }
%    Ouputs: measures of noise level with various estimators 
%
%    Example : estimNoise('bureau.gif', 'gaussian')
%
%
%    @ Olivier LALIGANT, 2009-13
%
%   Ref. :
%    O. Laligant, F. Truchetet, E. Fauvet, 'Noise estimation from digital
%    step-model signal', IEEE Trans. Image Processing, 2013 Dec.,
%    22(12):5158:67
function estimNoise(Im, type_noise)

disp('------------------------ Noise estimation ------------------------')
disp('See Ref. : ')
disp('  O. Laligant, F. Truchetet, E. Fauvet, ''Noise estimation');
disp('  from digital step-model signal'', IEEE Trans. Image Processing,');
disp('  2013 Dec., 22(12):5158:67');disp(' ');

if(nargin == 2) 
else
	comment = sprintf('estimNoise(Image, ''type_noise''); \n');
	disp(comment);
	comment = sprintf(' ''type_noise'' = {''gaussian'', ''salt & pepper'', ''exponential'', ''poisson'', ''speckle''} \n');
	disp(comment);
	return;
end

% s=double(imread(Im));
s = Im;
%disp('---------- FNVE estimator ----------------');
sigmaFNVE = FNVE(s);
varianceFNVE = sigmaFNVE^2;
results = sprintf('FNVE estimator var : %4.3f\n', varianceFNVE);
disp(results)

% %disp('---------- Mad estimator ----------------');
% var_med = fmedDeriv(s);
% results = sprintf('Mad estimator var : %4.3f\n', var_med);
% disp(results)

%disp('---------- TaiYang estimator ----------------');
[sigmaTai, useful_pixels_percentage] = TaiYang(s, 10, 0);
varianceTai = sigmaTai^2;
results = sprintf('TaiYang estimator var : %4.3f   %% useful pixels : %4.2f\n', varianceTai, useful_pixels_percentage);
disp(results)

%disp('---------- Average estimator ----------------');
[sigmaAv, useful_pixels_percentage] = averageN(s, 10, 'lms', 0);
varianceAv = sigmaAv^2;
results = sprintf('Average estimator var : %4.3f   %% useful pixels : %4.2f\n', varianceAv, useful_pixels_percentage);
disp(results)

%disp('---------- Nolse estimator ----------------');
[ v2D, v1D, comment2, comment1, image_v, vip, vin] = ...
     fnolse(s, type_noise);
disp(comment1)
disp(comment2)

