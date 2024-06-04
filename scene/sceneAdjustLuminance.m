function scene = sceneAdjustLuminance(scene, method, targetL, varargin)
% Scale scene luminance
%
% Synopsis:
%   scene = sceneAdjustLuminance(scene, method, targetL,[locs or rect])
%
% Brief:
%   The photon level in the scene structure is scaled so that one of
%   the luminance distribution parameters ('mean', 'max', 'median',
%   or 'roi') is set to val.
%   
%   The illuminant is also scaled to preserve the reflectance.
%
% Inputs
%   scene:  Scene object
%   param:  Options: 'mean', 'peak', or 'roi' (formerly 'crop')
%   val:    Luminance value on return
%
% Output
%   scene:  Adjusted scene
%
% Description
%    We scale the photons in the scene to set a particular parameter
%    (mean, peak, median, or ROI) to a specified luminance level.
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
  sceneGet(scene,'max luminance')
%}
%{
  scene = sceneCreate;
  rect = [0 0 100 100];
  scene = sceneAdjustLuminance(scene,'roi',200,rect);
  sceneGet(scene,'roi mean luminance',rect)
%}
%{
  % For backwards compatibility, we still allow setting the mean level as
  % follows, but not preferred usage.
  scene = sceneCreate;
  scene = sceneAdjustLuminance(scene,100);
  sceneGet(scene,'mean luminance')
%}

%% For backwards compatibility 

if isnumeric(method)
    targetL = method; 
    method = 'mean'; 
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
            % one waveband at a time.  I don't think this happens, so
            % I want a warning when it does.
            warning('Data too big for memory.  One wave at a time.')
            nWave = sceneGet(scene,'wave');
            for ii=1:nWave
                photons(:,:,ii) = photons(:,:,ii)*(targetL/currentL);
            end
        end
    case {'max','peak'}
        % Let's hope we are past the age of running out of memory
        currentL = sceneGet(scene,'max luminance');
        photons = photons*(targetL/currentL);
    case 'median'
        % The median is the 50th percentile
        luminance = sceneGet(scene,'luminance');
        currentL = median(luminance(:));
        photons = photons*(targetL/currentL);
    case {'roi','crop'}
        % If roi, then the user had to send in locs or rect
        roi = varargin{1};
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
