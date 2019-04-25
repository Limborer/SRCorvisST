% -- readme  
%
%    NOISE ESTIMATION distribution
%    
%    This a companion distribution of the paper:
%
%    O. Laligant, F. Truchetet, E. Fauvet, 'Noise estimation from digital
%    step-model signal', IEEE Trans. Image Processing, 2013 Dec.,
%    22(12):5158:67
%
%    This distribution permits to:
%    - introduce a new noise estimator (NOLSE) with interesting
%    performances on various types of noise
%    - test various noise estimators on real images corrupted by various synthetic noises
%    - estimate noise level in image with various noise estimators
%
%    Estimators:
%    - nolse.m, fnolse.m like-script and function versions of the new
%    estimator NOLSE
%    - averageN.m noise estimation by S.I. Olsen (see help)
%    - FNVE.m noise estimation by J. Immerkær
%    - mad.m noise estimation by D. L. Donoho
%    - TaiYang.m J. noise estimation by S.C. Tai and S.M. Yang
%
%    Main:
%    - testAllGWN.m : test of the estimators on an image corrupted by synthetic GWN 
%    - testAllSpeckle.m : test of the estimators on an image corrupted by speckle noise 
%    - testAllPoisson.m : test of the estimators on an image corrupted by Poisson noise 
%    - testAllImpulse.m : test of the estimators on an image corrupted by impulse noise
%    - estimNoise.m : estimation of the noise level in an image with various
%    estimators
%
%    Tools:
%    - binarise.m provides a binary image
%    - fit1p2d.m polynomial fitting
%    - histo.m histogram (variant)
%    - jordanOL.m jordan resolution (variant)
%    - mse.m mean square deviation calculus
%    - thresh.m low thresholding
%
disp('type ''help readme''');











