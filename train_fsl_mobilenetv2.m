%% 
clear; clc; close all;

% 1. Load Dataset
% Ensure cropped_7k_dataset contains subfolders:
% 'ano-pangalan-mo', 'kamusta-ka', 'magandang-umaga', 'mahal-kita',
% 'pasensya-na', 'salamat', 'email'
datasetFolder = fullfile(pwd, 'cropped_7k_dataset');
if ~exist(datasetFolder, 'dir')
    error("Dataset folder 'cropped_7k_dataset' not found in current directory: %s", pwd);
end

imds = imageDatastore(datasetFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

disp("=== Class Image Counts ===");
disp(countEachLabel(imds));

% 2. Split Data (80% Training, 20% Validation)
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomized');

% 3. Set Input Image Size & Data Augmentation
% MobileNetV2 expects 224x224x3 RGB images
inputSize = [224 224 3];

augmenter = imageDataAugmenter(...
    'RandXReflection', true, ...       % Horizontal flips for hand angles
    'RandXScale', [0.95 1.05], ...    % Slight zoom range
    'RandYScale', [0.95 1.05], ...
    'RandRotation', [-10 10]);         % Slight hand tilts

augimdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'DataAugmentation', augmenter, ...
    'ColorPreprocessing', 'gray2rgb');

augimdsValidation = augmentedImageDatastore(inputSize(1:2), imdsValidation, ...
    'ColorPreprocessing', 'gray2rgb');

% 4. Load MobileNetV2 Network Architecture
net = mobilenetv2;
lgraph = layerGraph(net);
numClasses = numel(categories(imdsTrain.Labels));

% Replace Output Fully Connected Layer ('Logits')
newFc = fullyConnectedLayer(numClasses, ...
    'Name', 'new_logits', ...
    'WeightLearnRateFactor', 10, ...
    'BiasLearnRateFactor', 10);
lgraph = replaceLayer(lgraph, 'Logits', newFc);

% Dynamically find and replace the final classification output layer
lastLayerName = lgraph.Layers(end).Name;
newClassOutput = classificationLayer('Name', 'new_classoutput');
lgraph = replaceLayer(lgraph, lastLayerName, newClassOutput);

% 5. Configure Training Options
options = trainingOptions('adam', ...
    'MiniBatchSize', 16, ...
    'MaxEpochs', 12, ...
    'InitialLearnRate', 0.0003, ...
    'ValidationData', augimdsValidation, ...
    'ValidationFrequency', 10, ...
    'Plots', 'training-progress', ...
    'Verbose', true, ...
    'ExecutionEnvironment', 'gpu');

% 6. Train the Model
disp("Starting training on 6 clean keyframe classes...");
[fslModel, trainInfo] = trainNetwork(augimdsTrain, lgraph, options);

% 7. Save Model File
save('fsl_mobilenetv2_model.mat', 'fslModel');
disp("Model successfully saved as 'fsl_mobilenetv2_model.mat'.");
categories(imdsTrain.Labels)

% 8. Evaluate & Display Confusion Matrix
disp("Evaluating model performance on validation set...");
[predictedLabels, scores] = classify(fslModel, augimdsValidation);
valAccuracy = mean(predictedLabels == imdsValidation.Labels) * 100;
fprintf("Final Validation Accuracy: %.2f%%\n", valAccuracy);

figure('Name', 'FSL MobileNetV2 Confusion Matrix');
plotconfusion(imdsValidation.Labels, predictedLabels);
title(sprintf('MobileNetV2 Validation Accuracy: %.2f%%', valAccuracy));