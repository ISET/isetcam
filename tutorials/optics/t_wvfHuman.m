% Create human optics approximation and compare to Marimont & Wandell model
%
% Description:
%    Use the WVF methods to create an approximation to human optics in
%    isetbio, and compare to Marimont and Wandell model.
%
% Notes:
%    * [NOTE: DHB - The appearance of the two optical images is
%       surprisingly different. This should be expanded to compare the
%       PSFs, or something else, so that the tutorial makes clear why they
%       are so different.]
%

% History:
%    11/26/17  dhb  Simplify not to use wvfCreate (which didn't preserve
%                   lens density). Change name to t_ rather than s_.
%    09/27/18  jnm  Formatting

%% Initialize
ieInit;

%% Create  simple scene
scene = sceneCreate('gridlines');
scene = sceneSet(scene, 'fov', 1);

%% Create wavefront for human eyes
% Note that averaging the coefficients to get the sample mean is not
% the same as finding optics for a typical human observer. Averaging
% the coefficients does not yield a PSF whose phase structure is like
% that of any observer.  Nicolas Cottaris has analyzed this in some
% detail as part of the IBIOColorDetect project.
pupilMM = 4.5;
zCoefs = wvfLoadThibosVirtualEyes(pupilMM);
wave = (400:10:700)';

%% Create a default human oi structure with wavefront optics
oiW = oiCreate('wvf human', pupilMM, zCoefs, wave);

% Compute with wavefront version and display
oiW = oiCompute(oiW,scene);
oiW = oiSet(oiW, 'name', 'Wavefront');
oiWindow(oiW);

%% The standard default optics, Marimont and Wandell PSF.
oiM = oiCreate('human');

% Compute with M/W version and display
oiM = oiCompute(oiM,scene);
oiM = oiSet(oiM, 'name', 'Marimont');
oiWindow(oiM);

%% END
