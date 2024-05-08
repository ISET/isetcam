%% Calculating defocused, images
%
% s_opticsDefocusWVF
%
% We use wavefront methods to introduce defocus a diffraction limited lens.
%
%  * The code at the top of this script shows the steps explicitly.
%  * The code at the end shows a simpler way to set the defocus, but
%    it hides the computations.
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
%            humanWaveDefocus, 
%

%%
ieInit

%% Test scene

scene = sceneCreate('freqorient',[512 512]);
scene = sceneSet(scene,'fov',2);
ieAddObject(scene);

%% Wavefront method

% This the explicit method for creating the wavefront and building the
% oi
wvf0 = wvfCreate('wave',sceneGet(scene,'wave'));

% This is how to set the focal length and pupil diameter explicitly.
% A lot of optics is in millimeters.  Not a great thing.
wvf0 = wvfSet(wvf0,'focal length',8);    % Millimeters
wvfGet(wvf0,'focal length','mm')
wvf0 = wvfSet(wvf0,'pupil diameter',3);  % Millimeters
wvfGet(wvf0,'pupil diameter','mm')

% We calculate the pointspread explicitly
wvf0 = wvfCompute(wvf0);

% Finally, we convert the wavefront representation to a shift-invariant
% optical image with this routine.
oi0 = wvf2oi(wvf0);

oiPlot(oi0,'psf 550');

% Here is the summary
fprintf('f# %0.2f and defocus %0.2f\n',oiGet(oi0,'fnumber'),oiGet(oi0,'wvf zcoeffs','defocus'));

%% Now we compute with the oi as usual

oi0 = oiCompute(oi0,scene);
oi0 = oiSet(oi0,'name','Diffraction limited');
oiWindow(oi0);

%% Here is the point spread.  Diffraction-limited in this case.

% Notice the Airy disk units are not right in this plot.  Help!
oiPlot(oi0,'psf 550');

%% Adjust the defocus (in diopters)
wvf1 = wvfCreate('wave',sceneGet(scene,'wave'));

% Make a new one with some defocus
wvf1 = wvfSet(wvf1,'zcoeffs',1.5,'defocus');
wvf1 = wvfCompute(wvf1);
oi1 = wvf2oi(wvf1);
oiPlot(oi1,'psf 550');

fprintf('f# %0.2f and defocus %0.2f\n',oiGet(oi1,'fnumber'),oiGet(oi1,'wvf zcoeffs','defocus'));

%% Compute
oi1 = oiCompute(oi1,scene);
oi1 = oiSet(oi1,'name','Defocused');
oiWindow(oi1);

%% The new pointspread
oiPlot(oi1,'psf 550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%% An alternative approach using only the oi<> methods
wvf = wvfCreate('wave',sceneGet(scene,'wave'));

oi = oiCreate('wvf',wvf);   % Diffraction limited
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','DL');
oiWindow(oi);

oiPlot(oi,'psf 550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%% This should be the equivalent code

oi = oiSet(oi,'wvf zcoeffs',1,'defocus');  % Defocus
oiPlot(oi,'psf 550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%%
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','defocused');
oiWindow(oi);

%{
  % This is what happens in the oiSet() above
  wvf1 = oiGet(oi,'wvf');
  wvf1 = wvfSet(wvf1,'zcoeffs',1.5,'defocus');
  wvf1 = wvfCompute(wvf1);
  oi1  = wvf2oi(wvf1);
%}
%% END