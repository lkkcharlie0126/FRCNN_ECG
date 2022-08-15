function plot_predict_bbox(selectedScores, selectedLabels, selectedBboxes, ...
    score_threshold)
box_color = 'r';
for j = 1:length(selectedScores)
    if selectedScores(j) >= score_threshold
        switch selectedLabels(j)
            case 'SR'
                box_color = 'r';
            case 'APC'
                box_color = 'g';
            case 'VPC'
                box_color = 'b';
            case 'LBBB'
                box_color = 'c';
            case 'RBBB'
                box_color = 'm';
            case 'Others'
                box_color = 'y';
        end
        rectangle('Position', selectedBboxes(j,:), 'EdgeColor',box_color)
    end
end
end