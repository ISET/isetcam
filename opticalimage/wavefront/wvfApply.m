function oi = wvfApply(scene, wvf, varargin)
% Calculate an OI using a wavefront specification 
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
%   nolca - No human longitudinal chromatic aberration in wvfComputePSF
%           (default true)
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
wvf = wvfSet(wvf,'calc pupil diameter',8);
[pupilAmp, params] = wvfPupilAmplitude(wvf,'nsides',3);
wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);
wvf = wvfComputePSF(wvf);
oi = piFlareApply2(scene,wvf);

%}

%% Parse input
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('scene', @isstruct);
p.addRequired('wvf',@isstruct)
p.addParameter('nolca',true,@islogical);
p.addParameter('force',true,@islogical);

p.parse(scene,wvf,varargin{:});

%%
wvf = wvfComputePSF(wvf,'nolca',p.Results.nolca,'force',p.Results.force);

oi = wvf2oi(wvf);

oi = oiCompute(oi,scene);

end
