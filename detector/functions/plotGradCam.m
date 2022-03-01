%% CAM
function combinedImage = plotGradCam(im, imHi, detector, roi2soft_net, activation_layer, softmax_layer, selectIndexImg, selectedBboxes, score_threshold, regression)
    combinedImage = double(imHi)*1.5;
    regionProp = activations(detector.Network,im,'regionProposal');
    out_score = activations(detector.Network,im,'rcnnClassification');
    feature = activations(detector.Network,im,activation_layer);
    
    % Select region proposal (score>=0.5 & class ~= background)
    out_score = reshape(out_score, size(out_score, [3,4]));
    [pred_score, pred_class] = max(out_score);
    region_selected_logi = (pred_score >= score_threshold) & (pred_class ~= 7);
    
    regionProp_selected = regionProp(region_selected_logi, :);
    feature_selected = feature(:,:,:,region_selected_logi);
    pred_class_selected = pred_class(region_selected_logi);

    % Select region proposal (strongest Bbox)
    regionProp_selected = regionProp_selected(selectIndexImg, :);
    feature_selected = feature_selected(:,:,:,selectIndexImg);
    pred_class_selected = pred_class_selected(selectIndexImg);
    
    
    for j = 1:size(regionProp_selected, 1)
        feature_each_Prop = dlarray(feature_selected(:,:,:,j), 'SSC');
        [outp,gradients] = dlfeval(@Gradient_function, roi2soft_net, feature_each_Prop, softmax_layer, pred_class_selected(j));
        % calculate gradcam
        alpha = mean(gradients, [1 2]);
        classActivationMap = sum(feature_each_Prop .* alpha, 3);
        classActivationMap = extractdata(classActivationMap);
        gradcam = max(classActivationMap,0); % apply relu function
%         gradcam = classActivationMap;
        % Calculate each bbox position on original size image
        if regression == 1
            original_width = selectedBboxes(j, 3);
            original_height = selectedBboxes(j, 4);
            original_width_range = selectedBboxes(j, 1):selectedBboxes(j, 1)+original_width-1;
            original_height_range = selectedBboxes(j, 2):selectedBboxes(j, 2)+original_height-1;
        else
            original_width = regionProp_selected(j,3) - regionProp_selected(j,1) + 1;
            original_height = regionProp_selected(j,4) - regionProp_selected(j,2) + 1;
            original_width_range = (regionProp_selected(j,1):regionProp_selected(j,3));
            original_height_range = (regionProp_selected(j,2):regionProp_selected(j,4));
        end
        gradcam = imresize(gradcam,[original_height, original_width]);
        gradcam = normalizeImage(gradcam);
        cmap = jet(255).*linspace(0,1,255)';
        gradcam = ind2rgb(uint8(gradcam*255),cmap)*255;
        combinedImage(original_height_range, original_width_range, :) = combinedImage(original_height_range, original_width_range, :) + gradcam;
       
%         imshow(uint8(normalizeImage(combinedImage)*255));
    end
    combinedImage = uint8(normalizeImage(combinedImage)*255);
%     f1 = figure('visible','on');
%     subplot(2,1,1)
%     imshow(uint8(combinedImage));
end

function [roi_out_1,gradients] = Gradient_function(dlnet,roi_out_1, layername, select_score)
    score_out = predict(dlnet, roi_out_1,'Outputs', layername);
    loss = score_out(select_score);
    gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
    gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization
end