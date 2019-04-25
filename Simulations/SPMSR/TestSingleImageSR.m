function [yh_hat] = TestSingleImageSR(ImName,ScenarioNum)
%  TestSingleImageSR - Tests the single image super-resolution scheme 
%  that was suggested in the following paper:
%  T. Peleg and M. Elad, "A statistical prediction model based on sparse 
%  representations for single image super-resolution", IEEE Trans. on 
%  Image Processing, vol. 23, no. 6, pp. 2569-2582, June 2014. 
%  Input:
%  ImName - The name of the image to be tested.
%  The image must be located at the TestImages folder 
%  ScenarioNum - The function supports three scenarios: 
%  1 - Bicubic filter, scale factor=2
%  2 - Bicubic filter, scale factor=3
%  3 - 7-by-7 Gaussian filter with std=1.6, scale factor=3
%  Output:
%  yh_hat - The output image of the suggested single image SR scheme
%  ========================================================================
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion, Haifa 32000 Israel
%  tomerfa@tx.technion.ac.il
%
%  June 2014
%  ========================================================================

ScenarioNum = 3;
ImName = 'lena';

% Set scale factor
if ScenarioNum==1
    q=2; % scale factor
elseif ScenarioNum<=3
    q=3; % scale factor
end

% Load high resolution image
if exist(['./TestImages/',ImName,'.tif'],'file')
    yh=imread(['./TestImages/',ImName,'.tif']);
elseif exist(['./TestImages/',ImName,'.png'],'file')
    yh=imread(['./TestImages/',ImName,'.png']);
elseif exist(['./TestImages/',ImName,'.gif'],'file')
    yh=imread(['./TestImages/',ImName,'.gif']);
elseif exist(['./TestImages/',ImName,'.bmp'],'file')
    yh=imread(['./TestImages/',ImName,'.bmp']);
end
if length(size(yh))==3
    yh=rgb2ycbcr(yh);
    yh=yh(:,:,1);
end
yh=double(yh);
yh=modcrop(yh,[q,q]);

% Generate low resolution image
if ScenarioNum<=2
    zl=imresize(yh,1/q,'bicubic');
elseif ScenarioNum==3
    GaussFilter=fspecial('gaussian',[7,7],1.6);
    yh_blurred=imfilter(yh,GaussFilter);
    zl=yh_blurred(1:q:end,1:q:end);
end

% Apply bicubic interpolation
yl=imresize(zl,q,'bicubic');

% Apply image reconstruction based on a statistical prediction model
yh_hat = ImagePrediction(yl,ScenarioNum); 

% Evaluate Performance
yh=shave(yh,[q,q]);
yl=max(0,min(255,yl));
yl=shave(yl,[q,q]);
PSNR_bicubic=10*log10(255.^2/mean((yl(:)-yh(:)).^2));
SSIM_bicubic=ssim(yh,yl);
fprintf('PSNR for Bicubic Interpolation: %f dB\n', PSNR_bicubic);
fprintf('SSIM for Bicubic Interpolation: %f\n', SSIM_bicubic);
yh_hat=shave(yh_hat,[q,q]);
yh_hat=max(0,min(255,yh_hat));
PSNR_prediction=10*log10(255.^2/mean((yh_hat(:)-yh(:)).^2));
SSIM_prediction=ssim(yh,yh_hat);
fprintf('PSNR for Sparse Representation Recovery: %f dB\n', PSNR_prediction);
fprintf('SSIM for Sparse Representation Recovery: %f\n', SSIM_prediction);