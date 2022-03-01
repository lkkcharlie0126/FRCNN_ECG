%% Last editted: 2022. 02. 18
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))
addpath(genpath('net'))


frcnnTrainner = TrainFRCNN;

frcnnTrainner.set_timeWindow = '10sec_square';
frcnnTrainner.lgraphBuilder = ResnetSelf2Builder;
frcnnTrainner.epoch = 1;
frcnnTrainner.minibatchsize = [2];
frcnnTrainner.inputImageSize = [227 227 3];
frcnnTrainner.foldNum = 5;
frcnnTrainner.anchorNum = 2;
frcnnTrainner.run();