%% Computer Vision Challenge 2020 config.m

%% General Settings
% Group number:
group_number = 5;

% Group members:
members = {'Abdullah Özbay', 'Ahmet Gulmez', 'Baris Sen', 'Mine Tülü'};

% Email-Address (from Moodle!):
mail = {'ga83mav@tum.de', 'ga94cib@tum.de', 'baris.sen@tum.de', 'ga87ver@tum.de'};

% If the background is a video, the variable isVideoBackground should be set to true
isVideoBackground = true;

%% Setup Image Reader
if ~exist('app', 'var')
    
    startedFromGUI = false;
    
    %% Input Settings
    % Specify Scene Folder
    src = "./ChokePoint/P1L_S1";
    
    % Select rendering mode
    render_mode = "foreground";
    
    if render_mode == "substitute";
        if isVideoBackground
            % Load Virtual Background Video
            bgVideoPath = './bgVideo.mp4';
            bgVideo = VideoReader(bgVideoPath);
        else    
            % Load Virtual Background Image
            bgImagePath = './bg.png';
            bg = imread(bgImagePath);
        end
    end
    
    % Choose a start point
    start = 500;
    
    %% Output Settings
    % Output folder
    outputFolder = ".";
    
    % Output name
    outputName = "output.avi";
    
    % Infinite loop
    infiniteLoop = true;
    
    % Store Output?
    store = true;
    
else
    % The values in this branch should not be modified since they are
    % received from the GUI
    startedFromGUI = true;
    
    %% Input Settings
   
    % Specify the scene folder
    src = app.src.Text;
    
    if app.mode.Value == "substitute"
        % Specify the background file path
        bgSrc = app.bg.Text;

        % Decide the background type depending on the file extension
        [fPath, fName, fExt] = fileparts(bgSrc);

        fExt = lower(fExt);
        if strcmp(fExt, '.png') || strcmp(fExt, '.jpg')

            % Load Virtual Background Image
            bg = imread(app.bg.Text);

        elseif strcmp(fExt, '.mp4') || strcmp(fExt, '.avi') 

            % Load Virtual Background Video
            bgVideo = VideoReader(bgSrc);

            % Set the flag to true in order to use it later on to read the
            % video
            isVideoBackground = true;
        else        
            error('Unexpected file extension: %s', fExt);
        end
    end

    % Select rendering mode
    render_mode = app.mode.Value;
    
    % Choose a start point
    start = app.start.Value;
    
    %% Output Settings
    % Output folder
    outputFolder = app.dst.Text;    
    
    % Output name
    outputName = app.OutputFileNameEditField.Value + ".avi";
        
    % Infinite loop
    infiniteLoop = app.loop.Value == "On";
    
    % Store output?
    store = app.StoreSwitch_2.Value == "On";
end
    
% Select Cameras
L = 1;
R = 2;

% Choose the number of succeeding frames
N = 20;

% Concatinate the output folder name and file name to get the destination
% path
dest = fullfile(outputFolder, outputName);

% Create the image reader
ir = ImageReader(src, L, R, start, N);

% Set the bg to a dummy variable is mode is not substitute
if render_mode ~= "substitute"
    bg = zeros(1,1);
end
