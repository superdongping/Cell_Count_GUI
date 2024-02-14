clc;
clear;
close all;

% Invoke the parameter tuning GUI and wait for the user to close it
parameterTuningGUI;
uiwait(gcf);  % Wait for the GUI to close

% Access the global parameters set by the GUI
global threshold minSize maxSize erosionSize;

% Directory containing your image files
Image_Directory = pwd;

% List all .tif files in the directory
Image_Files = dir(fullfile(Image_Directory, '*.tif'));

% Loop through each file
for i = 1:length(Image_Files)
    filePath = fullfile(Image_Directory, Image_Files(i).name);

    % Extract the base name for file identification
    [~, baseName, ~] = fileparts(Image_Files(i).name);

    % Read the image file
    firstImage = imread(filePath);

    % Analyze the image with the modified function, passing in the parameters
    analyzeROIsAndCellsFromData(firstImage, baseName, threshold, minSize, maxSize, erosionSize);
end
