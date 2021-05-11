function fullName = vcSelectDataFile(dataType, rw, ext, windowTitle)
%Select a data file name for reading or writing
%
%  fullName = vcSelectDataFile(dataType,[rw],[ext],[windowTitle])
%
%  dataType is used to suggest the starting directory.
%  Include stayput (i.e., don't change), or sensor, optics,
%  and any of the directory names inside of data
%
%  To choose a data file for reading or writing, use this routine.  The
%  parameter dataType is a clue about the proper directory to use to find
%  or write the file.
%
%  To specify whether the file is for reading or writing, use rw = 'r' for
%  reading and rw = 'w' for writing. Default is read.
%
%  You may also pass in an extension to use for filtering file names.
%  Returns fulName = [] on Cancel.
%
%  WINDOWTITLE is a string for the read window to help the user know the
%  purpose.
%
%   The dataType values are:
%
%    {'session','stayput'}
%       The last selected directory, or the current working directory if
%       none was selected previously.
%    {'data'}        --    data.
%    {'algorithm'}   --   ISET-Algorithms
%    otherwise reverts to 'session'
%
% Examples
%  fullName = vcSelectDataFile('session','r')
%  fullName = vcSelectDataFile('session','r','tif')  -- Select only files with a .tif extension.
%  fullName = vcSelectDataFile('data','w')
%  data = ieReadSpectralData(vcSelectDataFile('sensor'))
%
%  fullName = vcSelectDataFile('data','r')
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO
% Possibly, we should enforce the extension on the returned file name?

if ieNotDefined('dataType'), dataType = 'session'; end
if ieNotDefined('rw'), rw = 'r'; end
if ieNotDefined('ext'), ext = '*'; end

curDir = pwd;

% We remember the last directory the user chose. On the first call, this
% variable is empty.  But from then on, we use it.
persistent pDir;

switch lower(dataType)
    case {'session', 'stayput'}
        if isempty(pDir), fullPath = pwd;
        else, fullPath = pDir;
        end
    case {'algorithm'}
        fullPath = fullfile(isetRootPath, 'ISET-Algorithms');
        if ~exist(fullPath, 'dir')
            if ~isempty(pDir), fullPath = pDir;
            else, fullPath = isetRootPath;
            end
        end
    case {'data'}
        fullPath = fullfile(isetRootPath, 'data');

        % Check that directory exists.  If not, try using the last directory.
        % Otherwise, just go to data.
        if ~exist(fullPath, 'dir')
            if ~isempty(pDir), fullPath = pDir;
            else, fullPath = isetRootPath;
            end
        end
    case {'displays'}
        fullPath = fullfile(isetRootPath, 'data', 'displays');
        if ~exist(fullPath, 'dir')
            if ~isempty(pDir), fullPath = pDir;
            else, fullPath = isetRootPath;
            end
        end
    otherwise
        if isempty(pDir), fullPath = pwd;
        else, fullPath = pDir;
        end
end

chdir(fullPath);
fileFilter = ['*.', ext];
switch lower(rw)
    case 'r'
        if ieNotDefined('windowTitle'), windowTitle = 'ISET: Read Data';
        end
        [fname, pname] = uigetfile(fileFilter, windowTitle);
    case 'w'
        if ieNotDefined('windowTitle'), windowTitle = 'ISET: Write Data';
        end
        [fname, pname] = uiputfile(fileFilter, windowTitle);
    otherwise
        error('Read/Write set incorrectly')
end

% Clean up and go home
chdir(curDir)
if isequal(fname, 0) || isequal(pname, 0)
    fullName = [];
    disp('User canceled');
else
    fullName = fullfile(pname, fname);
    pDir = pname;
end

end
