clear all;
close all;
subject =  200;
subject_index = 24; 

win = 11;

%% loading
net_used = 'resnet50';
time_window = 10;
regression = 1;
fold = 1;
maxIntensity_threshold = 0.5;
ifRelu = 0;
savePath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\classWeightsNew\10sec\';
% ===================================================================================================
switch time_window
    case 10
%         load([savePath, net_used, '\fold', int2str(fold), '\result.mat']);
        %For LOSO
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\LOSO\10sec\alexnet_0.7\Subject', int2str(subject_index), '\result.mat']);
        load(['D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\LOSO\10sec\alexnet_0.7\Subject', int2str(subject_index), '\setting.mat']);
%        
    case 5
end

score_threshold = 0.5;
%%
    thisPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_no_overlap\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
    im = imread(thisPath);
    hiResPath = ['D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_highRes\signal_resize\s', int2str(subject), '\s', int2str(subject), '_', int2str(win), '.png'];
    imHiRes = imread(hiResPath);
    imshow(imHiRes)
    
    %% Detect bounding box
    [detectBoxImg, detectScoreImg, detectClassImg] = detect(detector,im,...
                    'Threshold', 0.5, 'SelectStrongest', false, 'MiniBatchSize', 1);
    [selectedBboxes, selectedScores, selectedLabels, selectIndexImg] = selectStrongestBboxMulticlass(...
                    detectBoxImg, detectScoreImg, detectClassImg, 'OverlapThreshold', 0.2);
                
    %% Plot bounding box
    plot_predict_bbox_new(imHiRes, selectedScores, selectedLabels, selectedBboxes, score_threshold)
    
    %% Plot ground truth
    figure(),
    imshow(imHiRes);
    plot_ground_truth_new(imHiRes, inputImageSize, dataTest_preprocess, win)

    
function [roi_out_1,gradients] = Gradient_function(dlnet,roi_out_1, layername, select_score)

score_out = predict(dlnet, roi_out_1,'Outputs', layername);
loss = score_out(select_score);
gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization

end 