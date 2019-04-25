
% read image
I0 = (imread('data/Eye5.png'));

%%
%%%%%%%%%%%%%%%%%%%%%% image degradation %%%%%%%%%%%%%%%%%%%%
sf = 6; % scale factor
I0  = modcrop((I0), sf);

LR_noisy = I0;
kernelsigma = 2;     % width (sigma) of the Gaussian blur kernel
k       = fspecial('gaussian', sf*2 + 5, kernelsigma);

%%
%%%%%%%%%%%%%%%%%%%%%% Cubic Super Resolution %%%%%%%%%%%%%%%%%%%%
disp('========== Bicubic ============');
HR_bic     = imresize(LR_noisy,sf,'bicubic');
% HR_bic_shave = (shave((HR_bic), [sf, sf]));
imshow(HR_bic,[]);


%% Proposed
%{,
disp('========== Proposed ============');
Isigma      = 15/255; % default 0.5/255 for noise-free case. It should be larger than noisesigma, e.g., Isigma = noisesigma + 2/255;
Isigma      = max(Isigma,0.1/255);
Msigma      = 10;    % noise level of last denoiser

% default parameter setting of HQS
totalIter   = 10;
modelSigmaS = logspace(log10(50),log10(Msigma),totalIter);
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
useGPU      = 1; % 1 or 0, true or false


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

tic;
load(fullfile('Denoiser/FFDNet/models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);

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
    
%     imshow((output),[])
%     title(['Iteration: ' num2str(itern)]);
%     drawnow;
end

if useGPU
    output = gather(output);
end
toc;

imshow(output,[])
HR_Proposed = double(output)*255;
return
% HR_Proposed = double(shave(HR_Proposed, [sf, sf]));
%}
%% SPMSR
%{
disp('========== SPMSR ============');
im_gnd = modcrop(I0, sf);
im_gnd = single(im_gnd)/255;

im_l = imresize(im_gnd, 1/sf, 'bicubic');
% im_b = imresize(im_l, sf, 'bicubic');

HR_SPMSR = Interface_SPMSR(im_l, sf);% HR_SPMSR = shave(HR_SPMSR, [sf, sf]);
%}

%% SRCNN
disp('========== SRCNN ============');
% set parameters
if sf == 2
    model = 'model/9-5-5(ImageNet)/x2.mat';
elseif sf ==3
    model = 'model/9-5-5(ImageNet)/x3.mat';
end

HR_SRCNN = SRCNN(model, HR_bic);
% HR_SRCNN = shave(HR_SRCNN, [sf, sf]);


%%
subplot(2,2,1); imshow(abs(HR_SRCNN),[]);
subplot(2,2,2); imshow(LR_noisy,[]);
subplot(2,2,3); imshow(HR_bic,[]);
subplot(2,2,4); imshow(abs(HR_Proposed),[]);


return

%%
imshow(abs(LR_noisy),[0 255])
saveas(gcf,'results/input.eps');

imshow(abs(HR_bic),[0 255])
saveas(gcf,'results/HR_bic.eps');

imshow(abs(HR_SRCNN),[0 255])
saveas(gcf,'results/HR_SRCNN.eps');

imshow(abs(HR_Proposed),[0 255])
saveas(gcf,'results/HR_Proposed.eps');