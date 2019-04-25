%fit with polynomial function order 1 not seéparablein  2d
% ax + by + c = f(x,y)
function p = fit1p2d(X, Y, F); % X et Y vectors, F square matrix

if length(X) ~= length(Y)
    disp('!!!! must be square !!!!')
    return;
end
N = length(X);

%terms : matrice 6lig x 7col
%double x1, y1, x2, y2, x3, y3, x4, y4;
%clear x1, y1, x2, y2, x3, y3, x4, y4;
x2=0; y2=0; x1=0; y1=0;
for i=1:N
    for j=1:N
    x2 = x2 + X(i)^2;
    y2 = y2 + Y(i)^2;
    x1 = x1 + X(i);
    y1 = y1 + Y(i);
    end
end

xy=0;cst=0; f4=0; f5=0; f6=0;
for i=1:N
    for j=1:N
        xy = xy + X(i) * Y(j);
        cst = cst + 1;
        f4 = f4 + F(i,j) * X(i);
        f5 = f5 + F(i,j) * Y(j);
        f6 = f6 + F(i,j);
    end
end

m = [  x2   xy    x1    f4;  ...
       xy   y2    y1    f5; ...
       x1   y1    cst   f6; ];

 mj = jordanOL(m);
 for i=1:3
    p(i) = mj(i, 4);
 end
 % first coeff : x or along lines (i)
 % 2nd coeff : y or along columns (j)
 % 3rd coeff : cste
 