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
dataCutter.folder_saveName = '5sec';
% dataCutter.wanted_img_size = [227, 227, 3];
dataCutter.istwcc = 0;
dataCutter.time_window = 5;
dataCutter.step_window = 5;



dataCutter.run();