
v = VideoReader("An_Xiaolan_Left_20170920_082819.avi");
k = 1;
thickness = [];
thicknessSR = [];

while hasFrame(v)
    frame = readFrame(v);
    frame = frame(1:160,:);
    
    col = 288;
    profile = frame(:,col);
    threshold = 22;
    thresholdSR = 9;
    
    % super-resolution
    frameSR = imread(['OUTPUT_' num2str(k) '.png']);
    frameSR = aux_imscale(frameSR, [0 double(max(frame(:)))]);
    profileSR = frameSR(:, col*3);
    
    
    subplot(3,2,1); plot(profile);  xlim([0,139]);ylim([0,120]);
    hold on; plot(ones(160)*threshold); 
    hold off;title('Intensity Profile (LR)');
    
    subplot(3,2,2); plot(profileSR); xlim([0,139*3]);ylim([0,120]);
    hold on; plot(ones(160*3)*thresholdSR); 
    hold off;title('Intensity Profile (HR)');
    
    A = mean(profile(1:160,:),2); A(A<threshold)=[];
    ASR = mean(profileSR(1:160*3,:),2); ASR(ASR<thresholdSR)=[];
    
    subplot(3,2,3); plot(A); title('Thresholded (LR)'); 
    xlim([0,50]);ylim([threshold,120]);
    subplot(3,2,4); plot(ASR); title('Thresholded (HR)');
    xlim([0,50*3]);ylim([thresholdSR,120]);
    
    thickness(k) = length(A); thicknessSR(k) = length(ASR);
    subplot(3,2,5); plot(thickness); title('Thickness (LR)'); 
    xlim([0,139]);ylim([20,40]); grid minor;
    hold on; plot(ones(41)*29, [0:40]); 
    plot(ones(41)*96, [0:40]);
    hold off;
    
    subplot(3,2,6); plot(thicknessSR/3); title('Thickness (HR)'); 
    xlim([0,139]);ylim([20,40]); grid minor;
    hold on; plot(ones(41)*29, [0:40]); 
    plot(ones(41)*96, [0:40]);
    hold off;
    
    drawnow;
    
    saveas(gcf,['screen_' num2str(k) '.png']);
    k = k+1
end