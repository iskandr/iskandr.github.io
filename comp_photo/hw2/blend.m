function result = blend(img1, img2, bw)

[rows1, cols1, dims1] = size(img1);
[rows2, cols2, dims2] = size(img2); 
size1 = rows1 * cols1;
size2 = rows2 * cols2;

if size1 < size2
    img2 = imresize(img2, [rows1 cols1]);
elseif size2 < size1
    img1 = imresize(img1, [rows2 cols2]); 
end    


r1=img1(:, :, 1);
g1=img1(:, :, 2); 
b1 = img1(:, :, 3); 

r2=img2(:, :, 1);
g2=img2(:, :, 2); 
b2 =img2(:, :, 3); 


%red
 [Rpyr1, Ridx1] = buildLpyr(r1);
 [Rpyr2, Ridx2] = buildLpyr(r2); 

 %green
 [Gpyr1, Gidx1] = buildLpyr(g1);
 [Gpyr2, Gidx2] = buildLpyr(g2);
 %blue
 [Bpyr1, Bidx1] = buildLpyr(b1);
 [Bpyr2, Bidx2] = buildLpyr(b2);
 
 if nargin < 3
    figure(1)
    imshow(img1);
    title('Select which area of this image to keep');
    bw = roipoly;
 end
 [maskpyr, maskidx] = buildGpyr(double(bw)); 

 newR=Rpyr1;
 newB=Gpyr1;
 newG=Bpyr1;

 for i = 1:size(Ridx1, 1) 
    mask = pyrBand(maskpyr, maskidx, i);
    mask = mask - min(min(mask)); 
    mask = mask / max(max(mask)); 

    Rband1 = pyrBand(Rpyr1, Ridx1, i);
    Rband2 = pyrBand(Rpyr2, Ridx2, i); 
    Gband1 = pyrBand(Gpyr1, Gidx1, i);
    Gband2 = pyrBand(Gpyr2, Gidx2, i);
    Bband1 = pyrBand(Bpyr1, Bidx1, i);
    Bband2 = pyrBand(Bpyr2, Bidx2, i);
    
    Rcombo = Rband1 .* mask + Rband2 .* (1 - mask); 
    newR = setPyrBand(newR, Ridx1, Rcombo, i);
 
    Gcombo = Gband1 .* mask + Gband2 .* (1 - mask); 
    newG = setPyrBand(newG, Gidx1, Gcombo, i);
    
    Bcombo = Bband1 .* mask + Bband2 .* (1 - mask); 
    newB = setPyrBand(newB, Bidx1, Bcombo, i);
 end

 Rfinal = reconLpyr(newR, Ridx1);
 Gfinal = reconLpyr(newG, Gidx1);
 Bfinal = reconLpyr(newB, Bidx1);
 
 result = cat(3, Rfinal, Gfinal, Bfinal); 