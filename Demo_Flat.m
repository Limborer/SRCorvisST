
addpath(genpath('FFDNet-master 2'));
useGPU      = 1; % 1 or 0, true or false

% read image
I0 = imread('resolution.tif');

%%
%%%%%%%%%%%%%%%%%%%%%% image degradation %%%%%%%%%%%%%%%%%%%%
sf = 3; % scale factor
% blur kernel k, not limited to Gaussian blur
kernelsigma = 2;     % width (sigma) of the Gaussian blur kernel
% from [0.6 2.4], e.g., sf = 2, kernelsigma = 1; sf = 3, kernelsigma = 1.6; sf = 4, kernelsigma = 2;
k       = fspecial('gaussian', 7, kernelsigma);
noisesigma  = 0/255;   % default, no noise
Isigma      = 0.5/255; % default 0.5/255 for noise-free case. It should be larger than noisesigma, e.g., Isigma = noisesigma + 2/255;
Isigma      = max(Isigma,0.1/255);
Msigma      = 20;    % noise level of last denoiser
% default parameter setting of HQS
totalIter   = 5;
%modelSigmaS = logspace(log10(12*sf),log10(Msigma),totalIter);
modelSigmaS = logspace(log10(50),log10(Msigma),totalIter);
ns          = min(25,max(ceil(modelSigmaS/2),1));
ns          = [ns(1)-1,ns];
lamda       = (Isigma^2)/3; % default 3, ****** from {1 2 3 4} ******

I0  = modcrop(I0, sf);
% LR (uint8), get the LR image
blur_HR   = imfilter(I0,k,'circular'); % blurred
LR        = downsample2(blur_HR, sf);  % downsampled
randn('seed',0);
LR_noisy  = im2double(LR) + noisesigma*randn(size(LR));

% imshow(LR_noisy,[])

% set noise level map
global sigmas;
sigmas = Isigma;

%%
%%%%%%%%%%%%%%%%%%%%%% super resolution %%%%%%%%%%%%%%%%%%%%
HR_bic     = imresize(LR_noisy,sf,'bicubic');
imshow(HR_bic,[])

%% prapare for step 1
y = im2single(LR_noisy);
[rows_in,cols_in,~] = size(y);
rows      = rows_in*sf;
cols      = cols_in*sf;
[G,Gt]    = defGGt(double(k),sf);
GGt       = constructGGt(k,sf,rows,cols);

Gty       = Gt(y);


% input (single)
input      = im2single(HR_bic);
output    = input;
if useGPU
    input = gpuArray(input);
    GGt   = gpuArray(GGt);
    Gty   = gpuArray(Gty);
end

%% main loop
tic;
load(fullfile('/Simulations/Denoiser/FFDNet/models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);

if useGPU
    net = vl_simplenn_move(net, 'gpu') ;
    output = gpuArray(output);
end

for itern = 1:totalIter
    itern
    % step 1, closed-form solution, see Chan et al. [1] for details
    rho    = lamda*255^2/(modelSigmaS(itern)^2);
    rhs    = Gty + rho*output;
    output = (rhs - Gt(real(ifft2(fft2(G(rhs))./(GGt + rho)))))/rho;
    

    % step 2, perform denoising
    %{,
    res    = my_vl_simplenn(net,output,[],[],'conserveMemory',true,'mode','test');
    im     = res(end).x;
    output = im;
    %}
    
%     output = bm3d(output, 0.1);
    
    imshow((output),[])
    title(itern);
    drawnow;
end

if useGPU
    output = gather(output);
end
toc;

%%
subplot(2,2,1); imshow(double(I0),[]);
subplot(2,2,2); imshow(LR_noisy,[]);
subplot(2,2,3); imshow(HR_bic,[]);
subplot(2,2,4); imshow(output,[]);
return
if showResult
    imshow(cat(2,input,output));
    drawnow;
    pause(pauseTime)
    imwrite(output,fullfile(folderResultCur,[Iname,'_ircnn_x',num2str(sf),'.png']));
end


