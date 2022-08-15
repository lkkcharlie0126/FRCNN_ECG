clear all;
load('D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\5sec\alexnet_0.7_twcc_200\fold1\result.mat')
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