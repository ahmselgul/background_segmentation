%% Computer Vision Challenge 2020 challenge.m
clc;
close all;

imtool close all;
% clear;
workspace;
%% Start timer here
tic

%% Generate Movie

% Call the config script to initialize the required parameters
config;

% The loop will be zero unless we reach the last frame
loop = 0;

% Create a counter which will keep track of the current frame index
frameCounter = 1;

% Create a counter which is responsible to iterate the background video
bgFrameCounter = 1;

%% Start Writing Movie to Disk
if store
    v = VideoWriter(dest, 'Motion JPEG AVI');
    v.open();
end

%% Process all frames in a loop while whether the infiniteLoop is set or 
% the loop variable is not set to one and program is not stopped from GUI.
while (~startedFromGUI || (startedFromGUI && ~app.shouldStop)) && ...
    (infiniteLoop || (loop ~= 1))

    % Get the next image tensors
    [left, right, loop] = ir.next();
    
    % Calculate the mask using the segmentation function
    mask = segmentation(left, right);
    
    % Get the image in the middle of the tensors
    currentImageL = left(:, :, floor((N+1)/2)*3+1:floor((N+1)/2)*3+3);
    currentImageR = right(:, :, floor((N+1)/2)*3+1:floor((N+1)/2)*3+3);

    if render_mode == "substitute"
        % If the background source is a video then read it as below
        if isVideoBackground
            bg = read(bgVideo, bgFrameCounter);
            numOfFrames = bgVideo.NumFrames;
            % Set the frame counter to zero so that the background video starts
            % again
            if bgFrameCounter > numOfFrames - 2
                bgFrameCounter = 1;
            end
        end 

        % Validate background image size
        if size(bg, 1) < 600 && size(bg, 2) < 800 && size(bg, 3) ~= 3
            error('The resolution of the background image/video ' + ... 
                'should be at least 600x800');
        end

        % Crop the background image accordingly
        bg = bg(1:600, 1:800, :);
        
        % Increment frame counter for the next iteration
        frameCounter = frameCounter + 1;

        % Increment background video frame counter for the next iteration
        bgFrameCounter = bgFrameCounter + 1;

    end
    
    % Render the mask onto the current image using the defined parameters
    result = render(currentImageL, mask, bg, render_mode);
        
    if exist('app', 'var') && app.displayImagesRealtime.Value == "On"
        app.ImageL.ImageSource = currentImageL;
        app.ImageR.ImageSource = currentImageR;
        app.ImageResult.ImageSource = result;
        drawnow
    else
        imshow([currentImageL, currentImageR, result]);
    end
    
    % Add the frame to the video
    if store
        v.writeVideo(result);
    end
    
    % If the flow is paused from the GUI, just wait
    while startedFromGUI && app.paused
        pause(0.1);
    end
end

%% Close the writer
if store
    v.close();
end

%% Stop timer here
elapsed_time = toc;
disp("The elapsed time for processing all images is " + string(elapsed_time) + " seconds.");
