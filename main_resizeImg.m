%% Last editted: 2022.01.27
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('iterator'))
addpath(genpath('imageResizer'))

imageResizer = ImageResizer;
imageResizer.folderOriginal = '5sec\signal_resize';
imageResizer.folderNew = '5sec_120\signal_resize';
imageResizer.wantedSize = [120, 120];

imageResizer =imageResizer.setPath();
imageResizer.iterateEachSubject()