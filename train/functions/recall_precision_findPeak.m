function [recall, precision, tp, re, pre] = recall_precision_findPeak(result, truth, inputImageSize, original_size)
% result= detectionResults_test;
% truth = dataTest_preprocess;

score_threshold = 0.5;
iou_threshold = 0.5;
scale = inputImageSize(1:2)./original_size(1:2);

truth = truth.UnderlyingDatastores{1, 2}.LabelData;
tp = [0,0,0,0,0,0,0,0];
pre = [0,0,0,0,0,0,0,0];
re = [0,0,0,0,0,0,0,0];



for i = 1:size(result,1) % Each image
    repeat = zeros(1,size(truth{i, 2}, 1));
    repeat_m = zeros(1,size(truth{i, 2}, 1));
    
    % Precision
    for j = 1:length(result{i,3}{1}) % Each peak
        if result{i,2}{1}(j) >= score_threshold
            pre(7) = pre(7) + 1;
            flag_7 = 0;
            for k = 1:size(truth{i, 2}, 1) % Each ground truth
                box_r = bboxresize(truth{i, 1}(k,:), scale);

                if (bboxOverlapRatio(box_r, result{i,1}{1}(j,:)) >= iou_threshold) && repeat(k) == 0
                    if repeat(k) == 0
                        flag_7 = 1;
                        repeat(k) = 1;
                    end
                    if truth{i, 2}(k,:) == result{i,3}{1}(j) && repeat_m(k) == 0
                        repeat_m(k) = 1;
                        break;
                    end
                end
            end
            tp(7) = tp(7) + flag_7;
        end
    end
    
    % Recall
    for j = 1:size(truth{i, 2}, 1)
        re(7) = re(7) + 1;
    end
end

% Result
precision = tp ./ pre;
recall = tp ./ re;
end

