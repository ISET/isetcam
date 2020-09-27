function [s, msg] = dcrawInit(ext)
% Initialize dcraw for raw image file formats
%
%   dcraw([ext])
%
% Inputs:
%   ext - cell array of extensions to be linked with dcraw
%
% Outputs:
%   s   - status, 0 for success, -1 for failure
%   msg - error message if failed
%
% Notes:
%   To compile dcraw on mac, use:
%      llvm-gcc -o dcraw dcraw.c -lm -DNO_JPEG -DNO_LCMS -DNO_JASPER
% 
% Example:
%   dcraw
%
% HJ, VISTA TEAM, 2015

% Check inputs
if notDefined('ext'), ext = {'RAW', 'ARW', 'NEF'}; end
if ~iscell(ext), ext = {ext}; end

% Check if dcraw executable works
if ismac
    fp = fullfile(L3rootpath, 'external', 'dcraw', 'dcraw_mac');
elseif isunix
    fp = fullfile(L3rootpath, 'external', 'dcraw', 'dcraw_linux');
else
    error('no dcraw support for windows at this point');
end
if exist(fp, 'file') == 2
    [s, msg] = system(fp);
    if s == 1, s = 0; end
else
    s = -1; msg = 'file not exist';
    return
end

% Register dcraw for imformats
for ii = 1 : length(ext)
    if isempty(imformats(ext{ii}))
        formatS.ext = ext{ii};
        formatS.isa = @(x) true; % determine image format by its extension
        formatS.info = '';
        formatS.read = @dcrawRead;
        formatS.write = '';
        formatS.alpha = 0;
        formatS.description = 'Camera RAW file';
        imformats('add', formatS);
    end
end

end
