function [recall, precision, tp, re, pre] = recall_precision_new(result, truth, inputImageSize, original_size)
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
            switch result{i,3}{1}(j)
                case 'SR'
                    pre(1) = pre(1) + 1;
                case 'APC'
                    pre(2) = pre(2) + 1;
                case 'VPC'
                    pre(3) = pre(3) + 1;
                case 'LBBB'
                    pre(4) = pre(4) + 1;
                case 'RBBB'
                    pre(5) = pre(5) + 1;
                case 'Others'
                    pre(6) = pre(6) + 1;
            end
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
                        switch result{i,3}{1}(j)
                            case 'SR'
                                tp(1) = tp(1) + 1;
                            case 'APC'
                                tp(2) = tp(2) + 1;
                            case 'VPC'
                                tp(3) = tp(3) + 1;
                            case 'LBBB'
                                tp(4) = tp(4) + 1;
                            case 'RBBB'
                                tp(5) = tp(5) + 1;
                            case 'Others'
                                tp(6) = tp(6) + 1;
                        end
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
        switch truth{i, 2}(j)
            case 'SR'
                re(1) = re(1) + 1;
            case 'APC'
                re(2) = re(2) + 1;
            case 'VPC'
                re(3) = re(3) + 1;
            case 'LBBB'
                re(4) = re(4) + 1;
            case 'RBBB'
                re(5) = re(5) + 1;
            case 'Others'
                re(6) = re(6) + 1;
        end
    end
end
% Average 
tp(8) = sum(tp(1:6));
pre(8) = pre(7);
re(8) = re(7);

% Result
precision = tp ./ pre;
recall = tp./re;
end

