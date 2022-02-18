%% Last editted: 2022.01.27
%% by Wen Tzu Chien
%%
clear all
close all;
addpath(genpath('iterator'))
addpath(genpath('imageResizer'))

imageResizer = ImageResizer;
imageResizer.folderOriginal = '20sec\signal_resize';
imageResizer.folderNew = '20sec_square\signal_resize';
imageResizer.wantedSize = [227, 227];

imageResizer =imageResizer.setPath();
imageResizer.iterateEachSubject()