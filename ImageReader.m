classdef ImageReader < handle
    % The image reader class is responsible for reading the image frames
    % from the left and right camera in each iteration of the background
    % calculation
    %
    properties 
        % The source path of the scene.
        src
        
        % The number from {1, 2, 3} that indicate which cameras we should
        % use for background subtraction
        L {mustBeNumeric}
        R {mustBeNumeric}
        
        % The index of the first frame
        start {mustBeNumeric}
        
        % Number of frames to be returned by the next() function that
        % follows the current frame.
        N {mustBeNumeric}
        
        % State of the image reader
        currentIndex {mustBeNumeric}
        
        % Total amount of images in the folder
        numberOfImages {mustBeNumeric}
        
        % imageFilesL and imageFilesR will store the file names of all
        % images in the left and right camera directories respectively
        imageFilesL
        imageFilesR
        
        % Image cache to utilize for the next call
        imageCacheL
        imageCacheR
    end
    
    methods  
        function obj = ImageReader(src, L, R, start, N)
            % Validate the inputs
            if ~exist('src', 'var') || ...
                    ~exist('L', 'var') || (L ~= 1 && L ~= 2) || ...
                    ~exist('R', 'var') || (R ~= 2 && R ~= 3)
                error("The input variables 'src' (the source folder), " + ...
                    "'L' (the index of the left camera, 1 or 2), and " + ...
                    "'R' (the index of the right camera, 2 or 3) are required.");
            end
            
            % Save the necessary parameters into attributes.
            obj.src = src;    
            obj.L = L;
            obj.R = R;
            
            if exist('start', 'var')
                obj.start = start;
            else
                obj.start = 1; % Default value
            end
            
            if exist('N', 'var')
                obj.N = N;
            else
                obj.N = 1; % Default value
            end

            % Initialize the current index with start.
            obj.currentIndex = start;
            
            % From the given source path (ex. "./ChokePoint/P1E_S1"), we
            % retrieve the name of the folder (ex. "P1E_S1") to use for 
            % getting the name of the camera folders. This corresponds to
            % the last 6 characters of the source path.
            pathLength = strlength(obj.src);
            folderName = extractBetween(obj.src, pathLength - 5, pathLength, 'Boundaries', 'inclusive');
            
            % Using the folder name, we initialize the names of the camera
            % folders (ex. "P1E_S1_C1").
            lName = string(folderName) + '_C' + L;
            rName = string(folderName) + '_C' + R;
            
            % Store all the source paths of images in the attributes.
            obj.imageFilesL = dir(fullfile(obj.src, lName, '*.jpg'));
            obj.imageFilesR = dir(fullfile(obj.src, rName, '*.jpg'));
            
            % Store the number of images also in an attribute.
            obj.numberOfImages = length(obj.imageFilesL);
            
            % Display an error if the start index is invalid
            if obj.currentIndex > obj.numberOfImages
                error("The starting index should not be greater than " + ...
                    obj.numberOfImages + " but you have given " + ...
                    obj.currentIndex);
            end
            
            % Initialize caches with dummy matrices
            obj.imageCacheL = zeros(1);
            obj.imageCacheR = zeros(1);
        end
        
        function [left, right, loop] = next(obj)
            % Return the image at index currentIndex and N following images
            % for the right and left camera.
            
            % Calculate the number of images. If there are at least N
            % images following the current frame, then return N + 1 images
            % for the left and right camera. Otherwise return all the
            % remaining frames.
            numOfImagesToReturn = 1 + min([obj.N (obj.numberOfImages - obj.currentIndex)]);
            
            % Initialize the left and right tensors
            left = zeros(600, 800, 3 * numOfImagesToReturn, 'uint8');
            right = zeros(600, 800, 3 * numOfImagesToReturn, 'uint8');
            
            if obj.imageCacheL == zeros(1)
                % Iterate over all images to return.
                for i = 0:numOfImagesToReturn - 1

                    % Get the path of the left image.
                    leftImageFile = obj.imageFilesL(obj.currentIndex + i);
                    leftImagePath = fullfile(leftImageFile.folder, leftImageFile.name);

                    % Get the path of the right image.
                    rightImageFile = obj.imageFilesR(obj.currentIndex + i);
                    rightImagePath = fullfile(rightImageFile.folder, rightImageFile.name);

                    % Save the images to the left and right tensors
                    left(:, :, (i * 3 + 1):(i * 3 + 3)) = imread(leftImagePath);
                    right(:, :, (i * 3 + 1):(i * 3 + 3)) = imread(rightImagePath);
                    
                    % Renew the cache
                    obj.imageCacheL = left;
                    obj.imageCacheR = right;
                end
            else
                % Get the old images from the cache
                left(:, :, 1:(numOfImagesToReturn - 1) * 3) = obj.imageCacheL(:, :, 4:numOfImagesToReturn * 3);
                right(:, :, 1:(numOfImagesToReturn - 1) * 3) = obj.imageCacheR(:, :, 4:numOfImagesToReturn * 3);
                
                % The last image to return is new, so read it from scratch
                newImageIndex = numOfImagesToReturn * 3 - 2:numOfImagesToReturn * 3;
                
                leftImageFile = obj.imageFilesL(obj.currentIndex + numOfImagesToReturn - 1);
                leftImagePath = fullfile(leftImageFile.folder, leftImageFile.name);
                left(:, :, newImageIndex) = imread(leftImagePath);                
                
                rightImageFile = obj.imageFilesR(obj.currentIndex + numOfImagesToReturn - 1);
                rightImagePath = fullfile(rightImageFile.folder, rightImageFile.name);
                right(:, :, newImageIndex) = imread(rightImagePath);
                
                % Renew the cache
                obj.imageCacheL = left;
                obj.imageCacheR = right;
            end
            
            % If the current frame is not the last frame, set the loop
            % variable to zero, else to one.
            loop = 0;
            if obj.currentIndex + obj.N >= obj.numberOfImages
                loop = 1;
                obj.currentIndex = 0;
                
                % Empty the cache
                obj.imageCacheL = zeros(1);
                obj.imageCacheR = zeros(1);
            end
            
            % Increment the current index for the next run.
            obj.currentIndex = obj.currentIndex + 1;
        end
    end
end