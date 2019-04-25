function st = binarise(s, t)

for i=1:size(s,1)
    for j=1:size(s,2)
        if (s(i,j) < t)
            st(i,j) = 0;
        else
            st(i,j) = 1;
        end
    end
end
