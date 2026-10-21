function result = histoclip(img, lower, upper)
    if nargin < 3 
        upper = 99;
    end
    if nargin < 2
        lower = 1;
    end
    
    gray = rgb2gray(img);
    ratio = img ./ repmat(gray, [1 1 3]);
   
    bottomval = prctile(gray(:), lower);
    
    gray2 = gray -bottomval; 
    
    topval = prctile(gray2(:), upper);
    
    newgray = gray2 / topval;
    
    result = repmat(newgray, [1 1 3]) .* ratio;
    
    result(result < 0) = 0;
    result(result > 1) = 1;

%     R = img(:, :, 1); 
%     G = img(:, :, 2);
%     B = img(:, :, 3);
%     
%     Rvec = R(:);
%     Gvec = G(:);
%     Bvec = B(:);
%     
%     R_lower = prctile(Rvec, 1);
%     R_upper = prctile(Rvec, 99);
%     
%     G_lower = prctile(Gvec, 1);
%     G_upper = prctile(Gvec, 99);
%    
%     B_lower = prctile(Bvec, 1);
%     B_upper = prctile(Bvec, 99);
%    
%     result = zeros(size(img));
%     result(:, :, 1) =   (R - R_lower) / R_upper;
%     result(:, :, 2) =   (G - G_lower) / G_upper;
%     result(:, :, 3) =   (B - B_lower) / B_upper;
%     
%     result(result < 0) = 0;
%     result(result > 1) = 1;