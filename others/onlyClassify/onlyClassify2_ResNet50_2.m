clear all;
%%
frcnnTrainner = TrainFRCNN;

frcnnTrainner.set_timeWindow = '10sec';
frcnnTrainner.lgraphBuilder = Resnet50Builder;
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
load('D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\10sec\resnet50_0.7_twcc_200\fold1\result.mat')
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
%%
groundTruth = [];
predicted = [];
predictedClass = [];

for i = 1:size(frcnnTrainner.T_used, 1)
    im = imread(frcnnTrainner.T_used{i, 1}{1});
    activate = activations(newNet,im,'activation_40_relu');

    for j = 2:7
        for k = 1:size(frcnnTrainner.T_used{i, j}{1}, 1)
            groundTruth = [groundTruth; j-1];
            beatLoc = frcnnTrainner.T_used{i, j}{1}(k, :);
            beatLoc(:, 3:4) = beatLoc(:, 3:4) + beatLoc(:, 1:2);
            beatLocFeatureMap = (beatLoc - 1) .* [42/680, 14/226, 42/680, 14/226] + 1;
            roiOut = visiongpuROIMaxPoolingForward(gpuArray(activate), double([beatLocFeatureMap, 1])', 14, 14);

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

saveName = ['D:\Win\WTMH\PAG_group\mitbih_5class\Result\onlyClassify', '\', 'resnet50_', frcnnTrainner.set_timeWindow, '.mat'];
save(saveName, 'groundTruth', 'predictedClass', 'cMatrix', 'accuracy', 'predicted')



  


