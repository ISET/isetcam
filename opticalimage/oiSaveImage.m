function fName = oiSaveImage(oi, fName)
% Write png image approximating appearance of photon data
%
% Syntax:
%  fullName = oiSaveImage(oi,[fullpathname]);
%
% Inputs
%  oi:    Optical image
%  fName: Name of output file
%
% Outputs
%  fName: Full path to the output file
%
% Description:
%  Save out an 8-bit RGB image of the photon image as a 'png' file.  If the
%  name is not passed in, then the user is queried to select the fullpath
%  name of the output file.  The same display method as in the oiWindow is
%  used.  The image is not displayed. The file name of the output (full
%  path) is returned.
%
%  The rgb image is obtained from the scene via oiShowImage, which uses the
%  same method to render as determined by the parameters in the oiWindow.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:
%  sceneSaveImage, imageSPD

% Examples:
%{
% We save the data using the flags in the oiWindow, if it is open.
% Otherwise, the standard RGB with gam = 1.
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
oiWindow(oi);
fName = oiSaveImage(oi,'deleteMe');   % PNG is appended
img = imread(fName); ieNewGraphWin; image(img);
delete(fName);
%}

if ~exist('oi', 'var') || isempty(oi), oi = ieGetObject('oi'); end

% Get RGB file name (tif)
if ieNotDefined('fName')
    fName = vcSelectDataFile('session', 'w', 'png', 'Image file (png)');
end

gam = oiGet(oi, 'gamma');
renderFlag = oiGet(oi, 'render flag index'); % Integer

% The negative value means we do not bring up a window to show the image in
% this routine.
if isempty(renderFlag), renderFlag = -1;
else, renderFlag = -1 * abs(renderFlag);
end

% Scale to max of 1 for output below; needed for gray scale case.
RGB = oiShowImage(oi, renderFlag, gam);

% Make sure file full path is returned
[p, n, e] = fileparts(fName);
if isempty(p), p = pwd; end
if isempty(e), e = '.png'; end
if ispc
    % seems like I'm the only one for whom the default doesn't work, so
    % thinking maybe it is a windows thing?
    fName = fullfile(p, append(n, e));
else
    fName = fullfile(p, [n, e]);
end

% Always has a png extension.  So, no 'png' argument needed.
% Written out as 8 bit for PNG format.
imwrite(RGB, fName);

% Have a look
%  imagescRGB(RGB);

end