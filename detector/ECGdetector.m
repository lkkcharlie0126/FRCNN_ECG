classdef ECGdetector
    properties
    path = 'D:\Win\WTMH\PAG_group\mitbih_5class'
    dataPath
    timeWindow = '10sec'
    network
    subjectNum
    winNum
    dataTest
    app
    detector

    selectedBboxes
    selectedScores
    selectedLabels
    selectIndexImg

    im
    f1
    f2
    end
    methods
        function obj = ECGdetector

        end

        function obj = loadData(obj)
            obj. dataPath = [obj.path, '\data\', obj.timeWindow];
            load([obj.dataPath, '\box\new\matlab\0.7\', 's', obj.subjectNum, '\', 'T_s', obj.subjectNum, '.mat']);
            try %For different version bbox 
                imdsTest = imageDatastore(T{:,'imageFilename'});
                bldsTest = boxLabelDatastore(T(:,2:6+1));
            catch
                imdsTest = imageDatastore(bboxTable{:,'imageFilename'});
                bldsTest = boxLabelDatastore(bboxTable(:,2:6+1));
            end
            obj.dataTest = combine(imdsTest,bldsTest);
            imagePath = [obj.dataPath, '\signal_resize\s',...
                obj.subjectNum, '\s', obj.subjectNum, '_', obj.winNum,'.png'];
            obj.im = imread(imagePath);
%             imagePathHi = [obj.guiPath, '\signal_hiRes\signal_10sec\s',...
%                 obj.subjectNum, '\s', obj.subjectNum, '_', obj.winNum,'.png'];            
%             obj.imHi = imread(imagePathHi);
        end

        function obj = plotSignal(obj)
             % Plot signal
            obj.f1 = imshow(obj.im);
            % Plot ground truth
            inputImageSize = size(obj.im);
            RGB = plot_ground_truth_new(obj.im, inputImageSize, obj.dataTest, str2num(obj.winNum));
            obj.f1 =  figure(1);
            imshow(RGB);
        end

        function obj = loadNet(obj)
            disp('Loading network...')
            result = load([obj.path, '\Result\FasterRCNN\', obj.timeWindow, '\',...
                obj.network, '\fold1\', 'result.mat']);
            try
                obj.detector = result.obj.detector;
            catch
                obj.detector = result.detector;
            end
%             net_used = 'resnet50';
%             roi2soft_layers = [ ...
%                 imageInputLayer([8 22 2048], 'Name', 'input_roi', 'Normalization', 'none')
%                 obj.detector.Network.Layers(180:182)
%                 ];
%             obj.softmax_layer = 'rcnnSoftmax';
%             obj.activation_layer = 'activation_49_relu';
%             obj.roi2soft_net = dlnetwork(layerGraph(roi2soft_layers));
            disp('Done');
        end

        function obj = detecting(obj)
            disp('Detecting...')
            [detectBoxImg, detectScoreImg, detectClassImg] = detect(obj.detector,obj.im,...
                    'Threshold', 0.5, 'SelectStrongest', false, 'MiniBatchSize', 1);
            [obj.selectedBboxes, obj.selectedScores, obj.selectedLabels, obj.selectIndexImg] = selectStrongestBboxMulticlass(...
                detectBoxImg, detectScoreImg, detectClassImg, 'OverlapThreshold', 0.2);
            
            % Plot predict box
%             [RGB, bboxLabel] = plot_predict_bbox_new(obj.im, obj.selectedScores, obj.selectedLabels, obj.selectedBboxes, 0.5);
%             obj.f2 =  figure(2);
%             imshow(RGB);
            disp('Done');
        end

%         function obj = evaluation(obj)
%             obj.detectionResults = detect(obj.detector, obj.im,...
%                 'Threshold', 0, 'SelectStrongest', true, 'MiniBatchSize', 1);
%     %         detectionResults_test = detect_fasterrcnn(detector, dataTest);
%             [obj.ap_test, obj.recall_test, obj.precision_test] = evaluateDetectionPrecision(...
%                                                 obj.detectionResults,...
%                                                 obj.dataTest_preprocess,...
%                                                 0.5);
%           
%             % Recall / precision 
%             [obj.recall, obj.precision, obj.tp, obj.re, obj.pre] = recall_precision_new(...
%                         obj.detectionResults_test, obj.dataTest_preprocess,...
%                         obj.inputImageSize, obj.inputImageSize);
%         end

        function obj = cam(obj)
        end
    end
end