function config=det_config(target_sz, image_sz)

% frame_min_width = 320;
% trackwin_max_dimension = 64;
% template_max_numel = 144;
% % frame_sz = size(frame);
% 
% if max(target_sz) <= trackwin_max_dimension ||...
%         frame_sz(2) <= frame_min_width
%     config.image_scale = 1;
% else
%     min_scale = frame_min_width/frame_sz(2);
%     config.image_scale = max(trackwin_max_dimension/max(target_sz),min_scale);    
% end
% 
% t_sz = target_sz*config.image_scale;
% win_area = prod(t_sz);
% config.ratio = (sqrt(template_max_numel/win_area));
% template_sz = round(t_sz*config.ratio); 
% config.template_sz = template_sz([2 1]);

target_max_win = 144;

config.ratio=sqrt(target_max_win/prod(target_sz));

config.t_sz=round(target_sz*config.ratio);

config.nbin=32;

config.target_sz=target_sz;
config.image_sz=image_sz;

config.thresh_p = 0.5; % IOU threshold for positive training samples
config.thresh_n = 0.1; % IOU threshold for negative ones