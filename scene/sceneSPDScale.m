function [scene, fullName] = sceneSPDScale(scene, fullName, op, skipIlluminant)
% Multiply, Divide, Add or Subtract the scene radiance data
%
%    scene = sceneSPDScale(scene,fullName,op,skipIlluminant);
%
%  The scene data are divided, multiplied, etc. using the spectral
%  information in fullName.  The calculation is applied to each pixel in
%  the scene. The data in the file fullName are assumed to represent a
%  spectral distribution in energy units. Hence, if you send in data with
%  all 1's in the energy term, the returned values will be  unchanged.
%
%  The fullName parameter:
%
%  Ordinarily, the term for multiplying is contained in a file, fullName.
%  This file has data in units of energy.  The data are interpolated
%  according to the information in scene.
%
%  If fullname is not passed in , the user is asked to select the file.
%  The parameter op is set to '/', '*','+', or '-' to specify the
%  operation.  The routine name should be changed to sceneSPDOp or
%  something.
%
%  It is also possible to send in a data vector for fullName.  In this
%  case, YOU must make sure that the vector is the same dimensionality as
%  the number of wavelength samples in the scene.  The data must be in
%  units of ENERGY.
%
%  When using multiply and divide, the spd values in the file are just
%  scale factors without real units.
%
%  When using add and subtract, however, the spd values in the file must
%  be in units of energy.  We convert them to photons here and combine them
%  with the photon data in scene.  The values are in energy units because
%  that is the way most of the official formulae and data are provided by
%  standards organizations.
%
% N.B. Please note this feature of photon/energy units.  If you wish to use
% a divisor that is all 1's photon units, the data will be changed. The 1's
% in photons are not 1's in energy.
%
% Example
%   [scene,fullName] = sceneSPDScale(scene,'D65','*');
%
% If you have a scene with D65 illuminant and you want to create a scene
% with a particular surface reflectance, use this type of code:
%
%   ref = [1:31]/31;
%   scene = sceneCreate('uniformD65',128);
%   skipIlluminant = 1;
%   scene = sceneSPDScale(scene,ref,'*',skipIlluminant);
%   vcReplaceAndSelectObject(scene); sceneWindow;
%
% The resulting scene will still have a D65 illuminant and the energy will
% be that illuminant times the ref function.
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO - validate input data

if ieNotDefined('scene'), [~, scene] = vcGetSelectedObject('SCENE'); end
if ieNotDefined('fullName'), fullName = vcSelectDataFile('lights'); end
if ieNotDefined('skipIlluminant'), skipIlluminant = 0; end
if isempty(fullName), return; end

% NOTE:  Check that the wavelength representations of the different objects
% agree

energy = double(sceneGet(scene, 'energy'));
wave = sceneGet(scene, 'wave');
nWave = sceneGet(scene, 'nwave');

% If the spd is sent in, it must be in energy units
if ischar(fullName), spd = ieReadSpectra(fullName, wave);
else spd = fullName;
end

% OK, this is awkward.  Almost all of the data we have stored on disk are
% in energy format.  Almost all of the calculations we perform are on
% photons.  So, I normally do this conversion.  If I were a better person,
% each of the data files would have a units field (e.g., quanta/sr/s/m2 and
% so forth) and I wouldn't have to guess.  This will come in the next
% release.

% If the scene has a current illuminant, say it is a multispectral scene,
% then we change the illuminant information also for multiply and divide.
switch op
        % I think these operations might be handled using RGB2XWFormat more
        % efficiently.
    case {'/', 'divide'}
        % for ii=1:nWave
        %    energy(:,:,ii) = energy(:,:,ii)/spd(ii);
        % end
        energy = bsxfun(@rdivide, energy, reshape(spd, [1, 1, nWave]));
        if ~skipIlluminant
            illE = sceneGet(scene, 'illuminant energy');
            illE = illE(:) ./ spd(:);
        end

    case {'multiply', '*'}
        % for ii=1:nWave
        %     energy(:,:,ii) = energy(:,:,ii)*spd(ii);
        % end
        energy = bsxfun(@times, energy, reshape(spd, [1, 1, nWave]));
        if ~skipIlluminant
            illE = sceneGet(scene, 'illuminant energy');
            if isempty(illE)
                error('No illuminant data');
            end
            illE = illE(:) .* spd(:);
        end

    case {'add', '+', 'sum', 'plus'}
        energy = bsxfun(@plus, energy, reshape(spd, [1, 1, nWave]));
    case {'subtract', '-', 'minus'}
        energy = bsxfun(@minus, energy, reshape(spd, [1, 1, nWave]));
    otherwise
        error('Unknown operation.')
end

% Place the adjusted data in the scene structure
[XW, r, c, ~] = RGB2XWFormat(energy);
photons = XW2RGBFormat(Energy2Quanta(wave, XW')', r, c);
scene   = sceneSet(scene,'photons',photons);
if ~skipIlluminant
    scene = sceneSet(scene, 'illuminant energy', illE);
end

% Update the scene luminance information
[lum, meanL] = sceneCalculateLuminance(scene);
scene = sceneSet(scene, 'luminance', lum);
scene = sceneSet(scene, 'meanl', meanL);

end