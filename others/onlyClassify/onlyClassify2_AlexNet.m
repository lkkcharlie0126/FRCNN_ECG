clear all;
%%
frcnnTrainner = TrainFRCNN;

frcnnTrainner.set_timeWindow = '10sec';
frcnnTrainner.lgraphBuilder = AlexnetBuilder;
frcnnTrainner.inputImageSize = [227 681 3];
frcnnTrainner.foldNum = 5;
frcnnTrainner.foldRun = [1];
frcnnTrainner.anchorNum = 3;
frcnnTrainner.notes = '';
frcnnTrainner.isBalanced = 0;

frcnnTrainner.folder_parent = 'D:\Win\WTMH\PAG_group\mitbih_5class';
frcnnTrainner = frcnnTrainner.setup();
frcnnTrainner = frcnnTrainner.loadData();
%% 
load('D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\10sec\alexnet_0.7_twcc_200\fold1\result.mat')
detector = obj.detector;
allLayers = detector.Network.layerGraph;
% analyzeNetwork(allLayers);
newLayers_1 = disconnectLayers(allLayers, 'relu5', 'rpnConv3x3');
newLayers_1 = disconnectLayers(newLayers_1, 'relu5', 'roiPooling/in');

layersToRemove = {};
for i = 16:35
    layersToRemove = [layersToRemove, newLayers_1.Layers(i).Name];
end
newLayers_1 = removeLayers(newLayers_1, layersToRemove);

newLayers_1 = addLayers(newLayers_1, regressionLayer('Name','routput'));
newLayers_1 = connectLayers(newLayers_1, 'relu5', 'routput');

inputMeanLayer_1 = newLayers_1.Layers(1).Mean;


% analyzeNetwork(newLayers_1)
newNet = assembleNetwork(newLayers_1);

%%
newLayers_2 = allLayers;
layersToRemove = {};
idx_layer = [1:21, 30, 32, 33:35];
for i = 1:length(idx_layer)
    layersToRemove = [layersToRemove, newLayers_2.Layers(idx_layer(i)).Name];
end
newLayers_2 = removeLayers(newLayers_2, layersToRemove);

newLayers_2 = addLayers(newLayers_2, imageInputLayer([6, 6, 256], "Normalization","none"));
newLayers_2 = connectLayers(newLayers_2, 'imageinput', 'fc6');

% analyzeNetwork(newLayers_2)
newNet2 = assembleNetwork(newLayers_2);
%%
groundTruth = [];
predicted = [];
predictedClass = [];

for i = 1:size(frcnnTrainner.T_used, 1)
    im = imread(frcnnTrainner.T_used{i, 1}{1});
    activate = activations(newNet,im,'relu5');
    for j = 2:7
        for k = 1:size(frcnnTrainner.T_used{i, j}{1}, 1)
            groundTruth = [groundTruth; j-1];
            beatLoc = frcnnTrainner.T_used{i, j}{1}(k, :);
            beatLoc(:, 3:4) = beatLoc(:, 3:4) + beatLoc(:, 1:2);
            beatLocFeatureMap = (beatLoc - 1) .* [40/680, 12/226, 40/680, 12/226] + 1;
            roiOut = visiongpuROIMaxPoolingForward(gpuArray(activate), double([beatLocFeatureMap, 1])', 6, 6);

            output = activations(newNet2, gather(roiOut),'rcnnClassification');
            output = reshape(output, [1, 7]);
            predicted = [predicted; output];
            [~, class] = max(output);
            predictedClass = [predictedClass; class];
        end
    end
end
accuracy = sum(groundTruth == predictedClass,'all')/numel(predictedClass)
cMatrix = confusionmat(groundTruth,predictedClass);

saveName = ['D:\Win\WTMH\PAG_group\mitbih_5class\Result\onlyClassify', '\', 'alexnet_', frcnnTrainner.set_timeWindow, '.mat'];
save(saveName, 'groundTruth', 'predictedClass', 'cMatrix', 'accuracy', 'predicted')





  


