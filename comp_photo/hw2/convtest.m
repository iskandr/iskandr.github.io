imsize = 1024; 
img  = rand(imsize);
start_filter = 3; 
end_filter = 35; 
n = end_filter - start_filter + 1; 
spatial_times = zeros(1, n);
freq_times = zeros(1,n); 
K = start_filter:end_filter;

for k = K
%intialize convolution kernels
    %filter = fspecial('gaussian', 3*k, k);
    filter = rand(k); 
    
%convolution in spatial domain
    tic
    spatial_result = conv2(img, filter, 'same');
    spatial_times(1,k-start_filter+1) = toc;

%convolution in time domain
    tic        
    img_fft = fft2(img);
    filter_fft = fft2(filter, imsize, imsize);
    freq_result = real(ifft2(img_fft .* filter_fft));
    
    freq_times(1,k-start_filter+1) = toc;
%     
%     disp(['iteration: ' int2str(k)]);
% 
%     diff = sqrt(sum(sum( (freq_result - spatial_result).^2)));
%     disp(['difference in results: ' num2str(diff)]);
end


plot(K, spatial_times, K, freq_times);

title('Kernel size vs. convolution performance');
legend('conv2', 'fft2');
