function [RGB, bboxLabel] = plot_predict_bbox_new(im, selectedScores, selectedLabels, selectedBboxes, score_threshold)
box_color = 'r';
index = 1;
box_r = [];
bbox_label = [];

bbox_color = [];

for j = 1:length(selectedScores)
    if selectedScores(j) >= score_threshold
        switch selectedLabels(j)
            case 'SR'
                box_color = [243 200 197];
            case 'APC'
                box_color = [230 158 126];
            case 'VPC'
                box_color = [247 218 147];
            case 'LBBB'
                box_color = [185 206 182];
            case 'RBBB'
                box_color = [18 171 163];
            case 'Others'
                box_color = [132 218 252];
        end
        bbox_label = [bbox_label, j];

        bbox_color = [bbox_color; box_color];

%         bbox_color{index} = box_color;
        box_r = [box_r; selectedBboxes(j,:)];
        index = index + 1;
    end
end
bboxLabel = selectedLabels(bbox_label);
RGB = insertObjectAnnotation(im,'rectangle', box_r, bboxLabel,...
        'TextBoxOpacity',0.9,'FontSize',18, ...
        'Color',bbox_color,'TextColor','black', ...
        'LineWidth', 2);
% imshow(RGB, 'Parent',app.UIAxes)
end