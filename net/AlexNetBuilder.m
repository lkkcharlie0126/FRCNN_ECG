classdef AlexNetBuilder < LgraphBuilder
    methods
        function obj = AlexNetBuilder()
            obj.featureLayer = 'relu5';
            obj.network = 'alexnet';
            obj.networkBasic = 'alexnet';
        end
    end
end