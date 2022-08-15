clear all;
subject =  111;
win = 99;

%% loading
net_used = 'alexnet';
time_window = 10;
regression = 1;
fold = 1;
maxIntensity_threshold = 0.5;
ifRelu = 1;
savePath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\original\';
% ===================================================================================================
switch time_window
    case 10
        load([savePath, net_used, '_0.7\fold', int2str(fold), '\result.mat']);
        %For LOSO
%         load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\LOSO\10sec\alexnet_0.7\Subject1\result.mat']);
%         load([savePath, 'setting\fold', int2str(fold) ,'\setting.mat']);        
%         load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\balanced2355\10sec\setting\fold', int2str(fold) ,'\setting.mat']);
    case 5
end

switch net_used
    case 'alexnet'
        roi2soft_layers = [ ...
            imageInputLayer([6 20 256], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(22:29)
            ];
        softmax_layer = 'prob';
        activation_layer = 'roiPooling';
    case 'resnet50'
        roi2soft_layers = [ ...
            imageInputLayer([8 22 2048], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(180:182)
            ];
        softmax_layer = 'rcnnSoftmax';
        activation_layer = 'activation_49_relu';
    case 'googlenet'
        roi2soft_layers = [ ...
            imageInputLayer([7 21 1024], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(146:149)
            ];
        softmax_layer = 'rcnnSoftmax';
        activation_layer = 'inception_5b-output';
end

score_threshold = 0.5;
% data_true = dataTest;
roi2soft_net = dlnetwork(layerGraph(roi2soft_layers))
%%
    thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_no_overlap\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
    im = imread(thisPath);
    thisPath_HiRes = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_highRes\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
    im_HiRes = imread(thisPath_HiRes);
    
    %% Detect bounding box
    [detectBoxImg, detectScoreImg, detectClassImg] = detect(detector,im,...
                    'Threshold', 0.5, 'SelectStrongest', false, 'MiniBatchSize', 1);
    [selectedBboxes, selectedScores, selectedLabels, selectIndexImg] = selectStrongestBboxMulticlass(...
                    detectBoxImg, detectScoreImg, detectClassImg, 'OverlapThreshold', 0.2);

    %% grad-CAM
    
    combinedImage = double(im_HiRes)*1.5;
    regionProp = activations(detector.Network,im,'regionProposal');
    out_score = activations(detector.Network,im,'rcnnClassification');
    feature = activations(detector.Network,im,activation_layer);
    
    % Select region proposal (score>=0.5 & class != background)
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
%         [outp, gradients] = Gradient_function(roi2soft_net, feature_each_Prop, softmax_layer, pred_class_selected(j));
        [outp, gradients] = dlfeval(@Gradient_function, roi2soft_net, feature_each_Prop, softmax_layer, pred_class_selected(j));
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
    combinedImage = normalizeImage(combinedImage)*255;
    im_gradCAM = uint8(combinedImage);
    imshow(im_gradCAM);
    
    %% Plot bounding box
    plot_predict_bbox_new(im_gradCAM, selectedScores, selectedLabels, selectedBboxes, score_threshold)
    
% function [roi_out_1,gradients] = Gradient_function(dlnet, roi_out_1, layername, select_score)
% 
% score_out = predict(dlnet, roi_out_1,'Outputs', layername);
% loss = score_out(select_score);
% gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
% gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization
% 
% end 