clear all;
subject =  111;
win = 99;

%% loading
net_used = 'googlenet';
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
        activation_layer = 'rpnConv1x1BoxDeltas';
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
    feature = activations(detector.Network,im,activation_layer);
    feature2 = activations(detector.Network,im,'boxDeltas');
%     for i = 1:6
%         subplot(5, 5, i)
%         imshow(feature(:,:,i))
%     end
%     figure(),
%     imshow(feature(:,:,2))