function output = normalizeImage(img,grayRange)

    %img : n x m x 1 

    c1 = grayRange(1);
    c2 = grayRange(2);
    m1 = min(img(:));
    m2 = max(img(:));
    m = (c2 - c1)/(m2 - m1);
    b = c1 - m*m1;
    output = repmat(m*img +b,1,1,3);

end