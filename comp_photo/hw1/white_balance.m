function result = white_balance(rgb)
    figure(3) 
    imshow(rgb)
    title('Select white point');
    
    thresh = 0.95 * mean(max(max(rgb)));
    ok = 0;
    while not(ok)
        [x,y] = ginput(1);
        neighborhood = rgb(y-1:y+1, x-1:x+1,:)
    
         % per channel means
        Rm = mean(mean(neighborhood(:, :, 1)));
        Gm = mean(mean(neighborhood(:, :, 2)));
        Bm = mean(mean(neighborhood(:, :, 3))); 
        
        % overall mean
        m = (Rm + Gm + Bm) / 3; 
        if m < thresh
            ok = 1;
        else
            text(x,y,'too saturated');
        end
    end
    
    
    % per-channel adjustments
     Ra = 1/Rm;
     Ba = 1/Bm;
     Ga = 1/Gm;
     
     result = rgb;
     result(:, :, 1) = result(:, :, 1) * Ra; 
     result(:, :, 2) = result(:, :, 2) * Ga; 
     result(:, :, 3) = result(:, :, 3) * Ba;

      