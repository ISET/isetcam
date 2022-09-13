function [rgbImages,rgbOverlays] = imagehc2rgb(obj,nBands,deltaPercent)
% Create a set of rgb images in wavebands of multispectral data
%
%   rgbImages = imagehc2rgb(obj,[nBands=5],[deltaPercent = (10,10)])
%
% obj:    A multispectral scene or optical image
% nBands: The number of waveband images; default is 5 over the wave
%         representation in the object
% deltaPercent:  
%
% Outputs
% rgbImages: A set of rgb images that can be written out or viewed using
%            rgbImages(row,col,3,nImages)
% rgbOverlays: 
%
% See also:  hc* functions, imageSPD, s_imagehc2rgb.m

% Examples:
%{
  scene = sceneCreate; rgb = imagehc2rgb(scene);
  N = size(rgb,4); for ii=1:N, ieNewGraphWin; imagescRGB(rgb(:,:,:,ii)); end
%}
%{
  scene = sceneCreate;
  oi = oiCreate; oi = oiCompute(oi,scene);  rgb = imagehc2rgb(oi);
  N = size(rgb,4); for ii=1:N, ieNewGraphWin; imagescRGB(rgb(:,:,:,ii)); end
%}
%{
  scene = sceneCreate; 
  [~,rgbOverlay] = imagehc2rgb(scene,5,[20 15]);
  imtool(rgbOverlay);
%}

%% Parameters
if ieNotDefined('obj'), obj = sceneCreate; end
if ieNotDefined('nBands'), nBands = 5; end
if ieNotDefined('deltaPercent'), deltaPercent = [10,10]; end

% Slightly different calls for the scene/opticalimage cases.  But logic is
% the same
switch obj.type
    case 'scene'
        w = sceneGet(obj,'wave');
        r = sceneGet(obj,'rows'); c = sceneGet(obj,'cols');
    case 'opticalimage'
        w = oiGet(obj,'wave');
        r = oiGet(obj,'rows'); c = oiGet(obj,'cols');
    otherwise
        error('Bad object type %s\n',obj.type);
end

wBands    = zeros(1,nBands);
bandWidth = floor(numel(w)/nBands);

% We divide up the wavelength in nBands.  Each band is this many w
% steps wide
for ii=1:nBands, wBands(ii) = w(floor((ii-1)*bandWidth)+1); end
rgbImages = zeros(r,c,3,nBands);

%% Adjust initial scene to waveband and make image

dWave = w(2)-w(1);
for ii=1:nBands    
    if ii==nBands, wList = wBands(ii):dWave:w(end);
    else,          wList = wBands(ii):dWave:wBands(ii+1);
    end

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

if nargout == 2
    % User asks for the overlay image.  So far only one way to put it
    % in.
    %
    % deltaPercent is the amount of the shift in the row/col dimensions
    %
    % The shortest waveband is at the lower left and the longer
    % wavelengths are behind.  We should create other algorithms in
    % the future.

    % Row and col of each image
    [r,c,~] = size(rgb);
    rStep = round(r*deltaPercent(1)/100);
    cStep = round(r*deltaPercent(2)/100);

    % Make the image a bit bigger so there is some white space around
    row = r + (nBands+1)*rStep;
    col = c + (nBands+1)*cStep;
    rgbOverlays = ones(row,col,3);

    % Paste from back to front
    for ii=nBands:-1:1
        rStart = floor((nBands-ii)*rStep + rStep); rEnd = (rStart+r-1);
        cStart = floor((ii-1)*cStep + cStep);      cEnd = (cStart+c-1);
        rgbOverlays(rStart:rEnd,cStart:cEnd,:) = squeeze(rgbImages(:,:,:,ii));
    end   

end
%% End
