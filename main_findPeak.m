%% Last editted: 2022. 03. 07
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))
addpath(genpath('net'))


frcnnTrainner = FindPeakAlgo3_4;

frcnnTrainner.set_timeWindow = '10sec';
frcnnTrainner.inputImageSize = [227 681 3];
frcnnTrainner.foldNum = 5;
frcnnTrainner.notes = '';

frcnnTrainner.run();