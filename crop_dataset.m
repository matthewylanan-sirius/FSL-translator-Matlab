% Clear workspace
clear; clc;

% 1. Set paths
datasetPath = pwd; 
outputFolder = fullfile(pwd, 'cropped_7k_dataset');

if ~exist(datasetPath, 'dir')
    error('Dataset folder "%s" not found! Ensure your unzipped Roboflow YOLO folder is in your current directory.', datasetPath);
end

% 2. Find all image files
imgFiles = dir(fullfile(datasetPath, '**', '*.jpg'));
imgFiles = [imgFiles; dir(fullfile(datasetPath, '**', '*.png'))];
imgFiles = [imgFiles; dir(fullfile(datasetPath, '**', '*.jpeg'))];

disp(['Found ', num2str(length(imgFiles)), ' images. Starting hand extraction...']);

cropCount = 0;

% 3. Iterate over each image and extract bounding box crops
for i = 1:length(imgFiles)
    imgPath = fullfile(imgFiles(i).folder, imgFiles(i).name);
    
    % Locate corresponding YOLO label file (.txt)
    [parentDir, baseName, ~] = fileparts(imgPath);
    labelPath = fullfile(parentDir, [baseName, '.txt']);
    
    % Handle standard YOLO folder structures where labels/ is parallel to images/
    if ~exist(labelPath, 'file')
        labelPath = strrep(imgPath, [filesep 'images' filesep], [filesep 'labels' filesep]);
        [lblDir, lblName, ~] = fileparts(labelPath);
        labelPath = fullfile(lblDir, [lblName '.txt']);
    end
    
    if ~exist(labelPath, 'file')
        continue; % Skip if no annotation text file exists
    end
    
    % Read image
    img = imread(imgPath);
    [imgH, imgW, ~] = size(img);
    
    % Read YOLO label file
    fileID = fopen(labelPath, 'r');
    if fileID == -1, continue; end
    lines = textscan(fileID, '%d %f %f %f %f');
    fclose(fileID);
    
    classIDs = lines{1};
    xCenters = lines{2};
    yCenters = lines{3};
    widths   = lines{4};
    heights  = lines{5};
    
    % Extract each annotated hand box in the image
    for j = 1:length(classIDs)
        cID = classIDs(j);
        
        % Convert normalized YOLO coordinates to pixel bounding box [x, y, w, h]
        wPix = widths(j) * imgW;
        hPix = heights(j) * imgH;
        xMin = (xCenters(j) * imgW) - (wPix / 2);
        yMin = (yCenters(j) * imgH) - (hPix / 2);
        
        % Keep coordinates inside valid image boundaries
        xMin = max(1, floor(xMin));
        yMin = max(1, floor(yMin));
        wPix = min(imgW - xMin, ceil(wPix));
        hPix = min(imgH - yMin, ceil(hPix));
        
        if wPix <= 5 || hPix <= 5, continue; end
        
        % Crop hand and resize to 224x224
        croppedHand = imcrop(img, [xMin, yMin, wPix, hPix]);
        if isempty(croppedHand), continue; end
        
        resizedHand = imresize(croppedHand, [224 224]);
        
        % Save cropped hand into class folder
        classFolder = fullfile(outputFolder, sprintf('class_%02d', cID));
        if ~exist(classFolder, 'dir')
            mkdir(classFolder);
        end
        
        cropCount = cropCount + 1;
        saveName = fullfile(classFolder, sprintf('crop_%d.jpg', cropCount));
        imwrite(resizedHand, saveName);
    end
    
    if mod(i, 500) == 0
        fprintf('Processed %d/%d images...\n', i, length(imgFiles));
    end
end

fprintf('\nExtraction Complete! Saved %d cropped hand images in: %s\n', cropCount, outputFolder);
