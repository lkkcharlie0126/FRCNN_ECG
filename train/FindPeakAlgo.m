classdef FindPeakAlgo < TrainFRCNN
    properties
        pathTestData
        Fs = 360;
        widthLeft
        widthRight
        interval_ecg = 0.3;
        min_peak = 0.7;
        name
    end
    methods
        function obj = FindPeakAlgo()
            obj.widthLeft = round(0.307 * obj.Fs);
            obj.widthRight = round(0.404 * obj.Fs);
        end
        function obj = iterateEachFold(obj)
            iteratorFold = Iterator;
            iteratorFold.list = obj.foldRun;
            iteratorFold = iteratorFold.first();
            while(~iteratorFold.isDone())
                obj.thisFold = iteratorFold.currentItem();

                disp(['====================== Fold: ', int2str(obj.thisFold), ' ===============================']);
                obj = obj.dataArrangement();
%                 obj.displayExample();

                obj.pathTestData = obj.dataTest_preprocess.UnderlyingDatastores{1, 1}.Files;
                obj.detectionResults_test = table('Size',[length(obj.pathTestData), 3],'VariableTypes',{'cell', 'cell', 'cell'});
                obj.detectionResults_test.Properties.VariableNames = [{'Boxes'}, {'Scores'}, {'Labels'}];

                obj = obj.iterateEachWindow();
                
                obj = obj.evaluation();
                obj.saveResult();

                iteratorFold = iteratorFold.next();
            end
        end

        function obj = iterateEachWindow(obj)
            for i = 1:length(obj.pathTestData)
                thisPath = obj.pathTestData{i};
                pos = findstr(thisPath, 'signal_resize');
                thisPathMat = [thisPath(1:pos-1), 'mat', thisPath(pos+13:end-4), '.mat'];
                signal = load(thisPathMat).signal_10s;
                [Ramp, Rpeak, signal] = obj.findPeak(signal, obj.Fs);
                [bboxWindow, scoresWindow, labelsWindow] = obj.axis2bbox(Rpeak, signal);

                obj.detectionResults_test{i, 1:3} = [{bboxWindow}, {scoresWindow}, {labelsWindow}];
                if mod(i, 100) == 0
                    disp([int2str(i), '/', int2str(length(obj.pathTestData))]);
                end
            end
            disp([int2str(length(obj.pathTestData)), '/',...
                int2str(length(obj.pathTestData))]);
        end

        function [Ramp, Rpeak, signal] = findPeak(obj, signal, s_rate)
            signal = (signal - min(signal))/max(signal-min(signal));
        
            min_interval = obj.interval_ecg * s_rate;

%             t = (1:length(signal))/s_rate; % Time
            [Ramp,Rpeak,~,~]  = findpeaks(signal,'MinPeakDistance',...
                min_interval, 'MinPeakHeight', obj.min_peak);
            
%             f1 = figure(1);
%             plot(t, signal); hold on;
%             plot(Rpeak/s_rate, Ramp, '*');
%             close(f1)
        end

        function [bboxWindow, scoresWindow, labelsWindow] = axis2bbox(obj, Rpeak, signal)
            bboxWindow = zeros(length(Rpeak), 4);
            for beat = 1:length(Rpeak)
                box_left = max(Rpeak(beat) - obj.widthLeft, 1);
                box_right = min(Rpeak(beat) + obj.widthRight, 3600);

                box_min = max(min(signal(box_left:box_right)), 0);
                box_max = min(max(signal(box_left:box_right)), 1);

                box_width = box_right - box_left;
                box_height = box_max - box_min;

                % signal_coordinate to image_coordinate for matlab
                box_left_img = round((box_left-1)*(obj.inputImageSize(2)-1)/(length(signal)-1)+1);
                box_max_img = round((obj.inputImageSize(1) + 1) - (box_max*(obj.inputImageSize(1)-1)+1));
                box_width_img = round(box_width*(obj.inputImageSize(2)-1)/(length(signal)-1));
                box_height_img = round(box_height*(obj.inputImageSize(1)-1));
                box_pos_img = [box_left_img,...
                    box_max_img,...
                    box_width_img,...
                    box_height_img];
%                     max(box_width_img, 1),...
%                     max(box_height_img, 1)];
                
                bboxWindow(beat,:) = box_pos_img;
            end
            scoresWindow = ones(length(Rpeak), 1);
            labelsWindow = categorical(ones(length(Rpeak), 1));
        end

        function obj = evaluation(obj)
            disp('Evaluating...');
            % Recall / precision 
            [obj.recall, obj.precision, obj.tp, obj.re, obj.pre] = recall_precision_findPeak(...
                        obj.detectionResults_test, obj.dataTest_preprocess,...
                        obj.inputImageSize, obj.inputImageSize);
            disp('End');
        end

        function obj = saveResult(obj)
            obj.path_save_var = [obj.path_result, obj.slash,...
                'findPeak', '_', obj.set_box_width{1}, '_', obj.name, obj.notes, obj.slash,...
                'fold', int2str(obj.thisFold)];
            mkdir(obj.path_save_var)
            save([obj.path_save_var, obj.slash, 'result.mat'], 'obj');
        end
    end
end