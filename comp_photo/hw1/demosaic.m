function result = demosaic(img) 
    [rows, cols] = size(img);
    
    xi = meshgrid(1:cols, 1:rows);
    yi = meshgrid(1:rows, 1:cols)';
    
    rmask = logical(repmat([1 0; 0 0], rows/2, cols/2));
    g1mask = logical(repmat([0 1; 0 0], rows/2, cols/2));     
    g2mask = logical(repmat([0 0; 1 0], rows/2, cols/2));     
    bmask = logical(repmat([0 0; 0 1], rows/2, cols/2));
    
    rRaw = reshape(img(rmask), rows/2, cols/2);
    g1Raw = reshape(img(g1mask), rows/2, cols/2);
    g2Raw = reshape(img(g2mask), rows/2, cols/2); 
    bRaw = reshape(img(bmask), rows/2, cols/2); 

    x = meshgrid(1:2:cols, 1:(rows/2));
    y = meshgrid(1:2:rows, 1:(cols/2))';
    rInterp = interp2(x,y,rRaw,xi, yi, 'bicubic'); 

    x = meshgrid(2:2:cols, 1:(rows/2));
    y = meshgrid(1:2:rows, 1:(cols/2))';
    g1Interp = interp2(x,y,g1Raw,xi, yi, 'bicubic');
    
    x = meshgrid(1:2:cols, 1:(rows/2));
    y = meshgrid(2:2:rows, 1:(cols/2))';
    g2Interp = interp2(x,y,g2Raw,xi, yi, 'bicubic');
    
    x = meshgrid(2:2:cols, 1:(rows/2));
    y = meshgrid(2:2:rows, 1:(cols/2))';
    bInterp = interp2(x,y,bRaw,xi, yi, 'bicubic'); 

    result = cat(3, rInterp, (g1Interp + g2Interp) / 2,  bInterp);
    
    %drop NaN borders
    result = result(2:end-1, 2:end-1, :);