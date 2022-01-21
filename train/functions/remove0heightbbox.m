    %% Remove bbox with 0 height
    function T_used = remove0heightbbox(T_used)
    flag = 0;
    for t = 1:size(T_used, 1)
        this_bbox = T_used{t, 2}{1};
        for t2 = 1:size(this_bbox, 1)
            if this_bbox(t2, 4) == 0
                this_row = t2;
                flag = 1;
            end
        end
        if flag == 1
            this_bbox(this_row, :) = [];
            T_used{t, 2}{1} = this_bbox;
            flag = 0;
        end
    end
    end