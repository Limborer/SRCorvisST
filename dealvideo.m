 function [HR_Proposed] = dealvideo1(video,p)
vid = VideoReader(video);
vidnum = vid.NumberOfFrame;
for i = 1:vidnum;
    img = read(vid, i);
    img = img(1:160,:);
     [I0, HR_bic, HR_Proposed] = interface(img, p);
     subplot(2,1,1); imshow(I0,[]);
     subplot(2,1,2); imshow(HR_Proposed,[]);
end
end