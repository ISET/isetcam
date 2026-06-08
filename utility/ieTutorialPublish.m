function htmlFile = ieTutorialPublish(fname,varargin)
% Publish a tutorial m-file as HTML in the same directory.
%
% Syntax:
%   htmlFile = ieTutorialPublish(fname)
%   htmlFile = ieTutorialPublish(fname,'param',value,...)
%
% Description:
%   This utility publishes a tutorial/script m-file to HTML so the output
%   file sits next to the source m-file. Figure snapshots are saved as
%   separate image files (PNG by default), not in a separate output folder.
%
% Inputs:
%   fname
%       Character vector or string identifying the m-file. Can be a full
%       path, relative path, or file on the MATLAB path. The .m extension
%       is optional.
%
% Optional parameter/value pairs:
%   'evalCode'         - Evaluate code while publishing (default true)
%   'showCode'         - Show source code in HTML (default true)
%   'maxHeight'        - Max image height in pixels (default 512)
%   'maxWidth'         - Max image width in pixels (default 512)
%   'imageFormat'      - Image format for figure snapshots (default 'png')
%   'createThumbnail'  - Create thumbnail image (default false)
%   'catchError'       - Catch and render errors in HTML (default true)
%   'stylesheet'       - Optional stylesheet file (default '')
%
% Output:
%   htmlFile
%       Full path to the published HTML file.
%
% Example:
%{
% Publish a tutorial in-place
% htmlFile = ieTutorialPublish('tutorials/scene/t_sceneIntroduction.m');
% web(htmlFile,'-browser');
%}
%
% See also:
%   publish
%
% Copyright ImagEval Consultants, LLC, 2026.

if ieNotDefined('fname')
    error('File name required.');
end

if isstring(fname), fname = char(fname); end

% Resolve source file.
[srcDir,~,srcExt] = fileparts(fname);
if isempty(srcExt)
    fname = [fname,'.m'];
    srcExt = '.m';
end

if ~strcmpi(srcExt,'.m')
    error('Input must reference an m-file.');
end

if isempty(srcDir)
    resolved = which(fname);
    if isempty(resolved), resolved = fullfile(pwd,fname); end
else
    resolved = fname;
end

if exist(resolved,'file') ~= 2
    error('Could not find file: %s',fname);
end

[sourceDir,sourceBase,sourceExt] = fileparts(resolved);
if ~strcmpi(sourceExt,'.m')
    error('Input must reference an m-file.');
end
sourceFile = [sourceBase,sourceExt];

p = inputParser;
p.addParameter('evalCode',true,@islogical);
p.addParameter('showCode',true,@islogical);
p.addParameter('maxHeight',512,@(x) isempty(x) || (isscalar(x) && isnumeric(x) && x > 0));
p.addParameter('maxWidth',512,@(x) isempty(x) || (isscalar(x) && isnumeric(x) && x > 0));
p.addParameter('imageFormat','png',@(x) ischar(x) || (isstring(x) && isscalar(x)));
p.addParameter('createThumbnail',false,@islogical);
p.addParameter('catchError',true,@islogical);
p.addParameter('stylesheet','',@(x) ischar(x) || (isstring(x) && isscalar(x)));
p.parse(varargin{:});
opts = p.Results;

if isstring(opts.imageFormat), opts.imageFormat = char(opts.imageFormat); end
if isstring(opts.stylesheet), opts.stylesheet = char(opts.stylesheet); end

publishOpts = struct( ...
    'format','html', ...
    'outputDir',sourceDir, ...
    'evalCode',opts.evalCode, ...
    'showCode',opts.showCode, ...
    'maxHeight',opts.maxHeight, ...
    'maxWidth',opts.maxWidth, ...
    'imageFormat',opts.imageFormat, ...
    'createThumbnail',opts.createThumbnail, ...
    'catchError',opts.catchError);

if ~isempty(opts.stylesheet)
    publishOpts.stylesheet = opts.stylesheet;
end

origDir = pwd;
cleanupObj = onCleanup(@() cd(origDir));
cd(sourceDir);
htmlFile = publish(sourceFile,publishOpts);

end
