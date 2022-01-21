%% Last editted: 2021.01.20
%% by Wen Tzu Chien
%%
classdef TrainFRCNN
    properties
        slash = '\';
        % Path setting
        set_box_width = ["0.7"];
        set_timeWindow = '20sec';
        folder_parent = fileparts(fileparts(cd));
        path_folder
        path_result
        % Model setting
        learningrate = 1e-4;
        minibatchsize = [2];
        epoch = 20;
        network = ["alexnet"];
        inputImageSize = [227 681 3];
        anchorNum = 3;
        foldNum = 5;

        T_used
        numClasses
        windows_num
        T_kfold
        thisFold

        dataTest_preprocess
        dataTrain_preprocess
        dataNum_Train
        dataNum_Test

        lgraph
        options
        info
        detector
        path_save_var
    end
    methods
        function obj = TrainFRCNN()
            rng(1)
        end

        function obj = run(obj)
            obj = obj.setup();
            obj = obj.loadData();
            obj = obj.kfold();
            obj = obj.iterateEachFold();
            
        end

        function obj = setup(obj)
            obj.path_folder = [obj.folder_parent, obj.slash, 'data', obj.slash,...
                obj.set_timeWindow, obj.slash, 'box', obj.slash, 'new', obj.slash, 'matlab'];
            obj.path_result = [obj.folder_parent, obj.slash, 'Result', obj.slash,...
                'FasterRCNN', obj.slash, obj.set_timeWindow];
        end

        function obj = loadData(obj)
            path_width = [obj.path_folder, obj.slash, obj.set_box_width{1}];
            subject_list = {dir(fullfile(path_width)).name}';
            subject_list = subject_list(3:end);
            T_all = [];
            for subject = 1:length(subject_list)
                load([path_width, obj.slash, subject_list{subject}, obj.slash, 'T_',...
                    subject_list{subject}, '.mat']);
                T_all = [T_all ; bboxTable];
            end
            % Select data to use
%             [T_used, eachClassBeatNum] = balanceData(T_all, 2355);
            obj.T_used = T_all;
            % Remove bbox with 0 height
            obj.T_used = remove0heightbbox(obj.T_used);
            obj.numClasses = size(obj.T_used,2)-1;
            obj.windows_num = size(obj.T_used,1);
        end

        function obj = kfold(obj)
            rng(1)
            shuffledIdx = randperm(size(obj.T_used, 1));
            obj.T_used = obj.T_used(shuffledIdx,:);
            obj.T_kfold = kfold_for_faster_rcnn(obj.T_used, obj.foldNum);
        end

        function obj = iterateEachFold(obj)
            iteratorFold = Iterator;
            iteratorFold.list = [1 : obj.foldNum];
            iteratorFold = iteratorFold.first();
            while(~iteratorFold.isDone())
                obj.thisFold = iteratorFold.currentItem();

                disp(['====================== Fold: ', int2str(obj.thisFold), ' ===============================']);
                obj = obj.dataArrangement();
                obj.displayExample();
                obj = obj.buildLgraph;
                obj = obj.applyClassWeights();
                obj = obj.trainingOptions()
                obj = obj.train();
                obj.evaluation();

                iteratorFold = iteratorFold.next();
            end
        end

        function obj = dataArrangement(obj)
            % Testing data
            % Logical index
            idx_test = zeros(obj.windows_num,1);
            idx_test(obj.T_kfold{obj.thisFold}) = 1;
            idx_test = logical(idx_test);
            
            imdsTest = imageDatastore(obj.T_used{idx_test,'imageFilename'});
            bldsTest = boxLabelDatastore(obj.T_used(idx_test,2:obj.numClasses+1));
            dataTest = combine(imdsTest,bldsTest);
            obj.dataTest_preprocess = dataTest;
            obj.dataNum_Test = length(dataTest.UnderlyingDatastores{1, 1}.Files);
            
            % Training data
            imdsTrain = imageDatastore(obj.T_used{~idx_test,'imageFilename'});
            bldsTrain = boxLabelDatastore(obj.T_used(~idx_test,2:obj.numClasses+1));
            dataTrain = combine(imdsTrain,bldsTrain);
            obj.dataTrain_preprocess = dataTrain;
            obj.dataNum_Train = length(dataTrain.UnderlyingDatastores{1, 1}.Files);
        end

        function displayExample(obj)
            data = read(obj.dataTrain_preprocess);
            I = data{1};
            bbox = data{2};
            annotatedImage = insertShape(I,'Rectangle',bbox);
            annotatedImage = imresize(annotatedImage,2);
            figure
            imshow(annotatedImage)
        end

        function obj = buildLgraph(obj)
            disp(['=============================', obj.network{1}, '==============================']);
            switch obj.network{1}
                case 'alexnet'
                    featureLayer = 'relu5';
                case 'googlenet'
                    featureLayer = 'inception_4d-output';
                case 'resnet50'
                    featureLayer = 'activation_40_relu';
            end
            % Estimate anchor box size
            [anchorBoxes, ~] = estimateAnchorBoxes(obj.dataTrain_preprocess, obj.anchorNum);
            % Build Lgraph
            obj.lgraph = fasterRCNNLayers(obj.inputImageSize,obj.numClasses,anchorBoxes, ...
                                      obj.network{1},featureLayer);
%             analyzeNetwork(lgraph)
        end

        function obj = applyClassWeights(obj)
            classes = ["SR", "APC", "VPC", "LBBB", "RBBB", "Others", "background"];
            classWeights = [0.05, 0.2, 0.15, 0.15, 0.15, 0.15, 0.15];
            obj.lgraph = applyClassWeights(obj.lgraph, classes, classWeights, obj.network(1));
        end

        function obj = trainingOptions(obj)
            obj.path_save_var = [obj.path_result, obj.slash,...
                obj.network{1},'_', obj.set_box_width{1}, obj.slash,...
                'fold', int2str(obj.thisFold)];
            mkdir(obj.path_save_var)
            mkdir([obj.path_save_var, obj.slash, 'checkpoint'])
            
            obj.options = trainingOptions('sgdm', ...
            'MiniBatchSize', obj.minibatchsize(1), ...
            'InitialLearnRate', obj.learningrate, ...
            'MaxEpochs', obj.epoch, ...
            'VerboseFrequency',  round((obj.dataNum_Train/ obj.minibatchsize(1))/10))%, ...
%             'CheckpointPath', [path_save_var, '\', 'checkpoint'])%,...
%                     'ValidationData',dataVal_preprocess,...
%                     'ValidationFrequency', round(dataNum_Test),...
%                     'ValidationPatience', Inf)
        end

        function obj = train(obj)
            [obj.detector, obj.info] = trainFasterRCNNObjectDetector(...
                obj.dataTrain_preprocess, obj.lgraph, obj.options,...
                                'NegativeOverlapRange',[0 0.6], ...
                                'PositiveOverlapRange',[0.8 1],...
                                'NumStrongestRegions', 2000,...
                                'NumRegionsToSample', [16, 16]);
        end

        function evaluation(obj)
            %Training
            detectionResults_train = detect(obj.detector, obj.dataTrain_preprocess,...
                'Threshold', 0, 'SelectStrongest', true, 'MiniBatchSize', 1);
            [ap_train, recall_train, precision_train] = evaluateDetectionPrecision(...
                                                detectionResults_train,...
                                                obj.dataTrain_preprocess,...
                                                0.5);
            % Testing
            detectionResults_test = detect(obj.detector, obj.dataTest_preprocess,...
                'Threshold', 0, 'SelectStrongest', true, 'MiniBatchSize', 1);
    %         detectionResults_test = detect_fasterrcnn(detector, dataTest);
            [ap_test, recall_test, precision_test] = evaluateDetectionPrecision(...
                                                detectionResults_test,...
                                                obj.dataTest_preprocess,...
                                                0.5);
          
            % Recall / precision 
            [recall, precision, tp, re, pre] = recall_precision_new(...
                        detectionResults_test, obj.dataTest_preprocess,...
                        obj.inputImageSize, obj.inputImageSize);

            % Plot recall-precision curve
    %         figure
    %         plot(recall_test{1},precision_test{1})
    %         xlabel('Recall')
    %         ylabel('Precision')
    %         grid on
    %         title(sprintf('Average Precision = %.2f', ap_test(1)))
    %         
    %         figure
    %         plot(recall_val{1},precision_val{1})
    %         xlabel('Recall')
    %         ylabel('Precision')
    %         grid on
    %         title(sprintf('Average Precision = %.2f', ap_val(1)))
            detector = obj.detector;
            info = obj.info;
            save([obj.path_save_var, obj.slash, 'result.mat'],...
                'detector', 'info', 'detectionResults_train','detectionResults_test',...
                'ap_train', 'ap_test', 'recall_train', 'recall_test', 'precision_train', 'precision_test',...
                'recall', 'precision', 'tp', 'pre', 're');
        end
    end
end