function [yh] = Interface_ImagePrediction(yl,ScenarioNum)
%  ImagePrediction - Apply image reconstruction based on a statistical prediction model
%  ====================================================================================
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion, Haifa 32000 Israel
%  tomerfa@tx.technion.ac.il
%
%  June 2014
%  ====================================================================================
[MM,NN]=size(yl);
yh=double(yl);
% Set the paramerters for the patch extraction
L=9;
k1=3;
if ScenarioNum==1
    conf.scale=2;
    conf.window=[4,4];
    [xx,yy]=meshgrid(-1:0,-1:0);
elseif ScenarioNum<=3
    conf.scale=3;
    conf.window=[3,3];
    [xx,yy]=meshgrid(-1:1,-1:1);
else
    display('This scenario is not supported')
    return;
end
II=numel(xx);
conf.border = [1 1]; % border of the image (to ignore)
conf.overlap = conf.window - [1 1]; % full overlap scheme (for better reconstruction)
n=conf.window(1)*conf.scale;
d=n^2; % patch dimension
% Set the number of levels in the prediction scheme
if ScenarioNum==1
    M=2;
elseif ScenarioNum==2
    M=4;
elseif ScenarioNum==3
    M=5;
end
hh = waitbar(0,'Applying the single image SR scheme');
for m=1:M
    ycurr=double(yh);
    yh=zeros(MM,NN);
    % Load the parameters of the prediction scheme
    if ScenarioNum<=2
        load(['Simulations/SPMSR/Params/level_params_joint_HR_LR_patches_ResFactor',num2str(conf.scale),'_NumModels',num2str(L),...
            '_NumLevels',num2str(M),'_LevelNo',num2str(m),'_Prediction_UoU_Bicubic_All.mat'])
    elseif ScenarioNum==3
        load(['Simulations/SPMSR/Params/level_params_joint_HR_LR_patches_ResFactor',num2str(conf.scale),'_NumModels',num2str(L),...
            '_NumLevels',num2str(M),'_LevelNo',num2str(m),'_Prediction_UoU_Gauss_All.mat'])
    end
    sigma1=level_params.sigma;
    AllDl=level_params.AllDl;
    AllDh=level_params.AllDh;
    AllConvXhl=level_params.AllConvXhl;
    Allbh=level_params.Allbh;
    AllWhl=level_params.AllWhl;
    % Go over all the q^2 coarse grids 
    for i=1:II
        % Extract patches from a coarse grid
        conf.origin=[xx(i),yy(i)];
        Yl=extract(conf,ycurr);
        % Remove DC from each patch 
        DCl=mean(Yl);
        Yl=Yl-repmat(DCl,d,1);
        % Cluster the patches according to a union of ortho dictionaries
        err_all=zeros(L,size(Yl,2));
        for l=1:L
            Dl=AllDl{l,i};
            R=sqrt(cumsum(sort(Dl'*Yl).^2));
            err_all(l,:)=R(end-k1,:);
        end
        [err_min,Idx4D]=min(err_all);
        Yh=zeros(d,size(Yl,2));
        % Go over all the clusters 
        for l=1:L
            % Recover each patch accorrding to its cluster's prediction model
            IdxOneModel=find(Idx4D==l);
            Dl=AllDl{l,i};
            Dh=double(AllDh{l,i});
            ConvXhl=AllConvXhl{l,i};
            bh=Allbh{l,i};
            Whl=AllWhl{l,i};
            N1=length(IdxOneModel);
            pl=size(Dl,2);
            Yl1=Yl(:,IdxOneModel);
            Xl=Dl'*Yl1;
            [Z_sorted,inds]=sort(Xl.^2);
            inds1=inds+(repmat(1:N1,pl,1)-1)*pl;
            R=sqrt(cumsum(Z_sorted));
            Sl=zeros(pl,N1);
            Sl(inds1)=2*(cumsum(R>1.15*n*sigma1)>=1)-1;
            Yh(:,IdxOneModel)=Dh*((Phi_x(Whl*Sl+repmat(bh,1,size(Sl,2)))).*(ConvXhl*Xl));
            clear Xl Z_sorted inds inds1 R Sl;
        end
        yh=yh+ReconstructFullImage(Yh+Yl+repmat(DCl,d,1),conf,size(ycurr));
        waitbar(((m-1)*II+i)/(II*M),hh)
    end
    % Image reconstruction from recovered patches by averaging on overlaps
    cnt=ones(MM,NN);
    if conf.scale==2
        cnt(2:MM-2,2:NN-2)=countcover([MM-(2*conf.scale*conf.border(1)-1),NN-(2*conf.scale*conf.border(2)-1)],...
            [conf.scale,conf.scale],[1,1]);
    elseif conf.scale==3
        cnt(3:MM-2,3:NN-2)=countcover([MM-2*(conf.scale*conf.border(1)-1),NN-2*(conf.scale*conf.border(2)-1)],...
            [conf.scale,conf.scale],[1,1]);
    end
    yh=yh./cnt;
    if conf.scale==2
        yh(1:2,:)=yl(1:2,:);
        yh(end-1:end,:)=yl(end-1:end,:);
        yh(:,1:2)=yl(:,1:2);
        yh(:,end-1:end)=yl(:,end-1:end);
    elseif conf.scale==3
        yh(1:3,:)=yl(1:3,:);
        yh(end-2:end,:)=yl(end-2:end,:);
        yh(:,1:3)=yl(:,1:3);
        yh(:,end-2:end)=yl(:,end-2:end);
    end
end
close(hh)