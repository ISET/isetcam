function oi = oiFromFile(imageData,imageType, meanLuminance, dispCal, wList)
% Read an RGB file (e.g. from Code V) and insert it into an optical image
%
% Synopsis
%    oi = oiFromFile(I,imType)
%
% Description:
%   Some optics analysis programs (e.g., Code V, Zemax) will write out an
%   rgb file that describes an image passing through the optics.  This
%   function enables you to read that image in to an OI and use it as an
%   approximation to the spectral irradiance.
%
% Inputs:
%  imageData: Typically, this is the name of an RGB image file.  But, it
%             may also be RGB data, rather than the file name
%  imageType: 'multispectral' or 'rgb' or 'monochrome'
%              When 'rgb', the imageData might be RGB format.
%  dispCal:   A display structure used to convert RGB to spectral data.
%             For the typical case an emissive display the illuminant SPD is
%             modeled and set to the white point of the display
%  wList:     The scene wavelength samples
%
% Returns
%   oi
%
% ieExamplesPrint('oiFromFile');
%
% See also
%   sceneFromFile

% Examples:
%{
  filename = 'eagle.jpg';
  oiFromFile(filename,'rgb');
  oiWindow(oi);
%}
%{
  filename = 'StuffedAnimals_tungsten-hdrs.mat';
  oi = oiFromFile(filename,'multispectral');
  oiWindow(oi);
%}
%{
  filename = 'ISO-Chart1.png';
  oi = oiFromFile(filename,'monochrome');
  oiWindow(oi);
%}

%% Parse

if notDefined('imageData')
    % If imageData is not sent in, we ask the user for a filename.
    % The user may or may not have set the imageType.  Sigh.
    if notDefined('imageType'), [imageData,imageType] = vcSelectImage;
    else, imageData = vcSelectImage(imageType);
    end
    if isempty(imageData), oi = []; return; end
end

if ischar(imageData)
    % I is a file name.  Check that it exists on the path
    filename = which(imageData); 
    if ~exist(filename,'file'), error('%s not found\n',filename); end
end
if notDefined('imageType'), error('Image type specification required.'); end
imageType = ieParamFormat(imageType);

if notDefined('dispCal'), dispCal = displayCreate('LCD-Apple'); end
if notDefined('meanLuminance'), meanLuminance = []; end
if notDefined('wList'), wList = 400:10:700; end

%%  Read the file as a scene
scene = sceneFromFile(filename,imageType,meanLuminance,dispCal,wList);
scene = sceneAdjustIlluminant(scene,'D65');

%% Convert the scene photons to optical image photons, scaling by pi
oi = oiCreate;
oi = oiSet(oi,'wave',sceneGet(scene,'wave'));
oi = oiSet(oi,'fov',sceneGet(scene,'fov'));
oi = oiSet(oi,'optics model','Ray trace');

% Ray trace optics parameters could be set here
%
disp('Suggest setting ray trace optical parameters');

% Scale the photons for the radiance to irradiance change
oi = oiSet(oi,'photons',sceneGet(scene,'photons')/pi);

end

