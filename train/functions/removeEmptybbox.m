    %% Remove empty bbox 
    function T_used = removeEmptybbox(T_used)
    
    for t = 1:size(T_used, 1)
        isEmpty = 1;
        for c = 2:size(T_used, 2)
            this_bbox = T_used{t, c}{1};
            if size(this_bbox, 1) == 0
                continue;
            end
            isEmpty = 0;
        end
        if isEmpty == 1
            T_used(t, :) = [];
            disp('Emptyy')
        end
    end
    end