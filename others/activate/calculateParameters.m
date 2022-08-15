clear all;
net_used = 'resnet50';
time_window = '10sec';
fold = 1;
savePath = 'D:\Win\WTMH\PAG_group\mitbih_5class\Result\FasterRCNN\';
load([savePath, time_window, '\', net_used, '_0.7_twcc_200\fold', int2str(fold), '\result.mat']);
detector = obj.detector;
analyzeNetwork(detector.Network)

layers = detector.Network.Layers;
parameters = zeros(size(layers, 1), 5);
for i = 1:size(layers, 1)
    if isprop(layers(i, 1), 'Weights')
        weightsSize = size(layers(i, 1).Weights);
        parameters(i, 1) = prod(weightsSize);
    end
    if isprop(layers(i, 1), 'Bias')
        biasSize = size(layers(i, 1).Bias);
        parameters(i, 2) = prod(biasSize);
    end
    if isprop(layers(i, 1), 'Offset')
        offsetSize = size(layers(i, 1).Offset);
        parameters(i, 3) = prod(offsetSize);
    end
    if isprop(layers(i, 1), 'Scale')
        scaleSize = size(layers(i, 1).Scale);
        parameters(i, 4) = prod(scaleSize);
    end
    parameters(i, 5) = sum(parameters(i, 1:4));
end
totalParameters = sum(parameters(:, 5))