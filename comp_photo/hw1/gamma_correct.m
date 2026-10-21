function result = gamma_correct(img) 

    gray = rgb2gray(img);
    ratio = img ./ repmat(gray, [1 1 3]);
    
    gamma = 2.2;
    newgray = ((255*gray).^(1/gamma))/255;
   
    result = repmat(newgray, [1 1 3]) .* ratio;
    
    result = (result - min(min(min(result)))) / max(max(max(result)));
