classdef ResnetSelfBuilder < LgraphBuilder
    methods
        function obj = ResnetSelfBuilder()
            obj.featureLayer = 'activation_19_relu';
            obj.network = 'resnetSelf';
            obj.networkBasic = 'resnet50';
        end

        function obj = adjustLayers(obj)
            % Self-designed
            obj.lgraph = removeLayers(obj.lgraph, 'roiPooling');
            
            layer = roiMaxPooling2dLayer([29, 29], 'Name', 'roiPoolingNew');
            obj.lgraph = addLayers(obj.lgraph, layer);
            
            obj.lgraph = connectLayers(obj.lgraph, 'regionProposal', 'roiPoolingNew/roi');
            obj.lgraph = connectLayers(obj.lgraph, 'activation_19_relu', 'roiPoolingNew/in');
            obj.lgraph = connectLayers(obj.lgraph, 'roiPoolingNew', 'res3d_branch2a');
            obj.lgraph = connectLayers(obj.lgraph, 'roiPoolingNew', 'add_7/in2');

            obj.lgraph = disconnectLayers(obj.lgraph, 'add_7', 'activation_22_relu');
            obj.lgraph = disconnectLayers(obj.lgraph, 'add_16', 'activation_49_relu');
            obj.lgraph = connectLayers(obj.lgraph, 'add_7', 'activation_49_relu');
            
            obj.lgraph = removeLayers(obj.lgraph, 'fcBoxDeltas');
            layer = fullyConnectedLayer(24,'Name', 'fcBoxDeltasNew');
            obj.lgraph = addLayers(obj.lgraph, layer);
            obj.lgraph = connectLayers(obj.lgraph, 'avg_pool', 'fcBoxDeltasNew');
            obj.lgraph = connectLayers(obj.lgraph, 'fcBoxDeltasNew', 'boxDeltas');

            % Remove unneed
            layersToRemove = {};
            for i = 22:48
                layersToRemove = [layersToRemove, ['activation_', int2str(i), '_relu']];
            end
            for i = 8:16
                layersToRemove = [layersToRemove, ['add_', int2str(i)]];
            end
            % 4
            toDelete = ['abcdef'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res4', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn4', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end

            % 5
            toDelete = ['abc'];
            toDelete2 = ['abc'];
            for i = 1:length(toDelete)
                for j = 1:length(toDelete2)
                    layersToRemove = [layersToRemove, ['res5', toDelete(i), '_branch2', toDelete2(j)]];
                    layersToRemove = [layersToRemove, ['bn5', toDelete(i), '_branch2', toDelete2(j)]];
                end
            end

            % 1
            layersToRemove = [layersToRemove, 'res4a_branch1'];
            layersToRemove = [layersToRemove, 'res5a_branch1'];
            layersToRemove = [layersToRemove, 'bn4a_branch1'];
            layersToRemove = [layersToRemove, 'bn5a_branch1'];

            % Remove
            obj.lgraph = removeLayers(obj.lgraph, layersToRemove);
        end
    end
end