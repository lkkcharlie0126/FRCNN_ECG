classdef LgraphBuilder
    properties
        featureLayer
        anchorBoxes
        lgraph
        network
        networkBasic
    end
    
    methods
        function obj = build(obj, dataTrain, anchorNum, inputImageSize, numClasses)
            % Estimate anchor box size
            [obj.anchorBoxes, ~] = estimateAnchorBoxes(dataTrain,...
                anchorNum);

            % Build Lgraph
            obj.lgraph = fasterRCNNLayers(inputImageSize,numClasses,...
                obj.anchorBoxes, obj.networkBasic, obj.featureLayer);
            obj = obj.adjustLayers();
            disp(['===================== ', obj.network, ' ======================'])
        end

        function obj = adjustLayers(obj)
            
        end
    end
end