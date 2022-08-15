classdef AlexnetBuilder < LgraphBuilder
    methods
        function obj = AlexnetBuilder()
            obj.featureLayer = 'relu5';
            obj.network = 'alexnet';
            obj.networkBasic = 'alexnet';
        end
    end
end