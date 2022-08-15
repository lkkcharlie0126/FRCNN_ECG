clear all;
close all;
%% 
savePath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\balanced2355\10sec\';
%% 
net_used = 'alexnet';
time_window = 10;
regression = 1;
fold = 1;
maxIntensity_threshold = 0.2;
ifRelu = 1;

saveFolder = [savePath, net_used, '_0.7\fold', int2str(fold), '\gradCAM_quantify_HiRes\'];
%% 
switch time_window
    case 10
        load([savePath, net_used, '_0.7\fold', int2str(fold), '\result.mat']);
        load([savePath, 'setting\fold', int2str(fold) ,'\setting.mat']);
        mkdir(saveFolder);
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
data_true = dataTest;
% data_pred = detectionResults_test;
%% =========================================================

% For adjust cnn
% roi2soft_layers = [ ...
%     imageInputLayer([6 20 256], 'Name', 'input_roi', 'Normalization', 'none')
%     detector.Network.Layers(22:24)
%     ];
% softmax_layer = 'rcnnSoftmax';

roi2soft_net = dlnetwork(layerGraph(roi2soft_layers))
T_featurePoision = {};
for i = 125:125%1:size(dataTest.UnderlyingDatastores{1, 1}.Files, 1) % For each window
    disp(['Window: ', int2str(i), '/', int2str(size(dataTest.UnderlyingDatastores{1, 1}.Files, 1))])
    thisPath = dataTest.UnderlyingDatastores{1, 1}.Files{i};
    im = imread(thisPath);
    pos = findstr(thisPath, '\');
    pos1 = pos(6);
    pos2 = pos(7);
    imHiRes = imread([thisPath(1:pos1), '10sec_highRes', thisPath(pos2:end)]);
    %% Detect bounding box
    [detectBoxImg, detectScoreImg, detectClassImg] = detect(detector,im,...
                    'Threshold', 0.5, 'SelectStrongest', false, 'MiniBatchSize', 1);
    [selectedBboxes, selectedScores, selectedLabels, selectIndexImg] = selectStrongestBboxMulticlass(...
                    detectBoxImg, detectScoreImg, detectClassImg, 'OverlapThreshold', 0.2);

    %% CAM
%     subplot(2,1,1)
%     f1 = figure('visible','on');
%     combinedImage = double(im)*1.5;
    combinedImage = double(imHiRes)*1.5;
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
    
    camBox_window = [];
    for j = 1:size(regionProp_selected, 1) % For each predict bbox
        feature_each_Prop = dlarray(feature_selected(:,:,:,j), 'SSC');
        [outp,gradients] = dlfeval(@Gradient_function, roi2soft_net, feature_each_Prop, softmax_layer, pred_class_selected(j));
        % calculate gradcam
        alpha = mean(gradients, [1 2]);
        classActivationMap = sum(feature_each_Prop .* alpha, 3);
        classActivationMap = extractdata(classActivationMap);
        if ifRelu == 1
            gradcam = max(classActivationMap,0); % apply relu function
        else
            gradcam = classActivationMap;
        end
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
        %% 二值化
        gradcam2 = gradcam > 1-maxIntensity_threshold;
        % Largest connected component
        gradcamC = zeros(size(gradcam));
%         if max(max(gradcamC)) == 0
%             continue;
%         end
        CC = bwconncomp(gradcam2);
%         if CC.NumObjectsum == 0
%             continue;
%         end
        numPixels = cellfun(@numel,CC.PixelIdxList);    
        [biggest,idx] = max(numPixels);
        
        gradcamC(CC.PixelIdxList{idx}) = 1;
%         imshow(gradcamC)
        
        % Calculate CAM BBox
        [camBox_high, camBox_low, camBox_left, camBox_right] = camBox(gradcamC);
        
        camBox_original_x = original_width_range(1)+camBox_left-1;
        camBox_original_y =  original_height_range(1)+camBox_high-1;
        camBox_original_w = camBox_right - camBox_left;
        camBox_original_h = camBox_low - camBox_high;
        camBox_original = {camBox_original_x, camBox_original_y, camBox_original_w, camBox_original_h, selectedLabels(j)};
        camBox_window = [camBox_window; camBox_original];
        %
        cmap = jet(255).*linspace(0,1,255)';
        gradcam = ind2rgb(uint8(gradcamC*255),cmap)*255;
%         gradcam = ind2rgb(uint8(gradcam*255),cmap)*255;
        combinedImage(original_height_range, original_width_range, :) = combinedImage(original_height_range, original_width_range, :) + gradcam;
       
%         imshow(uint8(normalizeImage(combinedImage)*255));
        
    end
    combinedImage = normalizeImage(combinedImage)*255;
    
    f1 = figure('visible','on');
    subplot(2,1,1)
    imshow(uint8(combinedImage));
    %% Plot CAM feature bbox
    for eachCamBox= 1:size(camBox_window, 1)
        switch camBox_window{eachCamBox, 5}
            case 'SR'
                box_color = 'r';
            case 'APC'
                box_color = 'g';
            case 'VPC'
                box_color = 'b';
            case 'LBBB'
                box_color = 'c';
            case 'RBBB'
                box_color = 'm';
            case 'Others'
                box_color = 'y';
        end
        rectangle('Position', [camBox_window{eachCamBox, 1:4}], 'EdgeColor',box_color)
    end
    %% Plot Predict bounding box
    plot_predict_bbox(selectedScores, selectedLabels, selectedBboxes, score_threshold)
    
    %% Subplot Ground truth
    subplot(2,1,2)
    plot_ground_truth_new(imHiRes, inputImageSize, data_true, i)
    
    %% Save img
    pos = findstr(thisPath, '\');
    pos = pos(end);
    saveas(f1, [saveFolder, thisPath(pos+1:end)]);
    close(f1)
%     plot_ground_truth(im, inputImageSize, data_true, i)
    
    %%  CAM feature position in Ground truth BBox
%     gtruthBbox = data_true.UnderlyingDatastores{1, 2}.LabelData{i, 1};
%     featurePoision = {};
%     [~, index] = sort(gtruthBbox(:,1));
%     gtruthBbox = gtruthBbox(index, :);
%     for j = 1:size(gtruthBbox, 1) % for each ground truth
%         maxIndex = 0;
%         maxIou = 0;
%         for jj = 1:size(camBox_window, 1)
%             if bboxOverlapRatio(gtruthBbox(j,:),[camBox_window{jj, [1:4]}], 'Min') > maxIou
%                 maxIndex = jj;
%                 maxIou = bboxOverlapRatio(gtruthBbox(j,:),[camBox_window{jj, [1:4]}], 'Min');
%             end
%         end
%         if maxIndex == 0
%             featurePoision = [featurePoision; 0];
%         else
%             featurePoision_left = max((camBox_window{maxIndex, 1} - gtruthBbox(j,1))/gtruthBbox(j,3), 0);
%             featurePoision_right = min((camBox_window{maxIndex, 1} + camBox_window{maxIndex, 3}  - gtruthBbox(j,1))/gtruthBbox(j,3), 1);
%             featurePoision_high = max((camBox_window{maxIndex, 2} - gtruthBbox(j,2))/gtruthBbox(j,4), 0);
%             featurePoision_low = min((camBox_window{maxIndex, 2} + camBox_window{maxIndex, 4} - gtruthBbox(j,2))/gtruthBbox(j,4), 1);
%             
%             featurePoision_w = featurePoision_right - featurePoision_left;
%             featurePoision_h = featurePoision_low - featurePoision_high;
%             featurePoision = [featurePoision; [featurePoision_left, featurePoision_high, featurePoision_w, featurePoision_h, pred_class_selected(maxIndex)]];
%         end
%     end
%     T_featurePoision = [T_featurePoision; {featurePoision}];
end
%% Save CAM feature table
% save([savePath, net_used, '_0.7\fold', int2str(fold),'\', 'T_featurePosition_',char(string(maxIntensity_threshold)), '.mat'], 'T_featurePoision');

function [roi_out_1,gradients] = Gradient_function(dlnet,roi_out_1, layername, select_score)

score_out = predict(dlnet, roi_out_1,'Outputs', layername);
loss = score_out(select_score);
gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization

end 