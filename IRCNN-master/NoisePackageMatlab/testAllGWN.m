% function testAllGWNG
% test of vaious noise estimatorsd on GWN
% Olivier LALIGANT, 2009-2013
function testAllGWN(variance)

disp('------------------------ Noise estimation ------------------------')
disp('See Ref. : ')
disp('  O. Laligant, F. Truchetet, E. Fauvet, ''Noise estimation');
disp('  from digital step-model signal'', IEEE Trans. Image Processing,');
disp('  2013 Dec., 22(12):5158:67');disp(' ');
disp('*** Gaussian noise ***')

if(nargin == 1) 
else
    variance = 0.5;
end

imFile = 'house_col_256.bmp'
I=double(imread(imFile));
%Im=I(1:128,1:128);
disp('>>>>> normalization to 1 of the image <<<<<');
I = I / max(max(I));

if( exist('normrnd') )
    s = normrnd(0,sqrt(variance), size(I));
else
    if(variance > 0.02) % for MATLAB
        comment = sprintf('!!! data range in [0;1], reduce the variance (max: 0.02)');
        disp(comment);return; 
    end
    s = imnoise(I, 'gaussian', 0, variance) - a;
end
comment = sprintf('Parameter of the GWnoise added: variance = %f\n', variance);
disp(comment);
s = I+s;


%disp('---------- Reference : MSE ----------------');
var_real_noise = mse(s-I, 2);
results = sprintf('MSE(Ref.) var : %4.3f   \n', var_real_noise);
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
     fnolse(s, 'gaussian');
disp(comment1)
disp(comment2)
disp('---------------- summary -----------------');
disp('MSE(ref.)  FNVE     MAD      TaiYang    Average     Nolse');
results = sprintf('%4.2f       %4.2f     %4.2f     %4.2f       %4.2f        %4.2f\n', var_real_noise, varianceFNVE, var_med, varianceTai, varianceAv, v2D);
disp(results);

