function [scene,rect] = sceneCrop(scene,rect)
%Crop scene data.
%
% Synopsis
%  [scene,rect] = sceneCrop(scene,[rect])
%
% Description
%   The image axis is (1,1) in the upper left.  Increasing y-values run
%   down the image.  Increasing x-values run to the right.
%   The rect parameters are (x,y,width,height).
%   (x,y) is the upper left corner of the rectangular region
%
%Purpose:
%   Crop the data (photons) in the scene or optical image to within the
%   rectangle, rect. If rect is not defined a graphical routine is
%   initiated for selecting the rectangle.  The values of rect can be
%   returned.
%
%   Because these are multispectral data, we can't use the usual imcrop.
%   Instead, we use ieROISelect to return the selected data.  Then we turn
%   the selected data into a photon image and reset the relevant parameters
%   in the scene structure.
%
% Example:
%  [val,scene] = vcGetSelectedObject('SCENE');
%  newScene = sceneCrop(scene);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('scene'), error('You must define a scene.'); end

if ieNotDefined('rect')
    [roiLocs,roi] = ieROISelect(scene);
    rect = round(roi.Position);
else
    cmin = rect(1); cmax = rect(1)+rect(3);
    rmin = rect(2); rmax = rect(2)+rect(4);
    [c,r] = meshgrid(cmin:cmax,rmin:rmax);
    roiLocs = [r(:),c(:)];
end

% The number of selected columns and rows
c = rect(3)+1; r = rect(4)+1;
% wave = sceneGet(scene,'nwave');

% These are in XW format.
photons = vcGetROIData(scene,roiLocs,'photons');
photons = XW2RGBFormat(photons,r,c);

% Now build up the new object.
scene = sceneClearData(scene);
scene = sceneSet(scene,'photons',photons);

% If there is a depth map, we crop it.
if isfield(scene,'depthMap')
    dmap  = sceneGet(scene,'depth map');
    dmap  = imcrop(dmap,rect);
    scene = sceneSet(scene,'depth map',dmap);
end

% ZLY: If a spatial spectral illuminant, crop that too.
if isequal(sceneGet(scene, 'illuminant format'), 'spatial spectral')
    illPhotons = vcGetROIData(scene,roiLocs,'illuminant photons');
    illPhotons = XW2RGBFormat(illPhotons, r, c);
    scene = sceneSet(scene, 'illuminant photons', illPhotons);
end

% Recalculate the luminance
[luminance, meanL] = sceneCalculateLuminance(scene);

scene = sceneSet(scene,'luminance',luminance);
scene = sceneSet(scene,'meanLuminance',meanL);

% Store the rect and clear out incorrect metadata.  Maybe we should be
% updating.
scene.metadata.rect = rect;
if isfield(scene.metadata,'coordinates')
    scene.metadata = rmfield(scene.metadata,'coordinates'); 
end

end





