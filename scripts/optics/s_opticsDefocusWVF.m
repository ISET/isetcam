%% Calculating a diffraction limited, but defocused, image
%
% s_opticsDefocusWVF
%
% We use wavefront methods to introduce defocus a diffraction limited lens.
%
%  * The code at the top of this script shows the steps explicitly.
%  * The code at the end shows a simpler way to set the defocus, but it hides
% the computations.
%
% The logic in both cases is this
%
%  * We create a shift-invariant optics with wavefront parameters
%  * We specify the pupil diameter and the focal length
%  * We then set the defocus and recompute the oi.
%
% Understanding the wavefront approach requires knowing a little bit about
% Zernike polynomials.  Tutorials emphasizing the wavefront methods are
% described in *t_wvf<TAB>* tutorials.
%
% See also:  sceneCreate, s_opticsDefocus, opticsDefocusCore,
%            humanWaveDefocus, t_opticsWVF, t_opticsWVFZernike
%

%%
ieInit

%% Test scene
scene = sceneCreate('freqorient', [512, 512]);
scene = sceneSet(scene, 'fov', 5);
ieAddObject(scene);

%% Wavefront method
wvf0 = wvfCreate;

% This is how to set the focal length and pupil diameter.  It is annoying
% that the diameter is millimeters.  I hope to change it to meters but that
% will involve dealing with many scripts.  And more patience than I have
% right now. (BW).
wvf0 = wvfSet(wvf0, 'focal length', 8e-3); % Meters
wvf0 = wvfSet(wvf0, 'pupil diameter', 3); % Millimeters

% We need to calculate the pointspread explicitly
wvf0 = wvfComputePSF(wvf0);

% Finally, we convert the wavefront representation to a shift-invariant
% optical image with this routine.
oi0 = wvf2oi(wvf0);
oiPlot(oi0, 'psf 550');

% Here is the summary
fprintf('f# %0.2f and defocus %0.2f\n', oiGet(oi0, 'fnumber'), oiGet(oi0, 'wvf zcoeffs', 'defocus'));

%% Now we compute with the oi as usual

oi0 = oiCompute(oi0, scene);
oi0 = oiSet(oi0, 'name', 'Diffraction limited');
oiWindow(oi0);

%% Here is the point spread.  Diffraction-limited in this case.

% Notice the Airy disk
oiPlot(oi0, 'psf 550');

%% Adjust the defocus (in diopters)
wvf1 = wvfCreate;

% Make a new one with some defocus
wvf1 = wvfSet(wvf1, 'zcoeffs', 1.5, 'defocus');
wvf1 = wvfComputePSF(wvf1);
oi1 = wvf2oi(wvf1);
oiPlot(oi1, 'psf 550');

fprintf('f# %0.2f and defocus %0.2f\n', oiGet(oi1, 'fnumber'), oiGet(oi1, 'wvf zcoeffs', 'defocus'));

%% Compute
oi1 = oiCompute(oi1, scene);
oi1 = oiSet(oi1, 'name', 'Defocused');
oiWindow(oi1);

%% The new pointspread
oiPlot(oi1, 'psf 550');

%% An alternative approach using only the oi<> methods

oi = oiCreate('wvf'); % Diffraction limited
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', 'DL');
oiWindow(oi);

oiPlot(oi, 'psf 550');

%% This should be the equivalent code

oi = oiSet(oi, 'wvf zcoeffs', 1.5, 'defocus'); % Defocus
oiPlot(oi, 'psf 550');
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', 'defocused');
oiWindow(oi);

%{
% This is what happens in the oiSet() above
wvf1 = oiGet(oi,'wvf');
wvf1 = wvfSet(wvf1,'zcoeffs',1.5,'defocus');
wvf1 = wvfComputePSF(wvf1);
oi1  = wvf2oi(wvf1);
%}

%% END