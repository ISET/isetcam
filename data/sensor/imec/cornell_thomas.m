function thisR = cbBoxCreate(varargin)
% Build basic cornell box scene with measured light and reflectance
%
% Synopsis:
%   thisR = cbBoxCreate
%
% Inputs:
%   N/A
%
% Returns:
%   thisR   - recipe of cornell box
%
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('surfacecolor', 'redgreen', @ischar);
p.parse(varargin{:});
surfaceColor = p.Results.surfacecolor;

%% Read recipe
thisR = piRecipeDefault('scene name', 'cornell box reference');
%% Remove current existing lights
piLightDelete(thisR, 'all');
%% Turn the object to area light

areaLight = piLightCreate('lamp', 'type', 'area');
lightName = 'cbox-lights-1';
areaLight = piLightSet(areaLight, 'spd val', lightName);

assetName = 'AreaLight_O';
% Move area light above by 0.5 cm
% thisR.set('asset', assetName, 'world translate', [0 0.005 0]);
thisR.set('asset', assetName, 'obj2light', areaLight);

assetNameCube = 'CubeLarge_O';
thisR.set('asset', assetNameCube, 'scale', [1 1.2 1]);
%{
wave = 400:10:700;
lgt = ieReadSpectra(lightName, wave);
ieNewGraphWin;
plot(wave, lgt);
grid on; box on;
xlabel('Wavelength (nm)'); ylabel('Radiance (Watt/sr/nm/m^2)')
%}
%% Load spetral reflectance
wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
rRefl = refl(:, 1);
gRefl = refl(:, 2);
wRefl = refl(:, 3);
%{
ieNewGraphWin;
hold all
plot(wave, rRefl, 'r');
plot(wave, gRefl, 'g');
plot(wave, wRefl, 'k');
box on; grid on;
axis square;
xlabel('Wavelength (nm)'); ylabel('Reflectance');
set(gca, 'xlim', [400 700]); set(gca, 'ylim', [0 1]);
legend('Red wall', 'Green wall', 'White wall')
%}
%% Load spectral reflectance
piMaterialList(thisR);
matList = {'ShieldMat', 'LeftWall', 'RightWall', 'BackWall', 'TopWall',...
    'BottomWall', 'CubeLarge', 'CubeSmall'};
if isequal(surfaceColor, 'redgreen')
    reflList = [wRefl, rRefl gRefl wRefl wRefl wRefl wRefl wRefl];
elseif isequal(surfaceColor, 'white')
    reflList = [wRefl, wRefl wRefl wRefl wRefl wRefl wRefl wRefl];
end
for ii=1:numel(matList)
    thisR = cbAssignMaterial(thisR, matList{ii}, reflList(:, ii));
end
end