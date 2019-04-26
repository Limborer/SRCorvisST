# SRCorvisST
## Requirements
* MATLAB R2015b or newer
* MatConvNet 1.0-beta25（You can get more details about MatConvNet at http://www.vlfeat.org/matconvnet/.）
## Demo for SRCorvisST: "test.m"
There is a sample image in the folder `pic_path`. You can find the resulting image in the folder `result_path` after running test.m.
### or
You can modify `p`,`pic_path`,`result_path`,`pic_type` in `test.m` to adjust `level of image reconstruction`,`source image location`,`result image location`,`type of picture`.
```matlab
p = 15;
pic_path = './pic_data';
result_path = './result';
pic_type = 'tif';
```
