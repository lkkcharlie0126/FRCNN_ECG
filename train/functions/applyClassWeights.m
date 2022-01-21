function newNet = applyClassWeights(net, classes, classWeights, network)
newClassificationLayers = classificationLayer('Name','output', 'Classes', classes, 'ClassWeights',classWeights);
newNet = net;
newNet = addLayers(newNet, newClassificationLayers);
newNet = removeLayers(newNet, 'rcnnClassification');
switch network
    case 'alexnet'
        newNet = connectLayers(newNet, 'prob', 'output');
    case 'googlenet'
        newNet = connectLayers(newNet, 'rcnnSoftmax', 'output');
    case 'resnet50'
        newNet = connectLayers(newNet, 'rcnnSoftmax', 'output');
end
end