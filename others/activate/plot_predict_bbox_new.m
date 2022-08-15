function RGB = plot_predict_bbox_new(im, selectedScores, selectedLabels, selectedBboxes, score_threshold)
box_color = 'r';
index = 1;
box_r = [];
bbox_label = [];
for j = 1:length(selectedScores)
    if selectedScores(j) >= score_threshold
        switch selectedLabels(j)
            case 'SR'
                selectedLabels(j) = 'N';
                box_color = 'red';
            case 'APC'
                box_color = 'green';
            case 'VPC'
                box_color = 'blue';
            case 'LBBB'
                box_color = 'cyan';
            case 'RBBB'
                box_color = 'magenta';
            case 'Others'
                box_color = 'yellow';
        end
        bbox_label = [bbox_label, j];
        bbox_color{index} = box_color;
        box_r = [box_r; selectedBboxes(j,:)];
        index = index + 1;
    end
end
RGB = insertObjectAnnotation(im,'rectangle', box_r, selectedLabels(bbox_label),...
        'TextBoxOpacity',0.9,'FontSize',18, ...
        'Color',bbox_color,'TextColor','black', ...
        'LineWidth', 2);
%     imshow(RGB)
end