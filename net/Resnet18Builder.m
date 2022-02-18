classdef Resnet18Builder < LgraphBuilder
    methods
        function obj = Resnet18Builder()
            obj.featureLayer = 'res4b_relu';
            obj.network = 'resnet18';
            obj.networkBasic = 'resnet18';
        end
    end
end