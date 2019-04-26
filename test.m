%%
clc
clear all;
p = 15;%level of image reconstruction
pic_path = './pic_data';%source image location
result_path = './result';%result image location
pic_type = 'tif';%type of picture

pics = dir(strcat(pic_path,'/*.',pic_type));
len = length(pics);
for i = 1:len
    img = imread(strcat(pic_path,'/',pics(i).name));
    [I0, HR_bic, HR_Proposed] = interface(img, p);%I0:source image,HR_Proposed:result image
    imwrite(uint8(HR_Proposed),strcat(result_path,'/',pics(i).name));
end
