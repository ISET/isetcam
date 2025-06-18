function files = ieFindFiles(rootDir,ext)
% findFiles finds with a particular extension in a directory and its
% subdirectories. 
%
% Synopsis
%   files = ieFindFiles(rootDir,ext)
%
% Input:
%   rootDir: The root directory to search.
%   ext - file extension (first character can be '.', or not). 
%
% Output:
%   files: A cell array of full file paths to the files in the directory
%   and its subdirectories, with an extension of ext.
%
% See also
%

% Example:
%{
files = ieFindFiles(fullfile(fiToolboxRootPath,'data'),'mat');
disp(files);
%}

if ~isequal(ext(1),'.'), ext = ['.',ext]; end

files = {}; % Initialize an empty cell array to store file paths
dirData = dir(rootDir); % Get directory contents

for i = 1:length(dirData)
    fileName = dirData(i).name;
    fullPath = fullfile(rootDir, fileName);

    if dirData(i).isdir && ~strcmp(fileName, '.') && ~strcmp(fileName, '..')
        % If it's a subdirectory (and not '.' or '..'), recursively call the function
        subFiles = ieFindFiles(fullPath,ext);
        files = [files; subFiles]; % Append sub-directory results
    elseif ~dirData(i).isdir && endsWith(fileName, ext)
        % If it's a .mat file, add it to the list
        files = [files; {fullPath}];
    end
end

end
