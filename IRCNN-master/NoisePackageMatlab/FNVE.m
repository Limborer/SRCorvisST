% -- Function file: FNVE(Im)
%    Noise estimator by J. Immerker
%    J. Immerkær, 'Fast Noise Variance Estimation', Computer Vision and Image Understanding, Vol. 64, No. 2, pp. 300-302, Sep. 1996 

function sigmaFNVE = FNVE(Im)

N = [ 1 -2 1; -2 4 -2; 1 -2 1];

[H, W] = size(Im);

Ic = conv2(Im, N, 'same');
Ic = abs(Ic);
Sa = sum(sum(Ic));
cst = 6*(W-2)*(H-2)/sqrt(pi/2);

sigmaFNVE = Sa / cst;


