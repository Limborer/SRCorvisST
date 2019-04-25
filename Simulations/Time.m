
% read image
I0 = (imread('resolution.tif'));

%%
%%%%%%%%%%%%%%%%%%%%%% image degradation %%%%%%%%%%%%%%%%%%%%
sf = 3; % scale factor
I0  = modcrop((I0), sf);

kernelsigma = 1.6;     % width (sigma) of the Gaussian blur kernel
k       = fspecial('gaussian', 7, kernelsigma);
blur_HR   = imfilter(I0,k,'circular'); 
LR        = downsample2(blur_HR, sf);  % downsampled

% noise parameters
noisesigma  = 0/255;   % default, no noise

randn('seed',0);
LR_noisy  = im2double(LR) + noisesigma*randn(size(LR));

% 
imshow(LR_noisy,[])

%%
%%%%%%%%%%%%%%%%%%%%%% Cubic Super Resolution %%%%%%%%%%%%%%%%%%%%
disp('========== Bicubic ============');
HR_bic     = imresize(LR_noisy,sf,'bicubic');
% HR_bic_shave = (shave((HR_bic), [sf, sf]));
imshow(HR_bic,[]);


%% Proposed
%{,
disp('========== Proposed ============');
Isigma      = 10/255; % default 0.5/255 for noise-free case. It should be larger than noisesigma, e.g., Isigma = noisesigma + 2/255;
Isigma      = max(Isigma,0.1/255);
Msigma      = 300;    % noise level of last denoiser

% default parameter setting of HQS
totalIter   = 10;
modelSigmaS = logspace(log10(100),log10(Msigma),totalIter);
ns          = min(25,max(ceil(modelSigmaS/2),1));
ns          = [ns(1)-1,ns];
lamda       = (Isigma^2)/3; % default 3, ****** from {1 2 3 4} ******

y = im2single(LR_noisy);
[rows_in,cols_in,~] = size(y);
rows      = rows_in*sf;
cols      = cols_in*sf;
[G,Gt]    = defGGt(double(k),sf);
GGt       = constructGGt(k,sf,rows,cols);
Gty       = Gt(y);
useGPU      = 0; % 1 or 0, true or false


% input (single)
input      = im2single(HR_bic);
output    = input;
if useGPU
    input = gpuArray(input);
    GGt   = gpuArray(GGt);
    Gty   = gpuArray(Gty);
end
% main loop, denoising with FFDNet
% set noise level map
global sigmas;
sigmas = Isigma;

load(fullfile('Denoiser/FFDNet/models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);

tic;
for itern = 1:totalIter
    itern
    % step 1, closed-form solution, see Chan et al. [1] for details
    rho    = lamda*255^2/(modelSigmaS(itern)^2);
    rhs    = Gty + rho*output;
    output = (rhs - Gt(real(ifft2(fft2(G(rhs))./(GGt + rho)))))/rho;

      % load denoiser
    if ns(itern+1)~=ns(itern)
       % net = loadmodel(modelSigmaS(itern),CNNdenoiser);
       % net = vl_simplenn_tidy(net);
        if useGPU
            net = vl_simplenn_move(net, 'gpu');
        end
    end
    
    % step 2, perform denoising
    res    = my_vl_simplenn(net,output,[],[],'conserveMemory',true,'mode','test');
    im     = res(end).x;
    output = im;
    
%     PSNR(itern) = aux_PSNR(double(output)*255, double(I0))
%     imshow((output),[])
%     title(['Iteration: ' num2str(itern) ', PSNR: ' num2str(aux_PSNR(double(output*255), double(I0))) ' dB']);
%     drawnow;
end

if useGPU
    output = gather(output);
end
tim_proposed = toc

% imshow(output,[])

HR_Proposed = double(output)*255;
% HR_Proposed = double(shave(HR_Proposed, [sf, sf]));
%}
%% SPMSR
%{,
tic;

disp('========== SPMSR ============');
im_gnd = modcrop(I0, sf);
im_gnd = single(im_gnd)/255;

im_l = imresize(im_gnd, 1/sf, 'bicubic');
% im_b = imresize(im_l, sf, 'bicubic');

HR_SPMSR = Interface_SPMSR(im_l, sf);% HR_SPMSR = shave(HR_SPMSR, [sf, sf]);
time_SPMSR = toc
%}

%% SRCNN
tic;
disp('========== SRCNN ============');
% set parameters
if sf == 2
    model = 'model/9-5-5(ImageNet)/x2.mat';
elseif sf ==3
    model = 'model/9-5-5(ImageNet)/x3.mat';
end

im_gnd = modcrop(I0, sf);
im_gnd = single(im_gnd)/255;

im_l = imresize(im_gnd, 1/sf, 'bicubic');
im_b = imresize(im_l, sf, 'bicubic');

HR_SRCNN = SRCNN(model, im_b);
% HR_SRCNN = shave(HR_SRCNN, [sf, sf]);

time_SRCNN = toc
%%
subplot(2,2,1); imshow(HR_SPMSR*255,[]);
subplot(2,2,2); imshow(HR_SRCNN*255,[]);
subplot(2,2,3); imshow(HR_bic,[]);
subplot(2,2,4); imshow(HR_Proposed,[]);

disp('PSNR results:');
PSNR_bic = aux_PSNR(HR_bic*255, double(I0))
PSNR_proposed = aux_PSNR(HR_Proposed, double(I0))
PSNR_SPMSR = aux_PSNR(double(HR_SPMSR*255), double(I0)) % a small shift fix
PSNR_SRCNN = aux_PSNR(double(HR_SRCNN*255), double(I0)) % a small shift fix

return



