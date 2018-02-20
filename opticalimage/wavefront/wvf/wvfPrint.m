function wvf = wvfPrint(wvf,varargin)
% wvf = wwvfPrint(wvf,varargin)
%
% Print out what's in the wavefront structure.
%
% varargin:  Structured as param, val pairs.
%   
% See also: wvfSet, wvfGet, sceCreate, sceGet
%
% (c) Wavefront Toolbox Team 2011, 2012

%% Book-keeping
fprintf('\nWavefront structure name is %s\n',wvfGet(wvf,'name'));
fprintf('\n');

%% Zernike coefficients and related
fprintf('Zernike coefficients\n');
fprintf('\t Coeffs %.3f\n',wvfGet(wvf,'zcoef'));


%% Spatial sampling parameters
fprintf('Spatial sampling conditions\n');
fprintf('\tSampling constant across wavelength in "%s" domain\n',wvfGet(wvf,'sample interval domain'));
fprintf('\tNumber of spatial samples (pixels) for pupil function/psf: %d\n',wvfGet(wvf,'spatial samples'));
fprintf('\tSize of sampled pupil plane (mm) at measurement wavelength: %g\n',wvfGet(wvf,'ref pupil plane size'));
fprintf('\tPupil plane sampling interval (mm/pixel) at measurement wavelength: %g\n',wvfGet(wvf,'ref pupil plane sample interval'));


%% Calculation parameters
fprintf('Calculation parameters\n');
fprintf('\tPupil size (mm): %g\n',wvfGet(wvf,'pupil size'));
fprintf('\tWavelengths: ')
val = wvfGet(wvf,'wavelengths');
for i = 1:length(val)
    fprintf(' %g',val(i));
end
fprintf('\n');


end
