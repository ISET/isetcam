function [otf,fSupport] = oiCalculateOTF(oi,wave,unit)
%Calculate the optical transfer function for the optical image
%
% Synopsis
%   [otf,fSupport] = oiCalculateOTF(oi,[wave],[unit = 'cyclesPerDegree'])
%
% The optical transfer function (OTF) is derived from the optics
% parameters of an optical image (OI).  The frequency units are cycles
% per degree by default.  However, by setting the variable
% unit='millimeter' or 'micron' the frequency units can be changed to
% cycles/{millimeter,micron}.
%
% This routine is used for diffraction limited, shift-invariant, and
% the human otf. Calculations for ray trace dat are handled in the ray
% trace routines, rtPlot or rtOTF, and they don't use this routine.
%
% See also
%  applyOTF, oiCalculateOTF, oiCompute, dlMTF, dlCore
%
% Copyright ImagEval Consultants, LLC, 2005.

% Examples:
%{
  scene = sceneCreate; scene = sceneSet(scene,'fov',1);
  oi = oiCreate('diffraction limited');
  oi = oiCompute(oi,scene);
  [otf,fSupport] = oiCalculateOTF(oi);
  ieNewGraphWin; mesh(fSupport(:,:,1),fSupport(:,:,2),abs(otf(:,:,1)));
  xlabel('Cycles/deg');
  [otf,fsmm] = oiCalculateOTF(oi,'wave','mm');
  ieNewGraphWin; mesh(fsmm(:,:,1),fsmm(:,:,2),abs(otf(:,:,1)));
  xlabel('Cycles/mm');
%}

if ieNotDefined('wave'), wave = sceneGet(oi,'wave'); end
if ieNotDefined('unit'), unit = 'cyclesPerDegree'; end

optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');

% Retrieve the frequency support in the proper units.
fSupport = oiGet(oi,'frequencysupport',unit);

switch lower(opticsModel)
    case {'dlmtf','diffractionlimited'}
        
        % We want to permit a defocused MTF here.  If the optics structure
        % has a defocus slot (in diopters), then we should retrieve it and
        % use it.
        %
        % The key routine is: otf = opticsDefocusCore(optics,sampleSF,D);
        % That has to be slotted in here.
        otf = dlMTF(oi,fSupport,wave,unit);
        
    case {'custom','shiftinvariant'}
        % Calculate the OTF at each wavelength from the custom data.
        % The OTFs are returned at the frequency determined by the
        % sample spacing in the optical image (see above).
        %
        % It is important that the units specified for this
        % calculation and the units specified for the custom OTF be
        % the same.  Can we check?
        otf = customOTF(oi,fSupport,wave,unit);
        
    case {'skip','skipotf'}
        % Doesn't really happen.
        warndlg('No OTF method selected.');
        
    otherwise
        error('Unknown optics model: %s',opticsModel);
end

end
