%% Last editted: 2022.01.27
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('dataCutter'))
addpath(genpath('iterator'))
addpath(genpath('train'))


dataCutter = DataCutter_BboxOnly;
dataCutter.slash = '/';
dataCutter.isResize = 1;
dataCutter.folder_saveName = '30sec';
% dataCutter.wanted_img_size = [227, 227, 3];
dataCutter.istwcc = 1;
dataCutter.time_window = 30;
dataCutter.step_window = 30;



dataCutter.run();