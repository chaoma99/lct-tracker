function [ feat ] = get_feature_detector( I, nbin )

% color image
if ~ismatrix(I) && ~isequal(I(:,:,1),I(:,:,2),I(:,:,3))
    I = uint8(255*RGB2Lab(I));
    nth=4;
else % gray image    
    I=I(:,:,1);
    nth=8;
end

thr=(1/(nth+1):1/(nth+1):1-1/(nth+1))*255;

ksize=4;

f_iif=255-calcIIF(I(:,:,1),[ksize ksize],nbin);

f_chn=cat(3,f_iif, I);

feat=zeros(size(f_chn,1), size(f_chn, 2), nth*size(f_chn,3));

for ii=1:size(f_chn,3)
    
    t_chn=f_chn(:,:,ii);
    t_chn=t_chn(:,:,ones(1,nth));
    t_chn=bsxfun(@gt, t_chn, reshape(thr, 1, 1, nth));    
    feat(:,:,(ii-1)*nth+1:ii*nth)=t_chn;
end

end

