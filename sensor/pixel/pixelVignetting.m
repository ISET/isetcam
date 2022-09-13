function [opticalImage,pixel,optics] = ...
    pixelVignetting(opticalimage,pixel,optics);
%
% [opticalImage,pixel,optics] = ...
%   pixelVignetting(opticalimage,pixel,optics);
%
% AUTHOR:	PC
% DATE: 	06/20/2003
% PURPOSE:
%   Apply pixel vignetting due to metal layers. Uses Phase-Space based
%   method
%

% Setting up local variables
irradianceImage = sceneGet(opticalImage,'photons');
distance = sceneGet(opticalImage,'distance');
nWaves = sceneGet(opticalImage,'nWaves');
fNumber = opticsGet(optics,'fnumber');
nRows = sensorGet(ISA,'rows'); nCols = sensorGet(ISA,'cols');
pitchX = sensorGet(ISA,'deltax'); pitchY = sensorGet(ISA,'deltay');


fNumber = 2; theta = atan(1/(2*fNumber));
nRows = 32; nCols = 34; pitchX = 0.1; pitchY = 0.1; distance = 7;
width = pitchX/2; step = 1;
if mod(nCols,2) == 0
    coordX = pitchX*(0:step:(nCols/2-1))+pitchX/2;
else
    coordX = pitchX*(0:step:nCols/2);
end
if mod(nRows,2) == 0
    coordY = pitchY*(0:step:(nRows/2-1))+pitchY/2;
else
    coordY = pitchY*(0:step:nRows/2);
end

% Every pixel has its own chief ray angle
[chiefRayAnglesX,chiefRayAnglesY] = ...
    meshgrid(atan((coordX/2)/distance)*2,atan((coordY/2)/distance)*2);

% Forward propagation of PS diagram (from surface to photodetector)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:size(chiefRayAnglesX,1)
    for jj = 1:size(chiefRayAnglesX,2)
        theta1(ii,jj) = -theta+chiefRayAnglesX(ii,jj);
        theta2(ii,jj) = theta+chiefRayAnglesX(ii,jj);
        nAir = 1; nSi3N4 = 2.08; nSiO2 = 1.46;
        dSi3N4 = 0.1; dSiO2 = 0.6;
        [xIn,uIn] = ...
            createPS(-width/2,width/2,theta1(ii,jj),theta2(ii,jj),nAir);
        [xOut,uOut] = ...
            propagatePS(xIn,uIn,[dSi3N4 dSiO2],[nSi3N4 nSiO2],'non-paraxial');
        % Buried Photodetector
        ratioModelX(ii,jj) = ...
            length(find(abs(xOut(:)) <= width/2))/length(xOut(:));
        % Surface Photodetector
        ratioModelSurfaceX(ii,jj) = ...
            length(find(abs(xIn(:)) <= width/2))/length(xIn(:));
    end
end

for ii = 1:size(chiefRayAnglesY,1)
    for jj = 1:size(chiefRayAnglesY,2)
        theta1(ii,jj) = -theta+chiefRayAnglesY(ii,jj);
        theta2(ii,jj) = theta+chiefRayAnglesY(ii,jj);
        nAir = 1; nSi3N4 = 2.08; nSiO2 = 1.46;
        dSi3N4 = 0.1; dSiO2 = 0.6;
        [xIn,uIn] = ...
            createPS(-width/2,width/2,theta1(ii,jj),theta2(ii,jj),nAir);
        [xOut,uOut] = ...
            propagatePS(xIn,uIn,[dSi3N4 dSiO2],[nSi3N4 nSiO2],'non-paraxial');
        % Buried Photodetector
        ratioModelY(ii,jj) = ...
            length(find(abs(xOut(:)) <= width/2))/length(xOut(:));
        % Surface Photodetector
        ratioModelSurfaceY(ii,jj) = ...
            length(find(abs(xIn(:)) <= width/2))/length(xIn(:));
    end
end
pixelVignetting_quadrant = (ratioModelX.*ratioModelY) ./ ...
    (ratioModelSurfaceX.*ratioModelSurfaceY);
mesh(pixelVignetting_quadrant)

pixelVignetting = ones(nRows,nCols);
if (mod(nCols,2) == 0)&(mod(nRows,2) == 0)
    pixelVignetting((nRows/2+1):nRows,(nCols/2+1):nCols) = ...
        pixelVignetting_quadrant;
    pixelVignetting(1:nRows/2,(nCols/2+1):nCols) = ...
        flipud(pixelVignetting_quadrant);
    pixelVignetting((nRows/2+1):nRows,1:nCols/2) = ...
        fliplr(pixelVignetting_quadrant);
    pixelVignetting(1:nRows/2,1:nCols/2) = ...
        fliplr(flipud(pixelVignetting_quadrant));
elseif (mod(nCols,2) ~= 0)&(mod(nRows,2) ~= 0)
    pixelVignetting((nRows+1)/2:nRows,(nCols+1)/2:nCols) = ...
        pixelVignetting_quadrant;
    pixelVignetting(1:(nRows+1)/2,(nCols+1)/2:nCols) = ...
        flipud(pixelVignetting_quadrant);
    pixelVignetting((nRows+1)/2:nRows,1:(nCols+1)/2) = ...
        fliplr(pixelVignetting_quadrant);
    pixelVignetting(1:(nRows+1)/2,1:(nCols+1)/2) = ...
        fliplr(flipud(pixelVignetting_quadrant));
elseif (mod(nCols,2) ~= 0)&(mod(nRows,2) == 0)
    pixelVignetting((nRows/2+1):nRows,(nCols+1)/2:nCols) = ...
        pixelVignetting_quadrant;
    pixelVignetting(1:nRows/2,(nCols+1)/2:nCols) = ...
        flipud(pixelVignetting_quadrant);
    pixelVignetting((nRows/2+1):nRows,1:(nCols+1)/2) = ...
        fliplr(pixelVignetting_quadrant);
    pixelVignetting(1:nRows/2,1:(nCols+1)/2) = ...
        fliplr(flipud(pixelVignetting_quadrant));
elseif (mod(nCols,2) == 0)&(mod(nRows,2) ~= 0)
    pixelVignetting((nRows+1)/2:nRows,(nCols/2+1):nCols) = ...
        pixelVignetting_quadrant;
    pixelVignetting(1:(nRows+1)/2,(nCols/2+1):nCols) = ...
        flipud(pixelVignetting_quadrant);
    pixelVignetting((nRows+1)/2:nRows,1:nCols/2) = ...
        fliplr(pixelVignetting_quadrant);
    pixelVignetting(1:(nRows+1)/2,1:nCols/2) = ...
        fliplr(flipud(pixelVignetting_quadrant));
end
mesh(pixelVignetting)

% Applying the pixel vignetting correction
for ii=1:nWaves
    filteredIrradianceImage(:,:,ii) = ...
        pixelVignetting .* irradianceImage(:,:,ii);
end
opticalImage.data.photons = filteredIrradianceImage;

return