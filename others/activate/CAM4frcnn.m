score_threshold = 0.5;
weights_fully = detector.Network.Layers(23,1).Weights;

k = 1
windows_num = size(T_used,1);
numClasses = size(T_used,2)-1;
idx_val = zeros(windows_num,1);
idx_val(T_kfold{k+1}) = 1;
idx_val = logical(idx_val);
imdsVal = imageDatastore(T_used{idx_val,'imageFilename'});
bldsVal = boxLabelDatastore(T_used(idx_val,2:numClasses+1));
dataVal = combine(imdsVal,bldsVal);
%% =========================================================
data_true = dataVal;
data_pred = detectionResults_val;
box_color = 'r';
%% =============================

for i = 1:size(dataVal_preprocess.UnderlyingDatastores{1, 1}.Files, 1)
    im = imread(dataVal_preprocess.UnderlyingDatastores{1, 1}.Files{i});
    
    % CAM
    subplot(2,1,1)
    combinedImage = double(im)*1.5;
    regionProp = activations(detector.Network,im,'regionProposal');
    feature = activations(detector.Network,im,'roiPooling');
    out_score = activations(detector.Network,im,'rcnnClassification');
    n = 0;
    for j = 1:size(regionProp, 1)
        [pred_score, pred_class] = max(out_score(1,1,:,j))
        if (pred_class == 7) || (pred_score < score_threshold)
            continue;
        else
            n = n+1;
            classActivationMap = 0;
            for k = 1:size(weights_fully,2)
                classActivationMap = classActivationMap + feature(:,:,k,j)*weights_fully(pred_class,k);
            end
            CAM = imresize(classActivationMap,[regionProp(j,4) - regionProp(j,2) + 1, regionProp(j,3) - regionProp(j,1) + 1]);
            CAM = normalizeImage(CAM);
            
            cmap = jet(255).*linspace(0,1,255)';
            CAM = ind2rgb(uint8(CAM*255),cmap)*255;
            combinedImage(regionProp(j,2):regionProp(j,4), regionProp(j,1):regionProp(j,3), :) = combinedImage(regionProp(j,2):regionProp(j,4), regionProp(j,1):regionProp(j,3), :) + CAM;
%             combinedImage(regionProp(j,2):regionProp(j,4), regionProp(j,1):regionProp(j,3)) = combinedImage(regionProp(j,2):regionProp(j,4), regionProp(j,1):regionProp(j,3)) + CAM;
        end
    end
    combinedImage = normalizeImage(combinedImage)*255;
    imshow(uint8(combinedImage));
    
    % Detect bounding box
    [detectBoxImg, detectScoreImg, detectClassImg] = detect(detector,im,...
                    'Threshold', 0, 'SelectStrongest', true, 'MiniBatchSize', 1);
    n_detect = length(find(detectScoreImg>0.5));
    for j = 1:length(detectScoreImg)
        if detectScoreImg(j) >= score_threshold
            switch detectClassImg(j)
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
            rectangle('Position', detectBoxImg(j,:), 'EdgeColor',box_color)
        end
    end
    % Subplot true
    subplot(2,1,2)
    img_r = imresize(im,inputImageSize(1:2));
    imshow(img_r);
    for j = 1:size(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}, 1)
        switch data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}(j)
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
        sz = size(im,[1 2]);
        scale = inputImageSize(1:2)./sz;
        box_r = bboxresize(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 1}(j,:), scale);
        rectangle('Position', box_r, 'EdgeColor',box_color)
    end
end
