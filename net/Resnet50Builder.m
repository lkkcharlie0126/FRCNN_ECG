classdef Resnet50Builder < LgraphBuilder
    methods
        function obj = Resnet50Builder()
            obj.featureLayer = 'activation_40_relu';
            obj.network = 'resnet50';
            obj.networkBasic = 'resnet50';
        end
    end
end