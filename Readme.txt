------------------------------------------------------------------------
-------------------------------- README --------------------------------
------------------------------------------------------------------------

------------------------------------------------------------------------
-------------------- Computer Vision Challenge 2020 --------------------
------------------------------------------------------------------------

------------------------------------------------------------------------
Group Number: 5
Group Members: Abdullah Özbay, Ahmet Gulmez, Baris Sen, Mine Tülü
Email addresses: ga83mav@tum.de, ga94cib@tum.de, baris.sen@tum.de, ga87ver@tum.de
------------------------------------------------------------------------


The user can start the project by running the "challenge.m" file or typing on the terminal the command "start_gui" to reach the GUI.

------------------------------------------------------------------------
Using the program through the GUI:
------------------------------------------------------------------------

After the user typed the command "start_gui," she gets the GUI on the screen. First, the user chooses a source folder; the selected folder's name appears on the GUI. 

The program chooses the camera. Afterward, the user selects an appropriate frame number as a starting frame and picks a mode from four different options; background, foreground, overlay, and substitute.

If the mode chosen as "substitute,"  the background of the image will be a video or image, next the user selects a background image or video (File formats can be PNG, JPG, MP4, and AVI).

Additionally, when the user selects the option for showing the images in real-time as "on," the images will be shown in real-time. That causes extra time for the process. If the user selects "off," the images will not be displayed; only the output is saved if the store is switched on.

In the next step, the user sets the loop settings if the user chooses "on" the program restarts after it is completed when she selects "off," and the program will not restart.

Moreover, the store setting allows the user to save the result as a video. She selects "on" to save or selects "off" not to keep. The user chooses a source path to save the generated video and assigns a name for the created video.

At long last, the user clicks "start" to run the code. If the user clicks "pause," the program stops. The "continue" selection restarts the program, where it left off. If the user chooses the "stop" option, the program breaks, and the user can change the GUI parameters before the program starts.

------------------------------------------------------------------------
Using the program through challenge.m and the config.m files:
------------------------------------------------------------------------

The first step is to set the following variables in the config.m file.

- Line 14, isVideoBackground: Should be set to true if the render_mode is substitute and the background replacement is a video file
- Line 23, src: Should be set to the path to the source directory of input images
- Line 26, render_mode: One of the following: 'background', 'foreground', 'overlay', 'substitute'
- Line 31, bgVideoPath: If render mode is 'substitute' and the 'isVideoBackground' is set to true, the bgVideoPath should be set to the video's path.
- Line 31, bgImagePath: If render mode is 'substitute' and the 'isVideoBackground' is set to false, the bgImagePath should be set to the image path.
- Line 41, start: The starting frame
- Line 45, outputFolder: Path to the output folder, if you would like to store the output
- Line 48, outputName: Name of the output file, if you would like to store the output
- Line 51, infiniteLoop: Set to true, if you would like to play the scenes in an infinite loop
- Line 54, store: Set to true, if you would like to store the output
- Line 113, L: Set to '1' or '2', the left camera index.
- Line 114, R: Set to '2' or '3', the right camera index.

After the values are all set, you can run the challenge.m file, and the results are shown through figures and video output in the end if requested. The elapsed time will be printed to the console.