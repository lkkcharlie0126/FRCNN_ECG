clear all;
close all;
%% Path setting
path_folder = 'D:\Win\WTMH\PAG_group\mitbih_5class\AAMI';
folder_save = 'D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec_no_overlap';
%% Total subject list
subject_list = {dir(fullfile(path_folder,'*.txt')).name}';


diseases = ["SR", "APC", "VPC", "LBBB", "RBBB", "Others"];
bubbleColor = ["r", "g", "b" , "c", "m", "y"];
subjectLength = length(subject_list);
for k = 1:subjectLength % For each subject
    %% File path
    subject = string(['S', subject_list{k}(1:3)]);
    file_txt = [path_folder, '\', subject_list{k}];
    file_mat = [file_txt(1:end-3), 'mat'];
    formatSpec = '%12s%9s%6s%5s%5s%s%[^\n\r]';
    fileID = fopen(file_txt,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
    dataArray{1} = strtrim(dataArray{1});
    fclose(fileID);
    %% Clear temporary variables
    clearvars fileID formatSpec ans ;
    
    %% Load .mat data
    load(file_mat);
    raw_data = val(1,:)';
    
    %% Sample number and label
    label = char(dataArray{1,3}(2:end));
    label = label(:,end);
    sample = str2num(char(dataArray{1,2}(2:end)));
    
    diseaseNumber = zeros(1, 6);
    diseaseNumber(1) = length(find((label == 'N') | (label == '·')));
    diseaseNumber(2) = length(find(label == 'A'));
    diseaseNumber(3) = length(find(label == 'V'));
    diseaseNumber(4) = length(find(label == 'L'));
    diseaseNumber(5) = length(find(label == 'R'));
    diseaseNumber(6) = length(label) - length(find(label == '+')) - sum(diseaseNumber(1:5));
    
    for i = 1:length(diseaseNumber)
        if diseaseNumber(i) > 0 
            bubblechart(categorical(subject), categorical(diseases(i)),...
                diseaseNumber(i), bubbleColor(i));
            hold on
        end
    end
end
% blgd = bubblelegend('Beat number', 'Style','telescopic');
lgd = legend('SR','APC', 'VPC', 'LBBB', 'RBBB', 'Others');
lgd.Location = 'northeastoutside';
% blgd.Location = 'northeastoutside';
grid on
hold off;

blgd.Layout.Tile = 'east';
