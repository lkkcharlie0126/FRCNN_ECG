function T_kfold = kfold_for_faster_rcnn(T_used, fold_num)
%% kfold
numClasses = size(T_used,2)-1;
% 找出所有疾病出現的index
idx_all = zeros(size(T_used,1),numClasses);
for i = 1:size(T_used,1)
    for j = 1:numClasses
        if length(T_used{i,j+1}{1}) ~= 0
            idx_all(i,j) = 1;
        end
    end
end
% 計算各類疾病出現的次數，並從小到大排序
each_classes_num = [];
for i = 1:numClasses
    each_classes_num = [each_classes_num, length(find(idx_all(:,i) == 1))];
end
[~, idx_classes_num] = sort(each_classes_num);

% 將重複的index設成0(較少出現的類別優先保留)
idx_only = idx_all;
for i = 1:length(idx_classes_num)
    idx_only(idx_only(:, idx_classes_num(i)) == 1, idx_classes_num(idx_classes_num ~= idx_classes_num(i))) = 0;
end
% 切5fold
fold = fold_num;
T_kfold = [];
for k = 1:fold
    T_kfold{k} = [];
end
for i = 1:numClasses
    idx = find(idx_only(:,i) == 1);
    length_idx = length(idx);
    idx_rand = randperm(length_idx);
    fold_length = floor(length_idx/fold);
    fold_rest = mod(length_idx, fold);
    idx_start = 1;
    for k = 1:fold
        if k <= fold_rest
            idx_end = idx_start + fold_length;
        else
            idx_end = idx_start + fold_length - 1;
        end
        T_kfold{k} = [T_kfold{k}; idx(idx_rand(idx_start:idx_end))];
        idx_start = idx_end + 1;
    end
end

%% 