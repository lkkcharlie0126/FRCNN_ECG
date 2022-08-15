 % CAM Box
function [camBox_high, camBox_low, camBox_left, camBox_right] = camBox(gradcamC)
camBox_high = 0;
camBox_low = size(gradcamC, 1);
for row = 1:size(gradcamC, 1)
    if camBox_high == 0
        if ismember(1, gradcamC(row, :))
            camBox_high = row;
        end
    else
        if ~ismember(1, gradcamC(row, :))
            camBox_low = row;
            break;
        end
    end
end

camBox_left = 0;
camBox_right = size(gradcamC, 2);
for col = 1:size(gradcamC, 2)
    if camBox_left == 0
        if ismember(1, gradcamC(:, col))
            camBox_left = col;
        end
    else
        if ~ismember(1, gradcamC(:, col))
            camBox_right = col;
            break;
        end
    end
end
end