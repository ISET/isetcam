function oi = wvfApply(scene, wvf, varargin)
% Deprecated:  Calculate an OI using a wavefront specification 
%
%  NO LONGER NEEDED
%
% Synopsis:
%   oi = wvfApply(scene, wvf, varargin)
%
% Brief description:
%   First used to apply a 'scattering flare' PSF to a scene and generate an
%   optical image. 
%
%   The scattering flare is implemented based on the paper "How to
%   Train Neural Networks for Flare Removal" by Wu et al.
%
%   It can be used for any wavefront calculation, however.
%
% Inputs:
%   scene: An ISET scene structure.
%
% Optional key/val pairs
%   lca -  Use human longitudinal chromatic aberration in wvfComputePSF
%           (default false)
%   force - Require wvfComputePSF to run (default true)
%
% Output:
%   opticalImage: An ISET optical image structure.
%
% Description
%   The scattering flare is implemented as perturbations on the pupil
%   function (wavefront).  We have several ideas to implement to
%   extend the flare modeling
%
%      * Can we take in an OI and apply the flare to that?  How would
%      that work? Maybe we should compute the Pupil function from any
%      OI by estimating the point spread function and then deriving
%      the Pupil function (psf = abs(fft(pupil)).  We can't really
%      invert because of the abs, but maybe approximate?
%      * We should implement additional regular wavefront aberration
%      patterns, not just random scratches
%      * We should implement wavelength-dependent scratches. Now
%      the impact of the scratches is the same at all wavelengths
%      * Accept a geometric transform and apply that to if we start
%      with a scene.
%      
% See also
%   oiCompute, wvfPupilFunction, wvfPupilAmplitude

% Examples:
%{
scene = sceneCreate('point array',512,128);
scene = sceneSet(scene,'fov',0.5);
mn = sceneGet(scene,'mean luminance');
scene = sceneSet(scene,'mean luminance',mn*1e5);

wvf = wvfCreate;    
wvf = wvfSet(wvf,'calc pupil diameter',3);
[apertureFunction, params] = wvfAperture(wvf,'nsides',3);
wvf = wvfPupilFunction(wvf,'amplitude',apertureFunction);
wvf = wvfComputePSF(wvf);
oi = oiCompute(wvf,scene);
oiShowImage(oi);
%}

%% Parse input
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('scene', @isstruct);
p.addRequired('wvf',@isstruct)
p.addParameter('lca',false,@islogical);
p.addParameter('computepupilfunc',true,@islogical);

p.parse(scene,wvf,varargin{:});

%%
wvf = wvfComputePSF(wvf,'lca',p.Results.lca,'computepupilfunc',p.Results.computepupilfunc);

oi = wvf2oi(wvf);

oi = oiCompute(oi,scene);

end
