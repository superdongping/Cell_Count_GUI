function analyzeROIsAndCellsFromData(imageData, baseName, threshold, minSize, maxSize, erosionSize)
% Convert imageData from uint16 to uint8
imageDataUint8 = uint8(double(imageData) / double(max(imageData(:))) * 255);

% Display the image and store the image handle
hFig = figure;
hImage = imshow(imageDataUint8, []);
hold on;

% Initialize an array to store ROI images and analysis results
roiImages = {};
roiResults = {};
roiCount = 0;

% Boolean flag to control the loop for drawing ROIs
isDrawing = true;

% Use a loop to draw multiple ROIs
while isDrawing
    h = drawfreehand('Color', 'r'); % Allows drawing a freehand ROI
    wait(h); % Wait for the ROI to be finalized

    % Check if the ROI is valid
    if ~isempty(h.Position)
        roiCount = roiCount + 1;

        % Create a mask for the ROI using the image handle to resolve ambiguity
        mask = createMask(h, hImage); % Pass the image handle here

        % Extract ROI and store it using the converted uint8 image data
        roiImage = bsxfun(@times, imageDataUint8, uint8(mask));
        roiImages{roiCount} = roiImage;

        % Calculate the total area of the ROI
        totalArea = sum(mask(:));

        % Store the total area in roiResults
        roiResults{roiCount}.TotalArea = totalArea;

        % Display a message box to ask if the user wants to draw more ROIs
        choice = questdlg('Do you want to draw another ROI?', 'Continue Drawing', 'Yes', 'No', 'Yes');

        % Handle the user's choice
        if strcmp(choice, 'No')
            isDrawing = false; % Exit the loop if the user chooses 'No'
        end
    end
end

close(hFig); % Close the figure after all ROIs are drawn

% Analyze each ROI for cell count and area, plot centroids, and save ROI images
for i = 1:roiCount
    [area, centroids] = Cell_Count(roiImages{i}, threshold, minSize, maxSize, erosionSize);
    roiResults{i}.CellCount = numel(area);
    roiResults{i}.MeanArea = mean(area);
    roiResults{i}.Centroids = centroids;

    % Overlay centroids on the ROI image if there are any valid areas

    if ~isempty(centroids)
        hFig = figure; imshow(roiImages{i}); hold on;
        plot(centroids(:,1), centroids(:,2), 'r+', 'MarkerSize', 4);
        hold off;
    else
        hFig = figure; imshow(roiImages{i}); % Just show the ROI image without centroids
    end

    % Save the ROI image with centroids
    roiFilename = sprintf('%s_ROI_%d.png', baseName, i);
    saveas(hFig, roiFilename);
    close(hFig);
end

% Prepare data for Excel
excelData = cell(roiCount + 1, 4);
excelData{1, 1} = 'ROI';
excelData{1, 2} = 'Cell Count';
excelData{1, 3} = 'Mean Area';
excelData{1, 4} = 'Total ROI Area';
for i = 1:roiCount
    excelData{i + 1, 1} = ['ROI ' num2str(i)];
    excelData{i + 1, 2} = roiResults{i}.CellCount;
    excelData{i + 1, 3} = roiResults{i}.MeanArea;
    excelData{i + 1, 4} = roiResults{i}.TotalArea;
end

% Write to Excel file
filename = sprintf('%s_ROI_Analysis_Summary.xlsx', baseName);
xlswrite(filename, excelData);

% Inform the user that the process is complete
msgbox('All ROIs have been processed and saved. Results are in the Excel summary file.');
end
