function results = run_lct2(seq, res_path, bSaveImage)


    addpath('./utility');
    	
	config.padding = 1.8;  %extra area surrounding the target
	config.lambda = 1e-4;  %regularization
	config.output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)	        
    config.interp_factor=0.01; % best 0.01
    config.kernel_sigma = 1;

    config.features.hog_orientations = 9;
    config.features.cell_size = 4;   % size of hog grid cell		
    config.features.window_size = 6; % size of local region for intensity historgram  
    config.features.nbins=8; % bins of intensity historgram
    
    config.motion_thresh=0.15;  
    config.appearance_thresh=0.38;
    
    show_visualization=0;
    
    target_sz = [seq.init_rect(1,4), seq.init_rect(1,3)];
	pos = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(target_sz/2);
    img_files = seq.s_frames;
       
    video_path='';

    [positions, time] = tracker_lct(video_path, img_files, pos, target_sz, config, show_visualization);
    %return results to benchmark, in a workspace variable
    
    rects = [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
    rects(:,3) = target_sz(2);
    rects(:,4) = target_sz(1);
    res.type = 'rect';
    res.res = rects;
    res.fps=numel(img_files)/time;
    
    results=res;   

end