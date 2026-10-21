function [r,g,b] = tonemap(lambda)    

    if nargin < 1
         lambda = 0.1; 
    end
    
    count = 5;
    shutter_start = 3; 
    log_speeds = -(shutter_start : shutter_start + count);
    for i = 1:count
        names{i} = ['office2_' int2str(i) '.jpg'];
    end
    
    % weights are triangular function which peaks at 128
    x = 1:256;
    w = x;
    w2 = 256 - x;
    w(128:256) = w2(128:256);
    
    for i = 1:count
        img = imread(names{i});
        images{i, 1} = img(:, :, 1);
        images{i, 2} = img(:, :, 2); 
        images{i, 3} = img(:, :, 3);
    end

    niters = 25; 
    patch = 10;  
    dims = size(images{1,1});
    
    map{1} = []; map{2} = []; map{3} = [];
    
    Z = zeros(patch * patch, count); 
 
    for i = 1:niters 
        pos = floor(rand(1,2) .* (dims - patch-1))+1; 
        xrange = pos(1):pos(1)+patch-1;
        yrange = pos(2):pos(2)+patch-1;
        
        for c = 1:3        
            for j = 1:count;
                Z(:, j) = reshape(images{j, c}(xrange, yrange), [patch*patch 1]); 
            end
            logmap = gsolve(Z,log_speeds,lambda,w);
            if isempty(map{c}) 
                map{c} = logmap;
            else
                map{c} = map{c} + logmap; 
            end
        end
    end
    
    r = map{1} ./ niters; 
    g = map{2} ./ niters;
    b = map{3} ./ niters;
    