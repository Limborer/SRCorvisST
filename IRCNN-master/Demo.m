
v = VideoReader("An_Xiaolan_Left_20170920_082819.avi");
k = 1;
while hasFrame(v)
    frame = readFrame(v);
    
    
    output = process(frame);
    
    
    
    imwrite(output, ['OUTPUT_' num2str(k) '.png']);
    
    k = k+1
end

%%
v = VideoReader("An_Xiaolan_Left_20170920_082819.avi");
k = 1;
while hasFrame(v)
    frame = readFrame(v);
    
   frame = frame(1:160,:);
    
    imwrite(frame, ['INPUT/INPUT_' num2str(k) '.png']);
    
    k = k+1
end

%%
 for k=1:139
     frame = imread(['INPUT/INPUT_' num2str(k) '.png']);
     frameSR = imread(['OUTPUT/OUTPUT_t' num2str(k-1,'%04.f') '.png']);
    frameSR = aux_imscale(frameSR, [0 double(max(frame(:)))]);
    imwrite(uint8(frameSR), ['OUTPUT/OUTPUT_' num2str(k) '.png']);
 end
