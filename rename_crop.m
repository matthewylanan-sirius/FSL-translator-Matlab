% Clear workspace and command window
clear; clc;

% Exact class mapping from Roboflow data.yaml (0 to 40)
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
    'a', 'b', 'c', 'd', 'e', 'f', 'g', ...
    'h', 'i', 'j', 'k', 'l', 'm', 'n', ...
    'o', 'p', 'q', 'r', 's', 't', 'u', ...
    'v', 'w', 'x', 'y', 'z' ...          % class_15 - class_40
};

% Path to cropped dataset folder
datasetFolder = fullfile(pwd, 'cropped_7k_dataset');

% Verify dataset folder exists before running
if ~exist(datasetFolder, 'dir')
    error('Target folder "%s" does not exist in the current working directory.', datasetFolder);
end

% Rename generic class folders to actual FSL phrase names
for i = 1:length(classNames)
    oldFolderName = sprintf('class_%02d', i - 1); % YOLO 0-indexed naming
    oldPath = fullfile(datasetFolder, oldFolderName);
    
    rawName = classNames{i};
    % Clean up name for OS-safe folder naming (e.g., replace spaces with underscores)
    safeName = regexprep(rawName, '[^\w\-]', '_');
    newPath = fullfile(datasetFolder, safeName);
    
    if exist(oldPath, 'dir')
        if exist(newPath, 'dir') && ~strcmp(oldPath, newPath)
            fprintf('Warning: Destination "%s" already exists. Merging/Skipping...\n', safeName);
        else
            movefile(oldPath, newPath);
            fprintf('Renamed: %s -> %s\n', oldFolderName, safeName);
        end
    else
        fprintf('Folder %s not found (already renamed or missing).\n', oldFolderName);
    end
end

disp('Folder renaming process complete!');