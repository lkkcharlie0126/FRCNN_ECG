classdef GooglenetBuilder < LgraphBuilder
    methods
        function obj = GooglenetBuilder()
            obj.featureLayer = 'inception_4d-output';
            obj.network = 'googlenet';
            obj.networkBasic = 'googlenet';
        end
    end
end