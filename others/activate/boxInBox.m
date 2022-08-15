function [camBox_window, combinedImage] = boxInBox(gradcam, maxIntensity_threshold, camBox_window, original_width_range, original_height_range, selectedLabels, j, combinedImage)
        %% 二值化
        gradcam2 = gradcam > 1-maxIntensity_threshold;
        % Largest connected component
        gradcamC = zeros(size(gradcam));
%         if max(max(gradcamC)) == 0
%             continue;
%         end
        CC = bwconncomp(gradcam2);
%         if CC.NumObjectsum == 0
%             continue;
%         end
        numPixels = cellfun(@numel,CC.PixelIdxList);    
        [biggest,idx] = max(numPixels);
        
        gradcamC(CC.PixelIdxList{idx}) = 1;
%         imshow(gradcamC)
        
        % Calculate CAM BBox
        [camBox_high, camBox_low, camBox_left, camBox_right] = camBox(gradcamC);
        
        camBox_original_x = original_width_range(1)+camBox_left-1;
        camBox_original_y =  original_height_range(1)+camBox_high-1;
        camBox_original_w = camBox_right - camBox_left;
        camBox_original_h = camBox_low - camBox_high;
        camBox_original = {camBox_original_x, camBox_original_y, camBox_original_w, camBox_original_h, selectedLabels(j)};
        camBox_window = [camBox_window; camBox_original];
        %
        cmap = jet(255).*linspace(0,1,255)';
        gradcam = ind2rgb(uint8(gradcamC*255),cmap)*255;
%         gradcam = ind2rgb(uint8(gradcam*255),cmap)*255;
        combinedImage(original_height_range, original_width_range, :) = combinedImage(original_height_range, original_width_range, :) + gradcam;
       
%         imshow(uint8(normalizeImage(combinedImage)*255));
end