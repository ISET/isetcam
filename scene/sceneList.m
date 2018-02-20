% Scene types with optional parameters
%
%   sceneCreate('empty',wave)
%
% Macbeth scenes
%    sceneCreate('macbeth d65',patchSize);
%    sceneCreate('macbeth d50',patchSize);
%    sceneCreate('macbeth illC',patchSize);
%    sceneCreate('macbeth fluorescent',patchSize);
%    sceneCreate('macbeth tungsten',patchSize);
%    sceneCreate('macbeth ee_ir',patchSize);
%
%    sceneCreate('L star',barWidth,nBars,deltaEStep)
%
% Reflectance chart
%    sceneCreate('reflectance chart',pSize,sSamples,sFiles);
%    
% Monochromatic test
%    scene = sceneCreate('uniform monochromatic',wave,imsize);
%    scene = sceneCreate('multispectral')
%    scene = sceneCreate('rgb')
%
% Patterns
%    sceneCreate('rings rays',radialF,imsize)            
%    sceneCreate('harmonic',paramStruct)
%    sceneCreate{'sweep frequency',imSize,maxFreq)
%
%    sceneCreate('line d65',imSize)
%    sceneCreate('line ee',imSize,offset,wave)
%    sceneCreate('line ep',imSize,offset)
%    sceneCreate('bar',imSize,barWidth);
%
%    sceneCreate('vernier',type, params) % See sceneVernier
%
%    sceneCreate('point array',imageSize,pixelsBetweenPoints);
%    sceneCreate('grid lines',imageSize,pixelsBetweenLines);
%    sceneCreate('radial lines',imageSizem spectralType,nLines);
%    sceneCreate('slanted edge',imageSize,edgeSlope);
%    sceneCreate('checkerboard',pixelsPerCheck,numberOfChecks)
%
%    sceneCreate('frequency orientation', paramStruct)
%        paramStruct:  angles,freq,blockSize,contrast
%
%    sceneCreate('zone plate', imSize);
%    sceneCreate('moire orient',imSize, edgeSlope);
%
%    sceneCreate('linear Intensity Ramp', imSize)
%
%    sceneCreate('uniform Equal Energy', imSize, wave)
%    sceneCreate('uniform Equal Photon', imSize, wave)
%    sceneCreate('uniform d65', imSize)
%    sceneCreate('uniform bb', imSize, colorTemp, wave)
%    sceneCreate('white noise',row,col])
%
% Text
%    scene = sceneCreate('letter', 'g', fontSize, fontName, display);
%
%

