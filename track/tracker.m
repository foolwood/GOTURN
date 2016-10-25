function [result, time] = tracker(img_files, ground_truth, net, gpu_id, show_visualization)
%% speed up 
%   image_bank = vl_imreadjpeg(img_files,'NumThreads', 4);
%
%
%
%%


close all
if show_visualization,  %create video interface
    update_visualization = show_video(img_files);
end

x_minmax = minmax(ground_truth(1,1:2:end));
y_minmax = minmax(ground_truth(1,2:2:end));
bbox_gt = [x_minmax(1),y_minmax(1),x_minmax(2)-x_minmax(1),y_minmax(2)-y_minmax(1)];

time = 0;
result = bsxfun(@times,bbox_gt,ones(numel(img_files),1));  %to calculate precision

image_prev = imread(img_files{1});
bbox_prev_tight = bbox_gt;
bbox_prev_prior_tight = bbox_gt;

pooling5 = [];

for frame = 2:numel(img_files),
    %%load image
    image_curr = imread(img_files{frame});
    tic;
    target_pad = crop_pad_image(bbox_prev_tight,image_prev);
    [curr_search_region,search_location,edge_spacing_x,...
        edge_spacing_y] = crop_pad_image(bbox_prev_prior_tight,image_curr);
    
    [bbox_estimate_cell,pooling5] = regressor_regress(net,pooling5,gpu_id,curr_search_region,target_pad);
    
    %%unscale the estimation to the real image size
    bbox_estimate_unscaled_cell = bb_unscale(bbox_estimate_cell,curr_search_region);
    %%find the estimated bounding box location relative to the current crop
    bbox_estimate_uncentered_cell = bb_uncenter(bbox_estimate_unscaled_cell,image_curr,...
        search_location,edge_spacing_x,edge_spacing_y);
    
    bbox_estimate_uncentered = mean(cell2mat(bbox_estimate_uncentered_cell),1);
    
    image_prev = image_curr;
    bbox_prev_tight = bbox_estimate_uncentered;
    bbox_prev_prior_tight = bbox_estimate_uncentered;%TODO
    
    result(frame,:) = bbox_estimate_uncentered;
    time = time + toc;
    
    if show_visualization,
        stop = update_visualization(frame, ground_truth(frame,:),result(frame,:),bbox_estimate_uncentered_cell);
        if stop, break, end
        drawnow
    end
    
end

end %%function
