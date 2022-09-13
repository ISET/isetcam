function scene = sceneAdjustIlluminant(scene,illEnergy,preserveMean)
%Adjust the current scene illuminant to the value in data
%
% Synopsis
%  scene = sceneAdjustIlluminant(scene,illEnergy,preserveMean)
%
% Brief Description
%  Change the scene illuminant.
%
% Inputs
%  scene:      A scene structure, or the current scene will be assumed
%  illEnergy:  Either a file name to spectral data, or 
%              an illuminant energy vector (same length as scene wave)
%              or an ISETCam illuminant struct.
%  preserveMean:  Scale result to preserve mean illuminant (default true)
%
%  Description
%    The calculation scales the scene radiance by dividing out the
%    current illuminant and then multiplying by the new illuminant.
%    This preserves the reflectance. By default, we also preserve the
%    scene mean luminance, which effectively scales the illuminant
%    level.
%
%    If you do not want the illuminant level to change, then set the
%    preserveMean flag to false. It is true by default.
%
%    If the current scene has no defined illuminant, we assume that
%    the scene illuminant is D65.
%
%    This appears to work if the scene is a spatial-spectral illuminant
%    too.
%
% ieExamplesPrint('sceneAdjustIlluminant');
%
% See also
%    sceneAdjustLuminance

% Examples:
%{
    scene = sceneCreate;   % Default is MCC under D65
    scene = sceneAdjustIlluminant(scene,'illHorizon-20180220.mat');
    vcReplaceAndSelectObject(scene); sceneWindow;
%}
%{
    bb = blackbody(sceneGet(scene,'wave'),3000);
    scene = sceneAdjustIlluminant(scene,bb);
    vcReplaceAndSelectObject(scene); sceneWindow;
%}
%{
    bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
    figure; plot(wave,bb)
    scene = sceneAdjustIlluminant(scene,bb);
    vcReplaceAndSelectObject(scene); sceneWindow;
%}

%%
if ieNotDefined('scene'),        scene = ieGetObject('scene'); end
if ieNotDefined('preserveMean'), preserveMean = true; end

% Make sure we have the illuminant data in the form of energy
wave = sceneGet(scene,'wave');
if ieNotDefined('illEnergy')
    % Read from a user-selected file
    fullName = vcSelectDataFile([]);
    illEnergy = ieReadSpectra(fullName,wave);
elseif ischar(illEnergy)
    % Read from the filename sent by the user
    fullName = illEnergy;
    if ~exist(fullName,'file'), error('No file %s\n',fullName);
    else, illEnergy = ieReadSpectra(fullName,wave);
    end
elseif isstruct(illEnergy) && isequal(illEnergy.type,'illuminant')
    fullName = illuminantGet(illEnergy,'name');
    illEnergy = illuminantGet(illEnergy,'energy');
else
    % User sent numbers.  We check for numerical validity next.
    fullName = '';
end

% A public service announcement.
if max(illEnergy > 10^14)
    warning('Illuminant appears to be in units of photons rather than energy.  Please check');
end

%% We check the illuminant energy values.
if max(illEnergy) > 10^5
    % Energy is not this big.
    warning('Illuminant energy values are high; may be photons, not energy.')
elseif isequal(min(illEnergy(:)),0)
    warning('Illuminant transformation cannot be inverted applied (zeroes).');
end

%% Start the conversion
curIll = sceneGet(scene,'illuminant photons');
if isempty(curIll)
    % We  treat this as an opportunity to create an illuminant, as in
    % sceneFromFile (or vcReadImage). Assume the illuminant is D65.  Lord
    % knows why.  Maybe we should do an illuminant estimation algorithm
    % here.
    disp('Old style scene.  Creating D65 illuminant')
    wave   = sceneGet(scene,'wave');
    curIll = ieReadSpectra('D65',wave);   % D65 in energy units
    scene  = sceneSet(scene,'illuminant energy',curIll);
    curIll = sceneGet(scene,'illuminant photons');
end

% Current mean luminance may be preserved
mLum     = sceneGet(scene,'mean luminance');
if isnan(mLum)
    [lum, mLum] = sceneCalculateLuminance(scene);
    scene = sceneSet(scene,'luminance',lum);
end

% Converts illEnergy to illPhotons.  Deals with different illuminant
% formats.  If preserve reflectance or not, do slightly different things.
curIll = double(curIll);
switch sceneGet(scene,'illuminant format')
    case 'spectral'
        % In this case the illuminant is a vector.  We convert to photons
        illPhotons = Energy2Quanta(illEnergy,wave);
        
        % Find the multiplier ratio
        illFactor  = illPhotons ./ curIll;
        
        % Adjust the radiance data and the illuminant by the illFactor
        % This preserves the reflectance.
        skipIlluminant = 0;  % Don't skip changing the illuminant (do change it!)
        scene = sceneSPDScale(scene,illFactor,'*',skipIlluminant);
        
    case 'spatial spectral'
        
        if isequal(size(curIll),size(illEnergy))
            [newIll,r,c] = RGB2XWFormat(illEnergy);
            newIll = Energy2Quanta(wave,newIll');
            newIll = XW2RGBFormat(newIll',r,c);
            
            % Get the scene radiance
            photons = sceneGet(scene,'photons');
            % Divide the radiance photons by the current illuminant and then
            % multiply by the new illuminant.  These are the radiance photons
            % under the new illuminant.  This preserves the reflectance.
            photons = (photons ./ curIll) .* newIll;
            
            % Set the new radiance back into the scene
            scene = sceneSet(scene,'photons',photons);
            
            % Set the new illuminant back into the scene
            scene = sceneSet(scene,'illuminant photons',newIll);
        else
            % This could be an loop across wavelength using interp2()
            error('No adjust illuminant method yet for spatial spectral illuminants');
        end
        
end

% Make sure the mean luminance is unchanged.
if preserveMean  % Default is true
    scene = sceneAdjustLuminance(scene,mLum);
end

scene = sceneSet(scene,'illuminant comment',fullName);

end

