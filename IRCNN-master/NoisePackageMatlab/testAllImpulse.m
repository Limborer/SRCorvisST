% function testAllImpulse
% test of vaious noise estimators on Impulse noise
% Olivier LALIGANT, 2009-2013
function testAllImpulse(density)

disp('------------------------ Noise estimation ------------------------')
disp('See Ref. : ')
disp('  O. Laligant, F. Truchetet, E. Fauvet, ''Noise estimation');
disp('  from digital step-model signal'', IEEE Trans. Image Processing,');
disp('  2013 Dec., 22(12):5158:67');disp(' ');
disp('*** Salt & Pepper noise ***')

if(nargin == 1)
    if(density >=1)
        disp('!!!  Error : 0 <= density <=1  !!!');
        density = 1;
    end
else
    density = 0.2;
end


imFile = 'office.gif'
I=double(imread(imFile));
minIm = min(min(I));
maxIm = max(max(I));
I = I / maxIm;
disp('>>>>> Normalization to 1 of the image <<<<<');
comment = sprintf('Parameter of Salt & Pepper noise: density = %f\n', density);
disp(comment);

s = imnoise (I, 'salt & pepper', density);
I=double(I);

%disp('---------- Reference : MSE ----------------');
var_real_noise = mse(s-I, 2);
var_real_salt_noise = mse(thresh(s-I,0), 2);
var_real_pepper_noise = mse(thresh(I-s,0), 2);
results = sprintf('MSE(Ref.) var : %4.3f    var Salt : %4.3f     var Pepper : %4.3f\n', var_real_noise, var_real_salt_noise, var_real_pepper_noise);
disp(results)

%disp('---------- FNVE estimator ----------------');
sigmaFNVE = FNVE(s);
varianceFNVE = sigmaFNVE^2;
results = sprintf('FNVE estimator var : %4.3f\n', varianceFNVE);
disp(results)


%disp('---------- Mad estimator ----------------');
var_med = mad(s);
results = sprintf('Mad estimator var : %4.3f\n', var_med);
disp(results)


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
     fnolse(s, 'salt & pepper');
disp(comment1)
disp(comment2)
disp('---------------- summary -----------------');
disp('MSE(ref.)  FNVE    MAD   TaiYang  Average   Nolse');
results = sprintf('%4.3f     %4.3f   %4.3f   %4.3f   %4.3f     %4.3f\n', var_real_noise, varianceFNVE, var_med, varianceTai, varianceAv, v1D);
disp(results);
disp('MSE(ref.) : salt   pepper    Nolse : salt   pepper');
results = sprintf('            %4.3f  %4.3f             %4.3f  %4.3f\n', var_real_salt_noise, var_real_pepper_noise, vip, vin);
disp(results);






