
SingleImageSR_TIP14_Box README
June 30, 2014


SingleImageSR_TIP14_box quick start:
------------------------------------

1. Unpack the contents of the compressed file to a new directory, named e.g. "SingleImageSR_TIP14_Box ".
2. Copy an image to the folder "TestImages" or use one of the images that already exist there.
2. Enter "TestSingleImageSR(ImName,ScenarioNum)" at the Matlab command prompt with two inputs:
   ImName - a string consisting of the name of the test image
   ScenarioNum - 1 for a bicubic filter and scale factor=2, 
                 2 for a bicubic filter and scale factor=3,
                 3 for a 7-by-7 Gaussian filter with std=1.6 and scale factor=3
   For example: TestSingleImageSR('lena',1)
3. For a complete list of functions in the package, enter
   >> help SingleImageSR_TIP14_Box
   This assumes the package was installed to a directory named "SingleImageSR_TIP14_Box".
   If not, replace SingleImageSR_TIP14_Box in the above with the (unqualified) name of the SingleImageSR_TIP14_Box 
   installation directory.