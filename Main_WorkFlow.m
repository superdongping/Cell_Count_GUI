clc;
close all;

% Prompt the user to choose whether to perform parameter setting
choice = questdlg('Would you like to perform parameter setting?', ...
    'Parameter Setting', ...
    'Yes', 'No', 'Yes');

% Check the user's choice
if strcmp(choice, 'Yes')
    % Invoke the parameter tuning GUI and wait for the user to close it
    parameterTuningGUI;
    uiwait(gcf);  % Wait for the GUI to close
else
    % Check if parameters exist in the workspace
    if ~exist('threshold', 'var') || ~exist('minSize', 'var') || ~exist('maxSize', 'var') || ~exist('erosionSize', 'var')
        errordlg('No parameter is detected, need to set the parameters first.', 'Parameter Error');
        return;  % Exit the script if parameters are not set
    end
end

% Access the global parameters set by the GUI or already existing in the workspace
global threshold minSize maxSize erosionSize Marker_size ;

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
    analyzeROIsAndCellsFromData(firstImage, baseName, threshold, minSize, maxSize, erosionSize, Marker_size);
end
