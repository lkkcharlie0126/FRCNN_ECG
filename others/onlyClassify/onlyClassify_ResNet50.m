clear all;
load('D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\5sec\resnet50_0.7_twcc_200\fold1\result.mat')
detector = obj.detector;
allLayers = detector.Network.layerGraph;
% analyzeNetwork(allLayers);
newLayers_1 = disconnectLayers(allLayers, 'activation_40_relu', 'rpnConv3x3');
newLayers_1 = disconnectLayers(newLayers_1, 'activation_40_relu', 'roiPooling/in');

layersToRemove = {};
for i = 142:188
    layersToRemove = [layersToRemove, newLayers_1.Layers(i).Name];
end
newLayers_1 = removeLayers(newLayers_1, layersToRemove);

newLayers_1 = addLayers(newLayers_1, regressionLayer('Name','routput'));
newLayers_1 = connectLayers(newLayers_1, 'activation_40_relu', 'routput');

inputMeanLayer_1 = newLayers_1.Layers(1).Mean;


% analyzeNetwork(newLayers_1)
newNet = assembleNetwork(newLayers_1);

%%
newLayers_2 = allLayers;
layersToRemove = {};
idx_layer = [1:147, 183, 185, 186:188];
for i = 1:length(idx_layer)
    layersToRemove = [layersToRemove, newLayers_2.Layers(idx_layer(i)).Name];
end
newLayers_2 = removeLayers(newLayers_2, layersToRemove);

newLayers_2 = addLayers(newLayers_2, imageInputLayer([14, 14, 1024], "Normalization","none"));
newLayers_2 = connectLayers(newLayers_2, 'imageinput', 'res5a_branch2a');
newLayers_2 = connectLayers(newLayers_2, 'imageinput', 'res5a_branch1');

% analyzeNetwork(newLayers_2)
newNet2 = assembleNetwork(newLayers_2);