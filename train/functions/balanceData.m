function [T_balanced, eachClassBeatNumAdd] = balanceData(T_used, targetImgNum)
%% 計算table中各class的beat數
classNum = size(T_used,2)-1;
imgNum = size(T_used,1);
eachClassBeatNum = zeros(1,classNum);
for index_class = 1:classNum
    for index_img = 1:imgNum
        eachClassBeatNum(index_class) = eachClassBeatNum(index_class) + size(T_used{index_img,index_class+1}{1}, 1);
    end
end

%% Random remove img to balance beats number
% targetImgNum = 6000;
eachClassBeatNumAdd = zeros(1, classNum);
rng(1)
index_img_rand = randperm(imgNum);
T_rand = T_used(index_img_rand,:);
[~, index_class_sort] = sort(eachClassBeatNum);
read_index = [];
keep_index = [];
for index_class = 1:classNum
    thisCollum = index_class_sort(index_class)+1;
    for index_img = 1:imgNum
        if ~ismember(index_img, read_index) && (size(T_rand{index_img, thisCollum}{1}, 1) > 0) % 判斷此img是否含有此疾病
            if (eachClassBeatNumAdd(thisCollum-1) < targetImgNum)% beat數還不到
                keep_index = [keep_index, index_img];
                for index_class2 = 1:classNum
                    eachClassBeatNumAdd(index_class2) = eachClassBeatNumAdd(index_class2) + size(T_rand{index_img, index_class2+1}{1}, 1);
                end
            end
            read_index = [read_index, index_img];
        end
    end
end

T_balanced = T_rand(keep_index, :);
end
%%