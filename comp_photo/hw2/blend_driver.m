function res = blend_driver(name1, name2)
if nargin < 1    
    name1 = 'japanese3.jpg';
end
if nargin < 2
    name2=  'clownface.jpg'; 
end
img1 = im2double(imread(name1));
img2 = im2double(imread(name2)); 

res = blend(img1, img2); 
imshow(res);