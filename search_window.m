function [ window_sz, app_sz ] = search_window( target_sz, im_sz, config)

%% For objects with large height, we restrict the search window with 1.4x height  

    if target_sz(1)/target_sz(2)>2
        window_sz = floor(target_sz.*[1.4, 1+config.padding]);

%% For objects with large height and width and accounting for at least 10 percent of the whole image,
%% we only search 2x height and width
    elseif min(target_sz)>80 && prod(target_sz)/prod(im_sz(1:2))>0.1
        window_sz=floor(target_sz*2);
    
%% otherwise, we use the padding configuration    
    else        
        window_sz = floor(target_sz * (1 + config.padding));
    end

    app_sz=target_sz+2*config.features.cell_size;

end



