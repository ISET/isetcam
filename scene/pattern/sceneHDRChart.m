function scene = sceneHDRChart(dRange,nLevels,rowsPerLevel,maxL,il)
% Create a HDR chart of horizontal strips from dark to bright
%
%   scene = sceneHDRChart(dRange,nLevels,rowPerLevel,maxL,il)
%
% Inputs
%  dRange:        The dynamic range of the scene
%  nLevels:       Number of luminance steps (log spacing, N=10)
%  rowsPerLevel:  Rows per luminance level
%  maxL:          Maximum luminance
%  il:            Illuminant
%
% Returns
%   scene:         HDR chart as a scene
%
% See also
%   sceneReflectanceChart, macbethChartCreate

%Examples:
%{
  rowsPerLevel = 12; nLevels = 30; dRange = 10^3.5;
  scene = sceneHDRChart(dRange,nLevels,rowsPerLevel);
  sceneWindow(scene);
%}
%{
  scene = sceneHDRChart;
  sceneWindow(scene);
%}

if ieNotDefined('dRange'),  dRange  = 10^4; end
if ieNotDefined('nLevels'), nLevels = 12; end
if ieNotDefined('rowsPerLevel'),   rowsPerLevel   = 8; end

% Default scene
scene = sceneCreate;
wave = sceneGet(scene,'wave');

if ieNotDefined('il'), il = illuminantCreate('d65',wave); end
illPhotons = illuminantGet(il,'photons');

% Spatial arrangement
r = nLevels*rowsPerLevel; c = r;
nWave = length(wave);

% Convert the scene reflectances into photons assuming an equal energy
% illuminant.
reflectances = logspace(0,log10(1/dRange),nLevels);
photons = repmat(illPhotons,[1,length(reflectances)]);
photons = photons*diag(reflectances);
photons = photons';

img = zeros(r,c,nWave);
for ll = 1:nLevels
    clear tmp
    tmp(1,1,:) =  photons(ll,:);
    tmp = repmat(tmp,[rowsPerLevel,c]);
    theseRows = (ll-1)*rowsPerLevel + (1:rowsPerLevel);
    img(theseRows,:,:) = tmp;
end

scene = sceneSet(scene,'photons',img);

if ieNotDefined('maxL'), return;
else, scene = sceneSet(scene,'max luminance',maxL);
end

end




