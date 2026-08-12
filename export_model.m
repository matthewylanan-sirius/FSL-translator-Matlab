% Load your trained MATLAB model
load('fsl_mobilenetv2_model.mat', 'fslModel');

% Export to ONNX format
outputFileName = 'fsl_mobilenetv2.onnx';
exportONNXNetwork(fslModel, outputFileName);

fprintf('Model successfully exported to %s\n', outputFileName);