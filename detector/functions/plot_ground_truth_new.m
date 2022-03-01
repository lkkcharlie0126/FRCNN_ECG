function RGB = plot_ground_truth_new(im, inputImageSize, data_true, i)
%     img_r = imresize(im,inputImageSize(1:2));
%     imshow(img_r);

    sz = size(im,[1 2]);
    scale = inputImageSize(1:2)./sz;
    box_r = [];
    bbox_color = [];

    for j = 1:size(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}, 1)
        box_r = [box_r; bboxresize(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 1}(j,:), scale)];
        switch data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}(j)
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
        bbox_color = [bbox_color; box_color];
    end
    RGB = insertObjectAnnotation(im,'rectangle', box_r, data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2},...
        'TextBoxOpacity',0.9,'FontSize',18, ...
        'Color',bbox_color,'TextColor','black', ...
        'LineWidth', 2);
%     imshow(RGB)
end