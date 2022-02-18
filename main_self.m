%% Last editted: 2022.01.20
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))

frcnnTrainner = TrainFRCNN;

frcnnTrainner.minibatchsize = [4];
frcnnTrainner.set_timeWindow = '10sec_square';
frcnnTrainner.epoch = 1;
frcnnTrainner.inputImageSize = [227 227 3];
frcnnTrainner.anchorNum = 4;
frcnnTrainner.network = ["resnetSelf2"];
frcnnTrainner.run();