function output = pathToLinux(inputPath)
%PATHTOLINUX Convert Windows path to Linux
%   David Cardinal, 2023-2024
% On Windows the Docker
% paths are Linux-format, so the native fullfile and fileparts
% don't work right.
if ispc
    if isequal(fullfile(inputPath), inputPath)
        if numel(inputPath) > 3 && isequal(inputPath(2:3),':\')
            % assume we have a drive letter
            output = inputPath(3:end);
        else
            output = inputPath;
        end
        output = strrep(output, '\','/');
    else
        output = strrep(inputPath, '\','/');
    end
else
    output = inputPath;
end

end

