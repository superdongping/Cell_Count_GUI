clc;
clear;
close all;

% Load the bfmatlab package
addpath('J:\Song_Lab\Ping\06 Software\bfmatlab\bfmatlab\');

% Directory containing your .oir files
oirDirectory = pwd;

% List all .oir files in the directory
oirFiles = dir(fullfile(oirDirectory, '*.oir'));

% Preallocate a cell array to store all ROI images
allRoiImages = {};

% Loop through each file
for i = 1:length(oirFiles)
    filePath = fullfile(oirDirectory, oirFiles(i).name);

    % Use Bio-Formats to read the .oir file
    data = bfopen(filePath);

    % Extract the first image from the file (assuming this is the one you want to use)
    firstImage = data{1, 1}{2, 1};  % Ensure this is the correct index for your desired image

    % Display the image
    hFig = figure;
    imshow(firstImage, []);

    % Use questdlg to ask the user if they want to use this image
    userResponse = questdlg('Do you want to use this image?', ...
        'Select Image', ...
        'Yes','No','Yes');

    if strcmp(userResponse, 'Yes')
        % Let the user draw a rectangle ROI on the image
        hRect = drawrectangle('Label','ROI');
        position = customWait(hRect);

        % Create the ROI image
        roiImage = imcrop(firstImage, position);

        % Convert ROI image to 8-bit if it's not already
        if ~isa(roiImage, 'uint8')
            % Scale the image data to the range 0-255
            roiImage = im2uint8(roiImage);
        end

        % Save individual ROI image
        [~, baseName, ~] = fileparts(oirFiles(i).name);
        roiFilename = sprintf('%s_ROI.tif', baseName);
        roiImageScaled = im2uint8(mat2gray(roiImage));
        imwrite(roiImageScaled, roiFilename);
        % imwrite(roiImage, roiFilename);  % Save as 8-bit image

        % Store the ROI image for later use
        allRoiImages{end+1} = roiImage;
    end

    close(hFig); % Close the figure for the current image
end

% Assuming each ROI image has the same size, calculate the figure size
roiSize = size(allRoiImages{1});
figureWidth = roiSize(2) * length(allRoiImages) / 100; % Adjust scale as needed
figureHeight = roiSize(1) / 100; % Adjust scale as needed

% Create a figure to display all ROIs
hFigAllRois = figure;
% Use tiled layout for flexible arrangement of subplots
t = tiledlayout('flow', 'Padding', 'compact');

for i = 1:length(allRoiImages)
    % Get next tile for the subplot
    ax = nexttile(t);
    imshow(allRoiImages{i}, []);
    title(sprintf('ROI %d', i)); % Optional: give each ROI a title
end

% Set the figure size to a fixed large size, or adjust dynamically based on your needs
figureWidth = 15; % Width in inches
figureHeight = 10; % Height in inches
set(hFigAllRois, 'Units', 'Inches', 'Position', [0, 0, figureWidth, figureHeight]);

% Adjust the figure size and resolution for saving
set(hFigAllRois, 'PaperUnits', 'inches');
set(hFigAllRois, 'PaperSize', [figureWidth, figureHeight]);
set(hFigAllRois, 'PaperPosition', [0, 0, figureWidth, figureHeight]);

% Save the figure with all ROIs in high resolution
print(hFigAllRois, 'All_ROIs.tif', '-dtiff', '-r300'); % '-r300' sets the resolution to 300 DPI
% close(hFigAllRois); % Close the figure after saving


% Define a custom wait function for the rectangle ROI
function position = customWait(hROI)
% Wait for the user to double-click the ROI or press Enter
wait(hROI);
% Get the position of the ROI
position = hROI.Position;
end
