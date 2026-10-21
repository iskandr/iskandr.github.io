function denoise() 
einstein = im2double(imread('einstein.pgm'));
signal = einstein + randn(size(einstein)) * 0.05; 
noise = randn(size(einstein)) * 0.05; 
prior = im2double(imread('feynman.pgm'));
figure(6)
imshow(signal)
[sig_pyr, sig_idx] = buildSFpyr(signal, 3,3);
[noise_pyr, noise_idx] = buildSFpyr(noise,3,3);
[prior_pyr, prior_idx] = buildSFpyr(prior, 3,3); 

bins = -.3:0.01:.3;

newpyr = sig_pyr; 
for i = 1:5
prior_band = prior_pyr(pyrBandIndices(prior_idx, i)); 
noise_band = noise_pyr(pyrBandIndices(noise_idx, i)); 
signal_indices = pyrBandIndices(sig_idx, i); 
signal_band = newpyr(signal_indices); 

phist = hist(prior_band(:),bins) + 0.1;
%phist = phist / sum(phist); 

nhist = hist(noise_band(:),bins) + 0.0000001; 
%nhist = nhist / sum(nhist); 
estimator{i} = conv2(bins.*phist, nhist, 'same') ./conv2(phist, nhist, 'same'); 
figure(i)
plot(bins, estimator{i})
newband{i} = interp1(bins, estimator{i}, signal_band);
newpyr(signal_indices) = newband{i}; 
end
figure(8)
imshow(einstein); 
figure(9)
imshow(signal);

reconstructed = reconSFPyr(newpyr, sig_idx);
figure(10)
imshow(reconstructed);

w = wiener2(signal, [3 3], 0.05); 
figure(11)
imshow(w); 
PSNR(einstein, reconstructed)
PSNR(einstein, w)
