function wvf = wvfPrint(wvf, varargin)
% Print wavefront structure
%
% Syntax:
%   wvf = wwvfPrint(wvf, [varargin])
%
% Description:
%    Print what's in the wavefront structure. This will contain measurement
%    conditions, spatial sampling conditions, and calculation parameters. 
%
% Inputs:
%    wvf      - wavefront structure
%    varargin - Structured as param, val pairs.
%
% Outputs:
%    wvf      - wavefront structure
%
% Optional key/value pairs:
%    *Needs attention*
%
% Notes:
%    * TODO: Fill out optional key/value pairs section
%
% See Also:
%    wvfSet, wvfGet, sceCreate, sceGet
%

% History:
%    xx/xx/11       (c) Wavefront Toolbox Team 2011, 2012

% Examples:
%{
    wvf0 = wvfCreate;
    wvfPrint(wvf0);
%}

%% Book-keeping
fprintf('\nWavefront structure name is %s\n', wvfGet(wvf, 'name'));
fprintf('\n');

%% Zernike coefficients and related
fprintf('Measurement conditions\n');
fprintf('\tPupil size (mm): %g\n', wvfGet(wvf, 'measured pupil'));
fprintf('\tWavelenth (nm): %g\n', wvfGet(wvf, 'measured wl'));
fprintf('\tOptical axis (deg): %g\n', ...
    wvfGet(wvf, 'measured optical axis'));
fprintf('\tObserver accommodation (diopters): %g\n', ...
    wvfGet(wvf, 'measured observer accommodation'));
fprintf('\tObserver focus correction (diopters): %g\n', ...
    wvfGet(wvf, 'measured observer focus correction'));


%% Spatial sampling parameters
fprintf('Spatial sampling conditions\n');
fprintf('\tSampling constant across wavelength in %s domain\n', ...
    wvfGet(wvf, 'sample interval domain'));
fprintf(['\tNumber of spatial samples (pixels) for pupil '...
    'function/psf: %d\n'], wvfGet(wvf, 'spatial samples'));
fprintf(['\tSize of sampled pupil plane (mm) at measurement '...
    'wavelength: %g\n'], wvfGet(wvf, 'ref pupil plane size'));
fprintf(['\tPupil plane sampling interval (mm/pixel) at measurement '...
    'wavelength: %g\n'], wvfGet(wvf, 'ref pupil plane sample interval'));
fprintf(['\tPSF sampling interval (arcmin/pixel) at measurement '...
    'wavelength: %g\n'], wvfGet(wvf, 'ref psf sample interval'));


%% Calculation parameters
fprintf('Calculation parameters\n');
fprintf('\tPupil size (mm): %g\n', wvfGet(wvf, 'calc pupil size'));
fprintf('\tOptical axis (deg): %g\n', wvfGet(wvf, 'calc optical axis'));
fprintf('\tObserver accommodation (diopters): %g\n', ...
    wvfGet(wvf, 'calc observer accommodation'));
fprintf('\tObserver focus correction (diopters): %g\n', ...
    wvfGet(wvf, 'calc observer focus correction'));
fprintf('\tWavelengths: ')
val = wvfGet(wvf, 'calc wavelengths');
for i = 1:length(val)
    fprintf(' %g', val(i));
end
fprintf('\n');


% %% What to calculate for
% 
% % We can calculate the pupil function for any pupil diameter smaller
% % than the diameter over which the measurements extend. This defines
% % the size to be used for the calculations represented by the wvf
% % object.
% wvf.calcpupilMM = 3;               % Used for this calculation   
% 
% % Something about the cones. 
% % S is a length 3 vector of the format: [start spacing Nsamples]
% % ex: S = [400 50 5]; 5 wavelength samples 400, 450, 500, 550, 600
% S = [550 1 1]; 
% T = load('T_cones_ss2');   % Probably in the PTB
% T_cones = SplineCmf(T.S_cones_ss2, T.T_cones_ss2, S);
% % vcNewGraphWin; plot(wave, T_cones'); xlabel('Wavelength (nm)');
% 
% % Weighting spectrum, for combining the PSFs in an average 
% T = load('spd_D65');
% weightingSpectrum = SplineSpd(T.S_D65, T.spd_D65, S);
% 
% % Resampled cone spectral absorptions
% wvf.T_cones = T_cones;
% % Probably used for combined psf
% wvf.weightingSpectrum = weightingSpectrum;
% 
% % Sets up the Stiles Crawford Effect parameters. 
% wvf.sceParams = sceCreate([], 'none');
% 
% % Handle any additional arguments via wvfSet
% if ~isempty(varargin)
%     if isodd(length(varargin))
%         error('Arguments must be (pair, val) pairs');
%     end
%     for ii=1:2:(length(varargin)-1)
%         val = wvfGet(wvf, varargin{ii}, varargin{ii+1});
%     end
% end
% 
% return
