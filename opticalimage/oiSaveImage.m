function fName = oiSaveImage(oi,fName,gam)
%Write png image approximating appearance of photon data
%
%  fullName = oiSaveImage(oi,[fullpathname],[gam]);
%
%   Save out an RGB image of the photon image as a png file.  If the name
%   is not passed in, then the user is queried to select the fullpath name
%   of the output file.  This routine is used for scenes.  sceneSaveImage
%   is used for scenes.
%
% Copyright ImagEval Consultants, LLC, 2003.


if ~exist('oi','var') || isempty(oi), oi = vcGetObject('oi'); end

% Get RGB file name (tif)
if ieNotDefined('fName')
    fName = vcSelectDataFile('session','w','png','Image file (png)');
end

% Get rgb image from photon data.  Gamma either defined here or from the
% open window.
if ~exist('gam','var'),     RGB = oiGet(oi,'rgb image');
else                        RGB = oiGet(oi,'rgb image',gam);
end

imwrite(RGB,fName,'png');

end