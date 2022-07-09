function rgbImages = imagehc2rgb(obj,nBands)
% Create a set of rgb images in wavebands of multispectral data
%
%   rgbImages = imagehc2rgb(obj,[nBands=5])
%
% obj:    A multispectral scene or optical image
% nBands: The number of waveband images; default is 5 over the wave
%         representation in the object
%
% rgbImages: A set of rgb images that can be written out or viewed using
%            rgbImages(row,col,3,nImages)
%
% Example:
%  scene = sceneCreate; rgb = imagehc2rgb(scene);
%  N = size(rgb,4); for ii=1:N, ieNewGraphWin; imagescRGB(rgb(:,:,:,ii)); end
%
%  oi = oiCreate; oi = oiCompute(oi,scene);  rgb = imagehc2rgb(oi);
%  N = size(rgb,4); for ii=1:N, vcNewGraphWin; imagescRGB(rgb(:,:,:,ii)); end
%
%  rgb = imagehc2rgb(scene,10);
%  N = size(rgb,4); for ii=1:N, vcNewGraphWin; imagescRGB(rgb(:,:,:,ii)); end
%
% See also:  hc* functions, imageSPD, s_imagehc2rgb.m
%
% Copyright Imageval LLC, 2014


%% Parameters
if ieNotDefined('obj'), obj = sceneCreate; end
if ieNotDefined('nBands'), nBands = 5; end

% Slightly different calls for the scene/opticalimage cases.  But logic is
% the same
switch obj.type
    case 'scene'
        nWave = sceneGet(obj,'nwave'); w = sceneGet(obj,'wave');
        r = sceneGet(obj,'rows'); c = sceneGet(obj,'cols');
    case 'opticalimage'
        nWave = oiGet(obj,'nwave');    w = oiGet(obj,'wave');
        r = oiGet(obj,'rows'); c = oiGet(obj,'cols');
    otherwise
        error('Bad object type %s\n',obj.type);
end

wStep  = floor(nWave/nBands);
nBands = floor(nWave/wStep);
wBands = zeros(1,nBands);
for ii=1:nBands, wBands(ii) = w(1 + (ii-1)*wStep); end
rgbImages = zeros(r,c,3,nBands);

%% Adjust initial scene to waveband and make image

for ii=1:(nBands-1)
    wList = wBands(ii):10:wBands(ii+1);
    switch obj.type
        case 'scene'
            s = sceneInterpolateW(obj,wList);
            rgb = imageSPD(sceneGet(s,'photons'),wList,1,r,c,-1);
        case 'opticalimage'
            s = oiInterpolateW(obj,wList);
            rgb = imageSPD(oiGet(s,'photons'),wList,1,r,c,-1);
    end
    % vcNewGraphWin; imagescRGB(rgb);
    rgbImages(:,:,:,ii) = rgb;
    
end
%% End
