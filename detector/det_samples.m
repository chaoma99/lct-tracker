
% det using the  bb as [x y w d]

function [feat, pos_samples, labels, weights]=det_samples(im, pos, window_sz, det_config)

w_area=get_subwindow(im, pos, floor(window_sz*1.2));

feat=get_feature_detector(w_area, det_config.nbin);

feat=imresize(feat, det_config.ratio, 'nearest');

% w_area=imresize(w_area, det_config.ratio, 'nearest');

t_sz=det_config.t_sz;

% feat=get_feature_detector(w_area, det_config.nbin);

sz=size(feat);

% step=max(floor(min(t_sz)/4),1);

step=1;

feat=im2colstep(feat, [t_sz(1:2), size(feat,3)], [step, step, size(feat,3)]);

[xx, yy]=meshgrid(1:step:sz(2)-t_sz(2)+1,1:step:sz(1)-t_sz(1)+1);

weights=fspecial('gaussian',size(xx), 25);

bb_samples=[xx(:), yy(:), ones(numel(xx),1)*t_sz(2), ones(numel(xx),1)*t_sz(1)];

bb_target=[(sz(2)-t_sz(2))/2, (sz(1)-t_sz(1))/2, t_sz(2), t_sz(1)];

labels=get_iou(bb_samples, bb_target);

yy=(yy+t_sz(1)/2-sz(1)/2)/det_config.ratio;
yy=yy(:)+pos(1);

xx=(xx+t_sz(2)/2-sz(2)/2)/det_config.ratio;
xx=xx(:)+pos(2);

pos_samples=[yy' ; xx'];

im_sz=det_config.image_sz;
% target_sz=det_config.target_sz;

idx=yy>im_sz(1) | yy<0 | ...
    xx>im_sz(2) | xx<0;

feat(:, idx)=[];

pos_samples(:, idx)=[];

labels(idx)=[];

weights(idx)=[];

end



function iou = get_iou(r1,r2)

if size(r2,1)==1
    r2=r2(ones(1, size(r1,1)),:);
end

left = max((r1(:,1)),(r2(:,1)));
top = max((r1(:,2)),(r2(:,2)));
right = min((r1(:,1)+r1(:,3)),(r2(:,1)+r2(:,3)));
bottom = min((r1(:,2)+r1(:,4)),(r2(:,2)+r2(:,4)));
ovlp = max(right - left,0).*max(bottom - top, 0);
iou = ovlp./(r1(:,3).*r1(:,4)+r2(:,3).*r2(:,4)-ovlp);

end