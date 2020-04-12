function scene = sceneAdjustLuminance(scene,meanL,varargin)
% Scale scene luminance
%
%   scene = sceneAdjustLuminance(scene,param,val)
%
% The photon level in the scene structure is multiplied so that the
% luminance parameter ('mean' or 'peak') is set to val. The illuminant is
% also scaled to preserve the reflectance.
%
% scene:  Scene object
% param:  Which param, choices are 'mean' or 'peak'
% val:    Luminance value at of the param on return
% 
%Example:
%   scene = sceneCreate; sceneGet(scene,'mean luminance')
%   scene = sceneAdjustLuminance(scene,'mean',10);  % Set to 10 cd/m2.
%   sceneGet(scene,'mean luminance')
%
%   scene = sceneAdjustLuminance(scene,'peak',200);
%   sceneGet(scene,'mean luminance')
%
% For backwards compatibility, we still allow setting the mean level as
%
%   scene = sceneAdjustLuminance(scene,100);
%   sceneGet(scene,'mean luminance')
%
% But this is not preferred.
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
%   Some scenes go to very long wavelengths.
%   That slows the calculation.  Never let the calculation go beyond 780nm.
%

% Verify that current luminance exists, or calculate it
if isnumeric(meanL), method = 'mean'; val = meanL;
else                 method = meanL; val = varargin{1};
end

% Saves a lot of time.  Calculation is single precision.
photons = scene.data.photons;

switch method
    case 'mean'
        currentVal  = sceneGet(scene,'mean luminance');
        try
            photons   = photons*(val/currentVal);
        catch ME
            % Probably the data are too big for memory.  So scale the photons
            % one waveband at a time.
            nWave = sceneGet(scene,'wave');
            for ii=1:nWave
                photons(:,:,ii) = photons(:,:,ii)*(val/currentVal);
            end
        end
    case 'peak'
        % Let's hope we are past the age of running out of memory
        luminance = sceneGet(scene,'luminance');
        currentVal = max(luminance(:));
        clear luminance;
        photons = photons*(val/currentVal);
    case 'crop'
        roi = varargin{2};
        currentVal = sceneGet(scene, 'roi mean photons', roi);
        try
            photons = photons*(val/currentVal);
        catch ME
            % Probably the data are too big for memory.  So scale the photons
            % one waveband at a time.
            nWave = sceneGet(scene,'wave');
            for ii=1:nWave
                photons(:,:,ii) = photons(:,:,ii)*(val/currentVal);
            end
        end
    otherwise
        error('Unknown method %s\n',method);
end

% We scale the photons and the illuminant data by the same amount to keep
% the reflectances in 0,1 range.
scene      = sceneSet(scene,'photons',photons);   % Takes time
illuminant = sceneGet(scene,'illuminant photons');
illuminant = illuminant*(val/currentVal);
scene      = sceneSet(scene,'illuminant photons',illuminant);

return
