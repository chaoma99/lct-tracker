

function [ svm_struct ] = det_learn( im, pos, window_sz, det_config, svm_struct )
%
[feat, ~, labels]=det_samples(im, pos, window_sz, det_config);

idx_p=labels>0.9;
idx_n=labels<0.5;

feat=feat(:, idx_p|idx_n);

% feat=feat';

labels(idx_p)=1;
labels(idx_n)=-1;
labels=labels(idx_p|idx_n);

% labels=(labels>0.5);

if isempty(svm_struct)
%     [feat, labels]=update_support_vector(feat, labels, svm_struct);
%     labels=[labels; svm_struct.GroupNames(svm_struct.SupportVectorIndices)];  

[svm_struct.w, svm_struct.b]= vl_svmtrain(feat, labels, 0.5) ;

else  
    svm_struct.w = onlineSVMTrain(feat', labels, 0.5, svm_struct.w);   
end

% xs0=feat(:,labels>det_config.thresh_p);
% hs0=feat(:,labels<det_config.thresh_n);

% if isempty(ferns)
%     fernPrm=struct('S',8,'M',50,'thrr',[-1 1],'bayes',1);
% else
%     fernPrm=struct('S',8,'M',50,'thrr',[0 1],'bayes',1, 'ferns', ferns);
% end

% det_config.C=100;

% sample_w=labels;
% sample_w(labels)=sum(labels==0);
% sample_w(~labels)=sum(labels==1);
% 
% C = max(det_config.C*sample_w/sum(sample_w),0.001);

% [ferns,~]=fernsClfTrain(feat',labels,fernPrm);


% svm_struct=svmtrain(feat,labels,'boxconstraint',C, 'autoscale', 'false');

end


function [w] = onlineSVMTrain(X, y, C, w)
%TRAIN_PA Train/update passive-aggressive online learner
%
%   w = train_pa(X, y, C, w)
%
% The function trains or updates a linear classifier using the
% passive-aggressive online learning algorithm. The variable C is the
% agressiveness parameter. The functions assumes the labels are in [-1, +1].
%


[N, D] = size(X);
if ~exist('w', 'var') || isempty(w)
    w = randn(D, 1);
    iter = 10;
else
    iter = 1;
end
if any(~(y == -1 | y == 1))
    error('Labels should be in [-1, 1].');
end        

% Perform updates
for i=1:iter
    for n=1:N
        % Perform prediction and suffer loss
        loss = max(0, 1 - y(n) .* (X(n,:) * w));
        % Update weights
        if loss > 0
           w = w + (loss ./ (sum(X(n,:) .^ 2) + (1 ./ (2 .* C)))) * (X(n,:)' * y(n)); 
        end
    end
end

end


