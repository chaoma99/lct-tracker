function [ pos, max_response ] = do_correlation_new( patch, pos, cos_window, config, model)

% if size(im,3) > 1, im = rgb2gray(im); end

cell_size=config.features.cell_size;

% patch = get_subwindow(im, pos, window_sz);          
            
zf = fft2(get_features(patch,config,cos_window));		

kzf = gaussian_correlation(zf, model.xf, config.kernel_sigma);

response =fftshift(real(ifft2(model.alphaf .* kzf)));

max_response=max(response(:));

[vert_delta, horiz_delta] = find(response == max_response, 1); 

pos = pos + cell_size * [vert_delta - floor(size(zf,1)/2)-1, horiz_delta - floor(size(zf,2)/2)-1];                  

end

