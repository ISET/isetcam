%% Running a ray trace calculation
%
% The ray-trace optics model is one of several types used in ISET
% (diffraction and shift-invariant are the others).
%
% The ray trace model includes field-height and wavelength dependent
% point spread functions. These can either be created synthetically,
% or they can be derived from optics software, such as Zemax.  We will
% start producing them with isetlens, as well.
%
% Copyright ImagEval Consultants, LLC, 2011.
%
% See also:  s_opticsRTGridLines, t_oiCompute

%%
ieInit

%% Make an example scene radiance of points

% You can adjust these parameters to speed up the calculation or
% explore the lens properties
scene = sceneCreate('point array', 512, 64); % Creates an array of points
scene = sceneSet(scene, 'fov', 20); % Make this smaller after MH agrees.

% To speed the computatons we use a small number of wavelength samples
scene = sceneInterpolateW(scene, (500:100:600));

% Add the scene to the ISET database and view it
ieAddObject(scene);
sceneWindow;
truesize

%% Create an optical image (oi) that uses the default ray trace model

% This model has a default lens we converted from Zemax to the array of
% point spread functions
oi = oiCreate('ray trace');

% If you would like to see the point spread functions, you can use this
% code.
%{
wave = 550; fhmm = 0.5;
rtPlot(oi,'psf',wave,fhmm);
%}

% Confirm that the optics model type is set to ray trace
% In general, optics parameters can be read out with this syntax using an
% oiGet() call.
fprintf('Optics model:       %s\n', oiGet(oi, 'optics model'))
fprintf('Ray trace lens:     %s\n', oiGet(oi, 'optics rt name')) % Name of the lens used by ray trace

%% The oiCompute will call opticsRayTrace to do the computation

oi = oiCompute(scene, oi);

% Make it easy to see the points
sceneWindow; truesize

% Here is the blurred result
ieAddObject(oi);
oiWindow;
truesize

%%
