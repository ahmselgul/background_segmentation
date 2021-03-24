function [mask] = segmentation(left, right)
    % The segmentation function calculates a background mask for the frame
    % in the middle of the tensor left. Returned binary mask is of size 
    % [600, 800].
    N = size(left, 3) / 3;
    
    % The threshold will be used to decide if a pixel value is different
    % from the background.
    threshold = 10;
    
    % Calculate the background image using a median filter over all (N + 1)
    % images.
    background = calculateBackground(left);
    
    % The current frame we will create a mask for is the image in the
    % middle of the tensor left.
    currentImage = left(:, :, floor(N/2)*3+1:floor(N/2)*3+3);
    
    % For each layer R, B, and G:
    %   Check if the difference between each pixel of the background image
    %   and the current image is greater than a threshold. If so, the pixel
    %   is set to one (foreground).
    % We use the threshold for each color channel to observe the difference 
    % and set the value in the matrix to one when one of the channels 
    % exceeds the threshold.
    diffR = abs(int16(background(:, :, 1)) - int16(currentImage(:, :, 1))) > threshold;
    diffB = abs(int16(background(:, :, 2)) - int16(currentImage(:, :, 2))) > threshold;
    diffG = abs(int16(background(:, :, 3)) - int16(currentImage(:, :, 3))) > threshold;
    initialMask = (diffR + diffB + diffG) > 0;

    % The mask we calculated so far has a lot of noise. We use the smooth
    % function we have implemented to get rid of some of the noise. The
    % smoothing function has several hyperparameters that we adjusted
    % emprically. The mask is performed twice for best results. 
    smoothedMask1 = smoothMask(initialMask, 30, 4, 4, 0.5, 0.2);
    smoothedMask2 = smoothMask(smoothedMask1, 10, 6, 1, 0.4, 0.2);

    % If there are holes in the mask we would like fill them since there
    % are probably the middle of a single color area where we could not
    % identify the motion using the previous methods.
    mask = fillHoles(smoothedMask2);
end

%% Background detection using simple median filter
function backgroundImage = calculateBackground(left)
    % We reshape the tensor left in order to use the median function.
    reshaped = reshape(left, size(left, 1), size(left, 2), 3, size(left, 3) / 3);
    
    % Return the median of all frames as the background.
    backgroundImage = median(reshaped, 4);
end

%% Removing noise in the mask using a sliding window
function smoothed = smoothMask(mask, window_radius, paint_radius, sampling_radius, filling_threshold, emptying_threshold)
    % This function removes some of the noise in the given binary mask
    % using a sliding window.
    % Input parameters:
    %   mask: The mask where the noise will be removed.
    %   window_radius: We will use the are environment of the pixels for
    %       deciding if a pixel should be removed. So, if the window_radius
    %       is r, we look at the area mask[x-r:x+r, y-r:y+r].
    %   paint_radius: If we decide that a pixel is a noise pixel, it is
    %       likely that the surrounding pixels also include noise. To
    %       improve efficiency of the smoothing function, we paint all the
    %       pixel in paint_radius range.
    %   sampling_radius: Since we are not correcting single pixels but
    %       areas of size [2*paint_radius+1, 2*paint_radius+1], we can
    %       avoid visiting through all pixels in the image by looking at
    %       only the every sampling_radius'th row and every 
    %       sampling_radius'th column. This improves the efficiency by 
    %       O(sampling_radius ^ 2).
    %   filling_threshold: We fill and area, if the rate of the amount of 
    %       1's in the environment to the amount of pixels in the
    %       environment is more than filling_threshold.    
    %   emptying_threshold: We emptry and area, if the rate of the amount of 
    %       1's in the environment to the amount of pixels in in the
    %       environment is less than emptying_threshold.
    
    % In order to be able to apply the window without edge cases, we add
    % padding to the image
    mask_padded = zeros(size(mask, 1) + 2 * window_radius, size(mask, 2) + 2 * window_radius);
    mask_padded(window_radius + 1:window_radius  + size(mask, 1),...
        window_radius + 1:window_radius + size(mask, 2)) = mask;
    
    % We initialize two matrices. Smoothed will hold the result, visited
    % will check if a decision about the pixel i, j has been done. 
    smoothed = zeros(size(mask_padded, 1), size(mask_padded, 2));
    visited = zeros(size(mask_padded, 1), size(mask_padded, 2));
    
    % We iterate over all pixels
    for i = 1 + window_radius:size(mask_padded, 1) - window_radius
        for j = 1 + window_radius:size(mask_padded, 2) - window_radius
            % If we have already visited the pixel or given a value to it,
            % we continue to the next pixel.
            if visited(i, j) == 1
                continue;
            end
            
            % If the pixel is 1 in the orginal mask, we first set it to 1
            % on the smoothed image.
            if mask_padded(i, j) > 0
                smoothed(i, j) = 1;
            end
            
            % If we are in a pixel that obeys i = 0 mod(sampling_radius)
            % and j = 0 mod(sampling_radius), we have a look at this pixel
            % and its environment.
            if mod(i, sampling_radius) == 0 && mod(j, sampling_radius) == 0
                
                % Get the environment of this point using the window radius
                environment_of_point = ...
                    mask_padded(i - window_radius:i + window_radius, ...
                                j - window_radius:j + window_radius);
                
                % Get the number of 1s in the environment
                sum_env = sum(sum(environment_of_point));
                
                % If the ratio of 1s in the environment is more than the
                % threshold, set all points in the area 
                % [i-paint_radius:i+paint_radius, 
                % j-paint_radius:j+paint_radius] to 1.
                % We also mark the painted points as visited.
                if sum_env > ((2 * window_radius) ^ 2) * filling_threshold
                    smoothed(i-paint_radius:i+paint_radius, j-paint_radius:j+paint_radius) = 1;
                    visited(i-paint_radius:i+paint_radius, j-paint_radius:j+paint_radius) = 1;
                    
                    % Since we already painted these points, we increment
                    % the j by the paint radius.
                    j = j + paint_radius;
                end
                
                % If the ratio of 1s in the environment is less than the
                % threshold, set all points in the area 
                % [i-paint_radius:i+paint_radius, 
                % j-paint_radius:j+paint_radius] to 0.
                % We also mark the painted points as visited.
                if sum_env < ((2 * window_radius) ^ 2) * emptying_threshold
                    smoothed(i-paint_radius:i+paint_radius, j-paint_radius:j+paint_radius) = 0;
                    visited(i-paint_radius:i+paint_radius, j-paint_radius:j+paint_radius) = 1;
                    
                    % Since we already painted these points, we increment
                    % the j by the paint radius.
                    j = j + paint_radius;
                end
            end
        end
    end
    
    % We remove the padding from the smoothed matrix
    smoothed = logical(smoothed(1 + window_radius:size(mask_padded, 1) - window_radius, 1 + window_radius:size(mask_padded, 2) - window_radius));
end

%% Filling the holes in the binary mask
function filledMask = fillHoles(binaryMask)
    % We first expand the mask with one line of 1s in the bottom of the
    % image because we would like to treat the empty areas in the bottom 
    % of the masks as holes.
    paddedMask = zeros(size(binaryMask, 1) + 1, size(binaryMask, 2));
    paddedMask(1:end - 1, :) = binaryMask;
    paddedMask(end, :) = 1;
    
    % We fill the holes in the resulting padded mask using the imfill function
    paddedFilledMask = imfill(paddedMask, 'holes');
    
    % We remove the padding and return the result
    filledMask = paddedFilledMask(1:end - 1, :);
end
