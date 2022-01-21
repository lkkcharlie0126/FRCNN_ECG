%% Last editted: 2021.01.20
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))

% 
% dataCutter = DataCutter;
% dataCutter.slash = '/';
% dataCutter.folder_saveName = '20sec';
% dataCutter.istwcc = 0;
% dataCutter.time_window = 20;
% dataCutter.step_window = 20;
% 
% dataCutter.run();

frcnnTrainner = TrainFRCNN;
frcnnTrainner.run();