%for polyfitC
function mat = jordanOL(mat);

n = size(mat, 1);
k=1;
while (k <= n)
    for j=k+1:n+1
        mat(k,j) = mat(k,j) / mat(k,k);
    end
    mat(k,k) = 1.0;
    for i=1:n
        if (i ~= k)
            for j=k+1:n+1
                mat(i,j) = mat(i,j) - mat(i,k) * mat(k,j);
            end
            mat(i,k) = 0;
        end
         
    end
    k = k+1;
end
