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

frcnnTrainner.set_timeWindow = '10sec';
frcnnTrainner.lgraphBuilder = ResnetSelf2SmallBuilder;
frcnnTrainner.epoch = 2;
frcnnTrainner.minibatchsize = [1];
frcnnTrainner.inputImageSize = [227 681 3];
frcnnTrainner.foldNum = 5;
frcnnTrainner.foldRun = [1];
frcnnTrainner.anchorNum = 3;
frcnnTrainner.numStrongestRegions = 200; % 每張照片提取幾個bbox
frcnnTrainner.numRegionsToSample = [16, 16]; % 每張照片選幾個bbox計算loss [FirstStage , SecondStage]
frcnnTrainner.negativeOverlapRange = [0, 0.5];
frcnnTrainner.positiveOverlapRange = [0.5, 1];
frcnnTrainner.notes = '_epoch2_New2_anchor3';
frcnnTrainner.isBalanced = 1;

frcnnTrainner.run();