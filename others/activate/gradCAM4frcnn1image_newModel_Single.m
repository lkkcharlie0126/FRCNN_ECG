clear all;
subject = 104;
win = 28;

%% loading
nets = {'resnetSelf2Small'};
for i_net = 1:length(nets)
net_used = nets{i_net};
time_window = '10sec';
regression = 1;
fold = 1;
maxIntensity_threshold = 0.2;
ifRelu = 1;
savePath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\';

modelPath = [savePath, time_window, '\', net_used, '_0.7_twcc_200\fold', int2str(fold)];
switch net_used
    case 'alexnet'
        modelPath = [savePath, 'original\', net_used, '_0.7\fold', int2str(fold)];
%         modelPath = [savePath, 'balanced2355\10sec\', net_used, '_0.7\fold', int2str(fold)];
        
end
% ===================================================================================================
% switch time_window
%     case '10sec'
%         load([modelPath, '\result.mat']);
%         %For LOSO
% %         load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\LOSO\10sec\alexnet_0.7\Subject1\result.mat']);
% %         load([savePath, 'setting\fold', int2str(fold) ,'\setting.mat']);        
% %         load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\balanced2355\10sec\setting\fold', int2str(fold) ,'\setting.mat']);
%     case '5sec'
%         load([modelPath, '\result.mat']);
% end
load([modelPath, '\result.mat']);

%% For each subject
% subjects = [100:109, 111:119, 121:124, 200:203, 205, 207:210, 212:215, 217, 219:223, 228, 230:234];
% subjects = [232, 221];
subjects = [200:203, 205, 207:210, 212:215];

% for i_subject = 1:length(subjects)
% subject = subjects(i_subject);
mkdir([modelPath, '\figures\gradCAM\s', int2str(subject)]);
mkdir([modelPath, '\figures\boxInBox\s', int2str(subject)]);
mkdir([modelPath, '\figures\GT\s', int2str(subject)]);

switch time_window
    case '10sec'
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_no_overlap\box\new\matlab\0.7\', 's', int2str(subject), '\', 'T_s', int2str(subject), '.mat']);
    case '5sec'
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\data\5sec\box\new\matlab\0.7\', 's', int2str(subject), '\', 'T_s', int2str(subject), '.mat']);
    case '30sec'
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\data\30sec\box\new\matlab\0.7\', 's', int2str(subject), '\', 'T_s', int2str(subject), '.mat']);
    case '10sec_260'
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_260\box\new\matlab\0.7\', 's', int2str(subject), '\', 'T_s', int2str(subject), '.mat']);
    case '10sec_150'
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_150\box\new\matlab\0.7\', 's', int2str(subject), '\', 'T_s', int2str(subject), '.mat']);

end
try
    imdsTest = imageDatastore(T{:,'imageFilename'});
    bldsTest = boxLabelDatastore(T(:,2:6+1));
catch 
    imdsTest = imageDatastore(bboxTable{:,'imageFilename'});
    bldsTest = boxLabelDatastore(bboxTable(:,2:6+1));
end
dataTest = combine(imdsTest,bldsTest);
try
    detector = obj.detector;
catch
end
switch net_used
    case 'alexnet'
        roi2soft_layers = [ ...
            imageInputLayer([6 20 256], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(22:29)
            ];
        roi2soft_layers = layerGraph(roi2soft_layers);
        softmax_layer = 'prob';
        activation_layer = 'roiPooling';
    case 'resnet50'
        roi2soft_layers = [ ...
            imageInputLayer([8 22 2048], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(180:182)
            ];
        roi2soft_layers = layerGraph(roi2soft_layers);
        softmax_layer = 'rcnnSoftmax';
        activation_layer = 'activation_49_relu';
    case 'googlenet'
        roi2soft_layers = [ ...
            imageInputLayer([7 21 1024], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(146:149)
            ];
        roi2soft_layers = layerGraph(roi2soft_layers);
        softmax_layer = 'rcnnSoftmax';
        activation_layer = 'inception_5b-output';
    case 'resnetSelf2Small'
        roi2soft_layers = [ ...
            imageInputLayer([2 2 2048], 'Name', 'input_roi', 'Normalization', 'none')
            detector.Network.Layers(70:72)
            ];
        softmax_layer = 'rcnnSoftmax';
        activation_layer = 'activation_49_relu';
%     case 'resnetSelf2Small'
%         roi2soft_layers = [ ...
%             imageInputLayer([4 4 1024], 'Name', 'input_roi', 'Normalization', 'none')
%             detector.Network.Layers(57:72)
%             ];
%         roi2soft_layers = layerGraph(roi2soft_layers);
%         roi2soft_layers = disconnectLayers(roi2soft_layers, 'res5a_branch2c','res5a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'activation_40_relu','res5a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'res5a_branch2c','add_14/in2');
%         softmax_layer = 'rcnnSoftmax';
%         activation_layer = 'add_8';
%     case 'resnetSelf2Small'
%         roi2soft_layers = [ ...
%             imageInputLayer([8 8 512], 'Name', 'input_roi', 'Normalization', 'none')
%             detector.Network.Layers(45:72)
%             ];
%         roi2soft_layers = layerGraph(roi2soft_layers);
% 
%         roi2soft_layers = disconnectLayers(roi2soft_layers, 'res4a_branch2c','res4a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'activation_22_relu','res4a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'res4a_branch2c','add_8/in2');
% 
%         roi2soft_layers = disconnectLayers(roi2soft_layers, 'res5a_branch2c','res5a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'activation_40_relu','res5a_branch1');
%         roi2soft_layers = connectLayers(roi2soft_layers, 'res5a_branch2c','add_14/in2');
%         softmax_layer = 'rcnnSoftmax';
%         activation_layer = 'add_7';
end

score_threshold = 0.5;
% data_true = dataTest;
roi2soft_net = dlnetwork(roi2soft_layers)

%% for each window
% for win = 1:180
    disp(['S', int2str(subject), '  win: ', int2str(win), '/180'])
%%
switch time_window
    case '10sec'
% 10 sec
thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_no_overlap\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
im = imread(thisPath);
thisPath_HiRes = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_highRes\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
im_HiRes = imread(thisPath_HiRes);
% 5 sec
    case '5sec'
        thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\5sec\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
        im = imread(thisPath);
        im_HiRes = im;
    case '30sec'
        thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\30sec\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
        im = imread(thisPath);
        im_HiRes = im;
    case '10sec_260'
        thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_260\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
        im = imread(thisPath);
        im_HiRes = im;
    case '10sec_150'
        thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_150\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
        im = imread(thisPath);
        im_HiRes = im;
end
%% Detect bounding box
[detectBoxImg, detectScoreImg, detectClassImg] = detect(detector,im,...
                'Threshold', 0.5, 'SelectStrongest', false, 'MiniBatchSize', 1);
[selectedBboxes, selectedScores, selectedLabels, selectIndexImg] = selectStrongestBboxMulticlass(...
                detectBoxImg, detectScoreImg, detectClassImg, 'OverlapThreshold', 0.2);

%% grad-CAM
% selectedLabels(12, :) = [];
% selectedBboxes(12, :) = [];
% selectedScores(12, :) = [];
% selectIndexImg(12, :) = [];

combinedImage = double(im_HiRes)*1.5;
combinedImage2 = combinedImage;
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

camBox_window = [];
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
    gradcam2 = gradcam;

    cmap = jet(255).*linspace(0,1,255)';
    gradcam = ind2rgb(uint8(gradcam*255),cmap)*255;
    combinedImage(original_height_range, original_width_range, :) = combinedImage(original_height_range, original_width_range, :) + gradcam;
   
%         imshow(uint8(normalizeImage(combinedImage)*255));
%% Box in box
    [camBox_window, combinedImage2] = boxInBox(gradcam2, maxIntensity_threshold,...
        camBox_window, original_width_range, original_height_range, selectedLabels, j, combinedImage2);
end

combinedImage = normalizeImage(combinedImage)*255;
im_gradCAM = uint8(combinedImage);
% imshow(im_gradCAM);
imwrite(im_gradCAM, ['G:\.shortcut-targets-by-id\1f0bMhqk07Z7Sai1WPT7zDQWu0SWxWqg-\NCKU\WTMH\PAG\碩論\figures\result\gradCAM\',...
    net_used, '_', int2str(subject), '_', int2str(win),  '_gradCAM_only', '.png']);

%% Plot bounding box
RGB = plot_predict_bbox_new(im_HiRes, selectedScores, selectedLabels, selectedBboxes, score_threshold);
imwrite(RGB, ['G:\.shortcut-targets-by-id\1f0bMhqk07Z7Sai1WPT7zDQWu0SWxWqg-\NCKU\WTMH\PAG\碩論\figures\result\gradCAM\',...
    net_used, '_', int2str(subject), '_', int2str(win),  '_pred', '.png']);
% imshow(RGB);

%% Plot bounding box
% f7 = figure('visible','on');
RGB = plot_predict_bbox_new(im_gradCAM, selectedScores, selectedLabels, selectedBboxes, score_threshold);

% imwrite(RGB, [modelPath, '\figures\gradCAM\s', int2str(subject), '\', int2str(win), '.png']);
imwrite(RGB, ['G:\.shortcut-targets-by-id\1f0bMhqk07Z7Sai1WPT7zDQWu0SWxWqg-\NCKU\WTMH\PAG\碩論\figures\result\gradCAM\',...
    net_used, '_', int2str(subject), '_', int2str(win),  '_gradCAM', '.png']);
% saveas(f7, [modelPath, '\figures\gradCAM\s', int2str(subject), '\', int2str(win), '.tif']);
% close(f7)

%% Plot box in bbox
f8 = figure('visible','off');
combinedImage2 = normalizeImage(combinedImage2)*255;
im_gradCAM = uint8(combinedImage2);
imshow(im_gradCAM);
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
% imwrite(getframe(gca).cdata, [modelPath, '\figures\boxInBox\s', int2str(subject), '\', int2str(win), '.png']);
imwrite(getframe(gca).cdata, ['G:\.shortcut-targets-by-id\1f0bMhqk07Z7Sai1WPT7zDQWu0SWxWqg-\NCKU\WTMH\PAG\碩論\figures\result\gradCAM\',...
    net_used, '_', int2str(subject), '_', int2str(win),  '_box', '.png']);

% saveas(f8, [modelPath, '\figures\boxInBox\s', int2str(subject), '\', int2str(win), '.png']);
close(f8)


%% Plot ground truth
% f9 = figure('visible','off');
% imshow(im_HiRes);
try
    RGB = plot_ground_truth_new(im_HiRes, obj.inputImageSize, dataTest, win);
    %     imwrite(RGB, [modelPath, '\figures\GT\s', int2str(subject), '\', int2str(win), '.png']);
    imwrite(RGB, ['G:\.shortcut-targets-by-id\1f0bMhqk07Z7Sai1WPT7zDQWu0SWxWqg-\NCKU\WTMH\PAG\碩論\figures\result\gradCAM\',...
        net_used, '_', int2str(subject), '_', int2str(win),  '_GT', '.png']);
    % imshow(RGB);


catch

end
end
% end
% end


function [roi_out_1,gradients] = Gradient_function(dlnet, roi_out_1, layername, select_score)

score_out = predict(dlnet, roi_out_1,'Outputs', layername);
loss = score_out(select_score);
gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization

end 