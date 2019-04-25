
function output = process(LR)
useGPU      = 0; % 1 or 0, true or false
%% read LR image
c     = size(LR,3);

%% parameter setting in HQS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Important!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sf          = 3;      % scale factor {2,3,4,...}
Isigma      = 0.2442/7;%16/255; % default 1/255 for noise-free case. It should be larger than true noise level.
Isigma      = max(Isigma, 0.1/255);
Msigma      = 3;      % {1,3,5,7,9, ..., 15, ...}

% set noise level map
global sigmas;
sigmas = Isigma;


% % folder to store results
% folderResultCur = fullfile(folderResult, ['SISR_direct_downsample_',setTestCur,'_x',num2str(sf)]);
% if ~exist(folderResultCur,'file')
%     mkdir(folderResultCur);
% end

%% set blur kernel
% blur kernel k, not limited to Gaussian blur
% case 1
% if exist(fullfile(folderTestCur,[Iname,'_kernel.png']),'file')
%     k     = imread(fullfile(folderTestCur,[Iname,'_kernel.png']));
%     if size(k,3)==3
%         k = rgb2gray(k);
%     end
%     k    = im2single(k);
%     k    = k./(sum(k(:)));
% else
    % case 2
    kernelsigma = (sf-1)*0.8; % width (sigma) of the Gaussian blur kernel from [0.6 2.4], e.g., sf = 2, kernelsigma = 1; sf = 3, kernelsigma = 1.6; sf = 4, kernelsigma = 2;
    % k       = fspecial('gaussian',5,kernelsigma);
    k       = fspecial('gaussian',sf*2 + 5,kernelsigma);  % should be odd number.
%         k       = fspecial('gaussian',31,kernelsigma);
% end


%% default parameter setting in HQS
totalIter   = 10;
modelSigma1 = 50; % default 49
modelSigmaS = logspace(log10(modelSigma1),log10(Msigma),totalIter);
ns          = min(25,max(ceil(modelSigmaS/2),1));
ns          = [ns(1)-1,ns];
lamda       = (Isigma^2)/3; % default 3, ****** from {1 2 3 4} ******

folderModel = 'models';
% load denoisers
if c==1
    load(fullfile(folderModel,'modelgray.mat'));
elseif c==3
    load(fullfile(folderModel,'modelcolor.mat'));
end


HR_bic     = imresize(LR,sf,'bicubic');
[a1,b1,~]  =  size(HR_bic);
% input (single)
input      = im2single(HR_bic);


%% edgetaper to better handle circular boundary conditions
% if use_edgetaper
    ks = sf*ceil(floor((size(k) - 1)/2)/sf);
    input = padarray(input, ks, 'replicate', 'both');
    for a=1:4
        input = edgetaper(input, k);
    end
    LR_edge      = downsample2(input, sf);  % downsampled
    LR = center_replace(LR_edge,im2single(LR));
% end

%% prapare for step 1
y = im2single(LR);
[rows_in,cols_in,~] = size(y);
rows      = rows_in*sf;
cols      = cols_in*sf;
[G,Gt]    = defGGt(double(k),sf);
GGt       = constructGGt(k,sf,rows,cols);
if c == 3
    GGt   = cat(3,GGt,GGt,GGt); % R,G,B channels
end
Gty       = Gt(y);

if useGPU
    input = gpuArray(input);
    GGt   = gpuArray(GGt);
    Gty   = gpuArray(Gty);
end

output    = (input);


%% main loop
tic;
load(fullfile('FFDNet-master 2/models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);


for itern = 1:totalIter
    itern
%     output = log(output);
    % step 1, closed-form solution, see Chan et al. [1] for details
    rho    = lamda*255^2/(modelSigmaS(itern)^2);
    rhs    = Gty + rho*output;
    output = (rhs - Gt(real(ifft2(fft2(G(rhs))./(GGt + rho)))))/rho;
    
    % load denoiser
    %     if ns(itern+1)~=ns(itern)
    %         net = loadmodel(modelSigmaS(itern),CNNdenoiser);
    %         net = vl_simplenn_tidy(net);
    %         if useGPU
    %             net = vl_simplenn_move(net, 'gpu');
    %         end
    %     end
    
    % step 2, perform denoising
    %     res    = vl_simplenn(net, output,[],[],'conserveMemory',true,'mode','test');
    res    = my_vl_simplenn(net,output,[],[],'conserveMemory',true,'mode','test');
    im     = res(end).x;
    output = im;
%    output = exp(output);
    imshow((output),[])
    title(itern);
    drawnow;
    %     pause(1)
end



if useGPU
    output = gather(output);
end
toc;

% if use_edgetaper
    input  = center_crop(input,a1,b1);
    output = center_crop(output,a1,b1);
% end


%%
% return
output = aux_imscale(output, [0 1]);
LR = LR(1:160,:);
output = output(1:160*sf,:);
% subplot(2,1,1); imshow(LR,[]); subplot(2,1,2);
% imshow((output),[]);
% colormap('hot');
return
if showResult
    imshow(cat(2,input,output));
    drawnow;
    pause(pauseTime)
    imwrite(output,fullfile(folderResultCur,[Iname,'_ircnn_x',num2str(sf),'.png']));
end






