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
ecgDetector.timeWindow = '20sec';
ecgDetector.network = 'resnetSelf2_0.7_twcc';
ecgDetector = ecgDetector.loadNet();

%%
ecgDetector.subjectNum = '102';
ecgDetector.winNum = '20';


ecgDetector = ecgDetector.loadData();
ecgDetector = ecgDetector.plotSignal();

ecgDetector = ecgDetector.detecting();