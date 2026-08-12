% Clear workspace
clear; clc;

% Exact class mapping from your Roboflow data.yaml file
classNames = { ...
    'Ikinalulugod-kitang-makilala', ... % class_00
    'Magandang-gabi', ...               % class_01
    'Magandang-hapon', ...              % class_02
    'Magandang-umaga', ...              % class_03
    'Pasensya-na', ...                  % class_04
    'ano-pangalan-mo', ...              % class_05
    'email', ...                        % class_06
    'i-m fine', ...                     % class_07
    'kamusta', ...                      % class_08
    'kamusta-ka', ...                   % class_09
    'lodi', ...                         % class_10
    'mahal-kita', ...                   % class_11
    'maraming-salamat', ...             % class_12
    'paalam', ...                       % class_13
    'pakiusap', ...                     % class_14
    'wala-yun' ...                      % class_15
};

% Path to cropped dataset
datasetFolder = fullfile(pwd, 'cropped_7k_dataset');

% Rename generic class folders to actual FSL phrase names
for i = 1:length(classNames)
    oldFolderName = sprintf('class_%02d', i - 1); % YOLO is 0-indexed
    oldPath = fullfile(datasetFolder, oldFolderName);
    
    rawName = classNames{i};
    % Clean up name for OS-safe folder naming
    safeName = regexprep(rawName, '[^\w\-]', '_');
    newPath = fullfile(datasetFolder, safeName);
    
    if exist(oldPath, 'dir')
        movefile(oldPath, newPath);
        fprintf('Renamed %s -> %s\n', oldFolderName, safeName);
    else
        fprintf('Folder %s not found (may already be renamed).\n', oldFolderName);
    end
end

disp('Folder renaming complete!');