function parameterTuningGUI()
% Define global variables for parameters
global threshold minSize maxSize erosionSize imgData;

% Initial default values for parameters
threshold = 0.35;
minSize = 15;
maxSize = 2000;
erosionSize = 1;

% Get screen size and set the figure size to 90% of the screen
screenSize = get(0, 'ScreenSize');
figWidth = screenSize(3) * 0.9;
figHeight = screenSize(4) * 0.9;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

% Create the figure for the GUI
hFig = figure('Name', 'Parameter Tuning for Cell Counting', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Position', [figX, figY, figWidth, figHeight]);

% Enable zoom feature for the figure
zoom(hFig, 'on');

% Control elements for parameters
controlYStart = screenSize(4) * 0.01; % Starting Y position for controls

% Load image button
uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Load Image', 'Position', [30, controlYStart, 100, 30], 'Callback', @loadImage);

% Threshold slider
hThresholdSlider = uicontrol('Parent', hFig, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', threshold, 'Position', [150, controlYStart, 200, 20], 'Callback', @adjustThreshold);
uicontrol('Parent', hFig, 'Style', 'text', 'String', 'Threshold', 'Position', [150, controlYStart + 25, 200, 20]);

% Minimum size slider
hMinSizeSlider = uicontrol('Parent', hFig, 'Style', 'slider', 'Min', 0, 'Max', 5000, 'Value', minSize, 'Position', [370, controlYStart, 200, 20], 'Callback', @adjustMinSize);
uicontrol('Parent', hFig, 'Style', 'text', 'String', 'Min Size', 'Position', [370, controlYStart + 25, 200, 20]);

% Maximum size slider
hMaxSizeSlider = uicontrol('Parent', hFig, 'Style', 'slider', 'Min', 0, 'Max', 10000, 'Value', maxSize, 'Position', [590, controlYStart, 200, 20], 'Callback', @adjustMaxSize);
uicontrol('Parent', hFig, 'Style', 'text', 'String', 'Max Size', 'Position', [590, controlYStart + 25, 200, 20]);

% Erosion size slider
hErosionSizeSlider = uicontrol('Parent', hFig, 'Style', 'slider', 'Min', 1, 'Max', 10, 'Value', erosionSize, 'Position', [810, controlYStart, 200, 20], 'Callback', @adjustErosionSize);
uicontrol('Parent', hFig, 'Style', 'text', 'String', 'Erosion Size', 'Position', [810, controlYStart + 25, 200, 20]);

% "Save Parameters" button
uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Save Parameters', 'Position', [1030, controlYStart, 120, 30], 'Callback', @saveParameters);

% Panel for displaying the image, using the remaining figure space
hPanelImage = uipanel('Parent', hFig, 'Position', [0.01, 0.15, 0.98, 0.8]);
hAxImage = axes('Parent', hPanelImage, 'Position', [0 0 1 1]);

    function loadImage(~, ~)
        [fileName, pathName] = uigetfile({'*.tif;*.jpg;*.png;*.oir', 'Image Files (*.tif, *.jpg, *.png, *.oir)'}, 'Select an Image');
        if fileName ~= 0
            imgPath = fullfile(pathName, fileName);
            imgData = imread(imgPath);
            if size(imgData, 3) > 1
                imgData = rgb2gray(imgData); % Convert to grayscale if it's a color image
            end
            updateImage();
        end
    end

    function adjustThreshold(~, ~)
        threshold = hThresholdSlider.Value;
        updateImage();
    end

    function adjustMinSize(~, ~)
        minSize = hMinSizeSlider.Value;
        updateImage();
    end

    function adjustMaxSize(~, ~)
        maxSize = hMaxSizeSlider.Value;
        updateImage();
    end

    function adjustErosionSize(~, ~)
        erosionSize = round(hErosionSizeSlider.Value); % Ensure erosion size is an integer
        updateImage();
    end

    function updateImage()
        if isempty(imgData)
            return;
        end
        % Process the image based on the current parameters
        processedImage = processImage(imgData, threshold, minSize, maxSize, erosionSize);
        % Display the processed image
        imshow(processedImage, 'Parent', hAxImage);
    end

    function result = processImage(image, thresh, minSz, maxSz, eroSize)
        I_BW = imbinarize(image, thresh);
        I_BW_m = medfilt2(I_BW, [3, 3]);
        se = strel('cube', eroSize); % Use the erosion size from the slider
        I_BW_e = imerode(I_BW_m, se);
        BWnobord = imclearborder(I_BW_e, 4);
        L = bwlabeln(BWnobord, 8);
        S = regionprops(L, 'Area', 'Centroid');

        % Filter based on area size and get centroids
        validAreas = ([S.Area] >= minSz) & ([S.Area] <= maxSz);
        validS = S(validAreas);
        centroids = cat(1, validS.Centroid); % Concatenate all centroids into an Nx2 matrix

        % Overlay the labeled areas on the original image
        labeledImage = labeloverlay(image, BWnobord, 'Transparency',0.7);

        % Create a figure and hold it for overlaying centroids
        result = labeledImage;
        if ~isempty(centroids)
            % If there are centroids, overlay them on the result image
            f = figure('visible', 'off');
            imshow(result, 'Parent', gca); hold on;
            % Plot each centroid as a red "+"
            plot(centroids(:,1), centroids(:,2), 'r+', 'MarkerSize', 5, 'LineWidth', 1.5);
            hold off;
            % Capture the figure as an image
            result = getframe(gca);
            result = result.cdata;
            close(f);
        end
    end

    function saveParameters(~, ~)
        % Save the current parameters to global variables
        threshold = hThresholdSlider.Value;
        minSize = hMinSizeSlider.Value;
        maxSize = hMaxSizeSlider.Value;
        erosionSize = round(hErosionSizeSlider.Value);
        % Provide feedback that parameters are saved
        msgbox('Parameters saved successfully.', 'Success', 'help');
    end
end
