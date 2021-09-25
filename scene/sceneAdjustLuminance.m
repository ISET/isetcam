function scene = sceneAdjustLuminance(scene,meanL,varargin)
% Scale scene luminance
%
% Synopsis:
%   scene = sceneAdjustLuminance(scene,param,val,[roi rect])
%
% Brief description:
%   The photon level in the scene structure is multiplied so that the
%   luminance parameter ('mean', 'peak' or 'roi') is set to val. The
%   illuminant is also scaled to preserve the reflectance.
%
% Inputs
%   scene:  Scene object
%   param:  Options: 'mean', 'peak', or 'roi' (formerly 'crop')
%   val:    Luminance value on return
%
% Output
%   scene
%
% ieExamplesPrint('sceneAdjustLuminance');
%
% See also
%    sceneAdjustIlluminant

% Examples:
%{
  scene = sceneCreate;
  scene = sceneAdjustLuminance(scene,'mean',10);  % Set to 10 cd/m2.
  sceneGet(scene,'mean luminance')
%}
%{
  scene = sceneCreate;
  scene = sceneAdjustLuminance(scene,'peak',200);
  sceneGet(scene,'mean luminance')
%}
%{
  scene = sceneCreate;
  scene = sceneAdjustLuminance(scene,'roi',200,rect);
%}
%{
% For backwards compatibility, we still allow setting the mean level as
% But not preferred
 scene = sceneAdjustLuminance(scene,100);
 sceneGet(scene,'mean luminance')
%}

%% Verify that current luminance exists, or calculate it
if isnumeric(meanL), method = 'mean'; targetL = meanL;
else,                method = meanL; targetL = varargin{1};
end

%% Saves a lot of time.  This makes the calculation single precision.
photons = scene.data.photons;

switch method
    case 'mean'
        currentL  = sceneGet(scene,'mean luminance');
        try
            photons   = photons*(targetL/currentL);
        catch ME
            % Probably the data are too big for memory.  So scale the photons
            % one waveband at a time.
            nWave = sceneGet(scene,'wave');
            for ii=1:nWave
                photons(:,:,ii) = photons(:,:,ii)*(targetL/currentL);
            end
        end
    case 'peak'
        % Let's hope we are past the age of running out of memory
        luminance = sceneGet(scene,'luminance');
        currentL = max(luminance(:));
        clear luminance;
        photons = photons*(targetL/currentL);
    case {'roi','crop'}
        % The roi can be a locs or rect
        roi = varargin{2};
        currentL = sceneGet(scene, 'roi mean luminance', roi);
        try
            photons = photons*(targetL/currentL);
        catch ME
            % Probably the data are too big for memory.  So scale the photons
            % one waveband at a time.
            nWave = sceneGet(scene,'wave');
            for ii=1:nWave
                photons(:,:,ii) = photons(:,:,ii)*(targetL/currentL);
            end
        end
    otherwise
        error('Unknown method %s\n',method);
end

% We scale the photons and the illuminant data by the same amount to keep
% the reflectances in 0,1 range.
scene      = sceneSet(scene,'photons',photons);   % Takes time
illuminant = sceneGet(scene,'illuminant photons');
illuminant = illuminant*(targetL/currentL);
scene      = sceneSet(scene,'illuminant photons',illuminant);

end
