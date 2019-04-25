%%
clc
clear all;
p = 15;
pic_path = './pic_data';
result_path = './result';
pic_type = 'tif';

pics = dir(strcat(pic_path,'/*.',pic_type));
len = length(pics);
for i = 1:len
    img = imread(strcat(pic_path,'/',pics(i).name));
    [I0, HR_bic, HR_Proposed] = interface(img, p);
    imwrite(uint8(HR_Proposed),strcat(result_path,'/',pics(i).name));
end
