classdef ResnetSelf2Builder < LgraphBuilder
    methods
        function obj = ResnetSelf2Builder()
            obj.featureLayer = 'activation_19_relu';
            obj.network = 'resnetSelf2';
            obj.networkBasic = 'resnet50';
        end

        function obj = adjustLayers(obj)
             % Self-designed

            obj.lgraph = disconnectLayers(obj.lgraph, 'add_1', 'activation_4_relu');
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_3', 'activation_10_relu');
            
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_4', 'activation_13_relu');
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_6', 'activation_19_relu');

            obj.lgraph = disconnectLayers(obj.lgraph, 'add_8', 'activation_25_relu');
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_13', 'activation_40_relu');

            obj.lgraph = disconnectLayers(obj.lgraph, 'add_14', 'activation_43_relu');
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_16', 'activation_49_relu');

            obj.lgraph = connectLayers(obj.lgraph, 'add_1', 'activation_10_relu');
            obj.lgraph = connectLayers(obj.lgraph, 'add_4', 'activation_19_relu');
            obj.lgraph = connectLayers(obj.lgraph, 'add_8', 'activation_40_relu');
            obj.lgraph = connectLayers(obj.lgraph, 'add_14', 'activation_49_relu');

            % Remove unneed
            layersToRemove = {};
            layerNum = [4:9, 13:18, 25:39, 43:48];
            for i = 1:length(layerNum)
                layersToRemove = [layersToRemove, ['activation_', int2str(layerNum(i)), '_relu']];
            end

            layerNum = [2, 3, 5, 6, 9:13, 15, 16];
            for i = 1:length(layerNum)
                layersToRemove = [layersToRemove, ['add_', int2str(layerNum(i))]];
            end

            % 2
            toDelete = ['bc'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res2', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn2', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end
            % 3
            toDelete = ['bc'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res3', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn3', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end
            
            % 4
            toDelete = ['bcdef'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res4', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn4', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end

            % 5
            toDelete = ['bc'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res5', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn5', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end
            
            % Remove
            obj.lgraph = removeLayers(obj.lgraph, layersToRemove);
        end
    end
end