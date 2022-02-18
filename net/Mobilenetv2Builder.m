classdef Mobilenetv2Builder < LgraphBuilder
    methods
        function obj = Mobilenetv2Builder()
            obj.featureLayer = 'block_13_expand_relu';
            obj.network = 'mobilenetv2';
            obj.networkBasic = 'mobilenetv2';
        end
    end
end