classdef ResnetSelf2SmallBuilder < ResnetSelf2Builder
    methods
        function obj = ResnetSelf2SmallBuilder()
            obj.featureLayer = 'activation_19_relu';
            obj.network = 'resnetSelf2Small';
            obj.networkBasic = 'resnet50';
        end

        function obj = build(obj, dataTrain, anchorNum, inputImageSize, numClasses)
            % Estimate anchor box size
            [obj.anchorBoxes, ~] = estimateAnchorBoxes(dataTrain,...
                anchorNum);
            
            % Build Lgraph
            obj.lgraph = fasterRCNNLayers(inputImageSize,numClasses,...
                obj.anchorBoxes, obj.networkBasic, obj.featureLayer, "ROIOutputSize",[8 8]);
            obj = obj.adjustLayers();
            disp(['===================== ', obj.network, ' ======================'])
        end
    end
end