% clear all;

resultPath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\10sec\findPeak_0.7_3_4';
foldNum = 1;
averageResult = [];
fold = [1, 2, 3, 4, 5];

for j = 1:length(fold)%5:5%1:foldNum
    load([resultPath, '\fold', int2str(fold(j)), '\result.mat'])
    recall = obj.recall;
    precision = obj.precision;
    ap_test = obj.ap_test;
    
    final_result = [];
    final_result = [recall(7), precision(7)];
    averageResult = [averageResult; final_result];
end
meanFoldResult = mean(averageResult);
[meanFoldResult, 2*meanFoldResult(1)*meanFoldResult(2) /...
    (meanFoldResult(1) + meanFoldResult(2))]