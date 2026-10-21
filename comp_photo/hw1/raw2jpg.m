function result = raw2jpg(name)
    % read in RAW file
    raw = im2double(imread(name));
    
    %demosaic into R,G,B channels using interpolation
    rgb = demosaic(raw);
    save('rgb.mat', 'rgb');
    
    %median filter
    rgb_med = zeros(size(rgb));
    for i = 1:3
        rgb_med(:, :, i) = medfilt2(rgb(:, :, i));
    end
    save('rgb_med.mat', 'rgb_med');
    
    
    
   %white balance
    rgb_white = white_balance(rgb_med);
    save('rgb_white.mat', 'rgb_white');

    rgb_gamma = gamma_correct(rgb_white);
    save('rgb_gamma.mat', 'rgb_gamma');
    
    
    %stretch range to fill histogram
     result = histoclip(rgb_gamma, 2, 99);
     
     save('rgb_final.mat', 'result');
     
     imwrite(result, 'final.jpg');

     