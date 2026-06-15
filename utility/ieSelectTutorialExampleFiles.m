function selectedFiles = ieSelectTutorialExampleFiles(allFiles, targetDir, scriptName)
% ieSelectTutorialExampleFiles - Optionally reduce a runnable file set to one requested script
%
% Syntax:
%   selectedFiles = ieSelectTutorialExampleFiles(allFiles, targetDir, scriptName)
%
% Description:
%   Matches a requested tutorial or example by bare script name, file name
%   with extension, path relative to the target directory, or full path.

if nargin < 3 || isempty(scriptName)
    selectedFiles = allFiles;
    return;
end

selectedFiles = allFiles([]);
selector = localNormalizeSelector(scriptName, targetDir);
for fileIndex = 1:numel(allFiles)
    filePath = fullfile(allFiles(fileIndex).folder, allFiles(fileIndex).name);
    if localMatchesSelector(filePath, selector, targetDir)
        selectedFiles(end+1) = allFiles(fileIndex); %#ok<AGROW>
    end
end

end

function selector = localNormalizeSelector(scriptName, targetDir)
%% Normalize user input for matching against file names and paths.

selector = strtrim(scriptName);
selector = strrep(selector, '\\', filesep);
selector = strrep(selector, '/', filesep);
if startsWith(selector, ['.' filesep])
    selector = selector(3:end);
end
if startsWith(selector, [targetDir filesep])
    selector = selector(numel(targetDir) + 2:end);
end

end

function tf = localMatchesSelector(filePath, selector, targetDir)
%% Match by basename, basename without extension, relative path, or full path.

[~, fileName, fileExt] = fileparts(filePath);
relativePath = erase(filePath, [targetDir filesep]);
tf = strcmp(fileName, selector) || ...
    strcmp([fileName fileExt], selector) || ...
    strcmp(relativePath, selector) || ...
    strcmp(filePath, selector);

end