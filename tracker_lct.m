function [positions, time] = tracker_lct(video_path, img_files, pos, target_sz, config, show_visualization)
%
%   It is meant to be called by the interface function RUN_TRACKER, which
%   sets up the parameters and loads the video information.
  
	%if the target is large, lower the resolution, we don't need that much
	%detail

	resize_image = (sqrt(prod(target_sz)) >= 100);  %diagonal size >= threshold
    if resize_image,
        pos = floor(pos / 2);
        target_sz = floor(target_sz / 2);
    end

    im_sz=size(imread([video_path img_files{1}]));
    [window_sz, app_sz]=search_window(target_sz,im_sz, config);
    config.window_sz=window_sz;
    config.app_sz=app_sz;
    
    config.detc=det_config(target_sz, im_sz);
    
    cell_size=config.features.cell_size;
    interp_factor=config.interp_factor;
    
	output_sigma = sqrt(prod(target_sz)) * config.output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
    
	%store pre-computed cosine window
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
	
    app_yf=fft2(gaussian_shaped_labels(output_sigma, floor(app_sz / cell_size)));
    
    if show_visualization,  %create video interface
        update_visualization = show_video(img_files, video_path, resize_image);
    end	

	time = 0;  %to calculate FPS
	positions = zeros(numel(img_files), 2);  %to calculate precision
    
    svm_struct=[];
    
    
    nScales=33;
    scale_sigma_factor=1/4;
    scale_sigma = nScales/sqrt(33) * scale_sigma_factor;
    ss = (1:nScales) - ceil(nScales/2);
    ys = exp(-0.5 * (ss.^2) / scale_sigma^2);
    ysf = single(fft(ys));
    
    scale_step = 1.02;
    ss = 1:nScales;
    scaleFactors = scale_step.^(ceil(nScales/2) - ss);
    currentScaleFactor = 1;
    
    if mod(nScales,2) == 0
        scale_window = single(hann(nScales+1));
        scale_window = scale_window(2:end);
    else
        scale_window = single(hann(nScales));
    end;
    
    scale_model_max_area = 512;
    scale_model_factor = 1;
    if prod(app_sz) > scale_model_max_area
        scale_model_factor = sqrt(scale_model_max_area/prod(app_sz));
    end
    scale_model_sz = floor(app_sz * scale_model_factor);
    lambda=0.01;
    
    
    min_scale_factor = scale_step ^ ceil(log(max(5 ./ window_sz)) / log(scale_step));
    max_scale_factor = scale_step ^ floor(log(min(im_sz(1:2)./ target_sz)) / log(scale_step));
    
%     min_scale_factor = scale_step ^ ceil(log(max(5 ./ sz)) / log(scale_step));
%     max_scale_factor = scale_step ^ floor(log(min([size(im,1) size(im,2)] ./ base_target_sz)) / log(scale_step));
    
	for frame = 1:numel(img_files),
		%load image
		im = imread([video_path img_files{frame}]);
		
        if size(im,3) > 1, 
            im_gray = rgb2gray(im); 
        else
            im_gray=im;
        end
        
		if resize_image 
            im=imresize(im, 0.5);
            im_gray = imresize(im_gray, 0.5); 
        end
      
		tic()

        if frame > 1,

            %obtain a subwindow for detection at the position from last
            %frame, and convert to Fourier domain (its size is unchanged)			
            [pos, ~]=do_correlation(im_gray, pos, window_sz, cos_window, config, motion_model);
            [~, max_response]=do_correlation(im_gray, pos, app_sz, [], config, app_model);
            
            config.max_response=max_response;
            
            if max_response<config.motion_thresh,  
                [pos, max_response]=refine_pos_rf(im, pos, svm_struct, app_model, config);           
            end
            
            
            % extract the test sample feature map for the scale filter
            xs = get_scale_sample(im_gray, pos, app_sz, scaleFactors*currentScaleFactor, scale_window, scale_model_sz);

            % calculate the correlation response of the scale filter
            xsf = fft(xs,[],2);
            scale_response = real(ifft(sum(sf_num .* xsf, 1) ./ (sf_den + lambda)));

            % find the maximum scale response
            recovered_scale = find(scale_response == max(scale_response(:)), 1);

            % update the scale
            currentScaleFactor = currentScaleFactor*scaleFactors(recovered_scale);
            if currentScaleFactor < min_scale_factor
                currentScaleFactor = min_scale_factor;
            elseif currentScaleFactor > max_scale_factor
                currentScaleFactor = max_scale_factor;
            end
            

        end       

        %Kernel Ridge Regression, calculate alphas (in Fourier domain)
        % for motion model (introspection model) and appearance model
		patch = get_subwindow(im_gray, pos, window_sz);
		xf = fft2(get_features(patch, config, cos_window));
		kf = gaussian_correlation(xf, xf, config.kernel_sigma);
		alphaf = yf ./ (kf + config.lambda);   %equation for fast training

        patch=get_subwindow(im_gray,pos,app_sz);
        app_xf=fft2(get_features(patch, config, []));
        app_kf = gaussian_correlation(app_xf, app_xf, config.kernel_sigma);
		app_alphaf = app_yf ./ (app_kf + config.lambda);   %equation for fast training
        
        
        % extract the training sample feature map for the scale filter
        xs = get_scale_sample(im_gray, pos, app_sz, currentScaleFactor * scaleFactors, scale_window, scale_model_sz);

        % calculate the scale filter update
        xsf = fft(xs,[],2);
        new_sf_num = bsxfun(@times, ysf, conj(xsf));
        new_sf_den = sum(xsf .* conj(xsf), 1);
        
        
        if frame == 1,  %first frame, train with a single image
                        
            motion_model.xf=xf;
            motion_model.alphaf = alphaf;

            app_model.xf=app_xf; 
            app_model.alphaf=app_alphaf;
            
            svm_struct=det_learn(im, pos, window_sz, config.detc, []);
            
            sf_den = new_sf_den;
            sf_num = new_sf_num;
            
        else            
            
            motion_model.alphaf = (1 - interp_factor) * motion_model.alphaf + interp_factor * alphaf;
            motion_model.xf = (1 - interp_factor) * motion_model.xf + interp_factor * xf; 
            
            sf_den = (1 - interp_factor) * sf_den + interp_factor * new_sf_den;
            sf_num = (1 - interp_factor) * sf_num + interp_factor * new_sf_num;
            
            if max_response>config.appearance_thresh
                
                app_model.alphaf=(1 - interp_factor) * app_model.alphaf + interp_factor * app_alphaf;
                app_model.xf=(1 - interp_factor) * app_model.xf + interp_factor * app_xf;
                
                svm_struct=det_learn(im, pos, window_sz, config.detc, svm_struct);
            end
        end
            
		%save position and timing
		positions(frame,:) = pos;
		time = time + toc();

		%visualization
        target_sz_s=target_sz*currentScaleFactor;
        
        if show_visualization,
            box = [pos([2,1]) - target_sz_s([2,1])/2, target_sz_s([2,1])];
            stop = update_visualization(frame, box);
            if stop, break; end  %user pressed Esc, stop early

            hold off
            drawnow
        % 			pause(0.05)  %uncomment to run slower
        end
        
	end

	if resize_image, positions = positions * 2; end
    
end