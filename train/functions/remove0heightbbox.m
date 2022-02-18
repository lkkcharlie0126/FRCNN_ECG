    %% Remove bbox with 0 height
    function T_used = remove0heightbbox(T_used)
    flag = 0;
    
    for t = 1:size(T_used, 1)
        for c = 2:size(T_used, 2)
            this_bbox = T_used{t, c}{1};
            for t2 = 1:size(this_bbox, 1)
                if min(this_bbox(t2, :)) <= 0 %|| (this_bbox(t2, 1) + this_bbox(t2, 1)) > 112 || (this_bbox(t2, 2) + this_bbox(t2, 4)) > 340
                    this_row = t2;
                    flag = 1;
                end
            end
            if flag == 1
                this_bbox(this_row, :) = [];
                T_used{t, c}{1} = this_bbox;
                flag = 0;
            end
        end
    end
    end