%% Last editted: 2021.01.20
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))

frcnnTrainner = TrainFRCNN;

frcnnTrainner.set_timeWindow = '10sec_square';
frcnnTrainner.network = ["resnet50"];
frcnnTrainner.epoch = 1;
frcnnTrainner.minibatchsize = [2];
frcnnTrainner.inputImageSize = [227 227 3];
frcnnTrainner.foldNum = 5;
frcnnTrainner.anchorNum = 2;
frcnnTrainner.run();