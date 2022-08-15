function plot_ground_truth(im, inputImageSize, data_true, i)
%     img_r = imresize(im,inputImageSize(1:2));
%     imshow(img_r);
    box_color = 'r';
    for j = 1:size(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}, 1)
        switch data_true.UnderlyingDatastores{1, 2}.LabelData{i, 2}(j)
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
        sz = size(im,[1 2]);
        scale = inputImageSize(1:2)./sz;
        box_r = bboxresize(data_true.UnderlyingDatastores{1, 2}.LabelData{i, 1}(j,:), scale);
        rectangle('Position', box_r, 'EdgeColor',box_color)
    end
end