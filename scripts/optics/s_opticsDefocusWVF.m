%% Calculating a diffraction limited, but defocused, image 
%
% s_opticsDefocusWVF
%
% In this case, we use wavefront methods to introduce defocus.
% Specifically, 
%
%  * We create a shift-invariant optics with wavefront parameters that
%  specify the pupil diameter and the focal length
%  * We then adjust the defocus term with a wvfSet and recompute the oi.
%
% This technique is simple to run.  Understanding it requires knowing a
% little bit about Zernike polynomials.  Tutorials emphasizing the
% wavefront methods are described in
% *t_wvf<TAB>* tutorials.
%
% See also:  sceneCreate, s_opticsDefocus, opticsDefocusCore,
%            humanWaveDefocus, t_opticsWVF, t_opticsWVFZernike
%

%%
ieInit

%% Test scene
scene = sceneCreate('freqorient',[512 512]);
ieAddObject(scene);

%% Wavefront method

wvf0 = wvfCreate;

% This is how to set the focal length and pupil diameter
wvf0 = wvfSet(wvf0,'focal length',8e-3);    % Meters
wvf0 = wvfSet(wvf0,'pupil diameter',3);     % Millimeters

% We then need to calculate the pointspread explicitly
wvf0 = wvfComputePSF(wvf0);

% Finally, we convert the wavefront representation to a shift-invariant
% optical image.
oi0 = wvf2oi(wvf0);
oiPlot(oi0,'psf 550');

% Here is the summary
fprintf('f# %0.2f and defocus %0.2f\n',oiGet(oi0,'fnumber'),oiGet(oi0,'wvf zcoeffs','defocus'));

%% Now we compute with the oi as usual

oi0 = oiCompute(oi0,scene);
oi0 = oiSet(oi0,'name','Diffraction limited');

oiWindow(oi0);

%% Here is the point spread.  Diffraction-limited in this case.

% Notice the Airy disk
oiPlot(oi0,'psf 550');

%% Adjust the defocus to 1 diopter
wvf1 = wvfCreate;

% Make a new one with some defocus
wvf1 = wvfSet(wvf1,'zcoeffs',1.5,'defocus');
wvf1 = wvfComputePSF(wvf1);
oi1 = wvf2oi(wvf1);
oiPlot(oi1,'psf 550');

fprintf('f# %0.2f and defocus %0.2f\n',oiGet(oi1,'fnumber'),oiGet(oi1,'wvf zcoeffs','defocus'));

%% Compute
oi1 = oiCompute(oi1,scene);
oiWindow(oi1);

%% The new pointspread

oiPlot(oi1,'psf 550');

%% END