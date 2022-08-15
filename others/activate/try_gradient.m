% get value of output and gradient
% net2 = dlnetwork(layerGraph(detector.Network));
layers = [ ...
    imageInputLayer([6 20 256], 'Name', 'input_roi', 'Normalization', 'none')
    detector.Network.Layers(22:24)
    ];
ll = dlnetwork(layerGraph(layers))


im = imread(dataVal_preprocess.UnderlyingDatastores{1, 1}.Files{3});
roi_out = activations(detector.Network,im,'roiPooling');
% 
% score_out = predict(ll,dlarray(roi_out(:,:,:,1), 'SSC'),'Outputs', 'rcnnSoftmax');
% score_out(1)
% roi_out = activations(dagnet,im,'roiPooling');
roi_out_1 = dlarray(roi_out(:,:,:,1), 'SSC');
[outp,gradients] = dlfeval(@Gradient_function, ll, roi_out_1);


function [roi_out_1,gradients] = Gradient_function(dlnet,roi_out_1)

score_out = predict(dlnet, roi_out_1,'Outputs', 'rcnnSoftmax');
loss = score_out(1);
gradients = dlgradient(loss,roi_out_1); % get gradient of loss with respect to conv_output
gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization

end 

% function called from dlfeval
% function [conv_output,gradients] = Gradient_function(net2,I2,softmaxlayer,activationlayer,class)
% [scores,conv_output] = predict(net2, I2, 'Outputs', {softmaxlayer, activationlayer}); % get score and output at defiend layer.
% loss = scores(class); %
% gradients = dlgradient(loss,conv_output); % get gradient of loss with respect to conv_output
% gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization
% end
