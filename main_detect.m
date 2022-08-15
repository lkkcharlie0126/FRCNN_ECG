%% Last editted: 2022. 02. 18
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))
addpath(genpath('net'))
addpath(genpath('detector'))


ecgDetector = ECGdetector;
ecgDetector.timeWindow = '5sec_260';
% ecgDetector.network = 'resnetSelf2_0.7_twcc';
% ecgDetector.network = 'resnetSelf2Small_0.7_twcc';

ecgDetector.network = 'resnet50_0.7_twcc';
% ecgDetector.network = 'googlenet_0.7_twcc';
% ecgDetector.network = 'alexnet_0.7_twcc';

ecgDetector = ecgDetector.loadNet();

%%
ecgDetector.subjectNum = '101';
n = 360;
% T = zeros(1,n);
tic
for i = 1:n
    ecgDetector.winNum = int2str(i);    
    ecgDetector = ecgDetector.loadData();
%     tic
    ecgDetector = ecgDetector.detecting();
%     T(i) = toc;
end
% sum(T)
toc