%% Explain the oiCompute function (diffraction limited)
%
% We explain the inner workings of the *oiCompute* function for
% the diffraction limited case. This is the key function that
% converts the scene spectral radiance to the sensor irradiance.
%
% oiCompute is simplest in the diffraction-limited case, but the
% same general approach is used for shift-invariant and ray-trace
% models.
%
% We use the term optical image (oi) to refer to the object that
% describes the basic properties of the spectral irradiance at
% the sensor.  The conversion of the scene radiance to spectral
% radiance is largely determined by the parameters of the
% *optics*.  The optics object is attached to the oi object.
%
% See also:  t_oiCompute, oiCompute, t_oiIntroduction,
% t_sceneIntroduction, t_optics<TAB>
%
% Copyright ImagEval Consultants, LLC, 2016

%%
ieInit;

%% Create a scene and oi (irradiance) image from an array of points

% For a basic scene, we normally only see this
scene = sceneCreate('point array');
scene = sceneSet(scene,'hfov',1);
ieAddObject(scene); sceneWindow;

% Diffraction limited optics
oi = oiCreate;

% Compute optical image and show it
oi = oiCompute(oi,scene);
ieAddObject(oi); oiWindow;

%% The inner workings exposed
%
% The main call in oiCompute when the model is diffraction
% limited is to this function
%
%    opticsDLCompute(scene,oi);
%
% Here is what happens inside there

% Compute the basic parameters of the oi from the scene parameters.
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));

% The wavelength sampling of the oi is set to match that of the
% scene
oi = oiSet(oi,'optics wave',sceneGet(scene,'wave'));

% Compute and set the irradiance
optics = oiGet(oi,'optics');
oi = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi));

% Compute the illumination fall of
oi = opticsCos4th(oi);

% Blur based on the OTF
oi = opticsOTF(oi,scene);

% Then we check if there is an IR/diffuser filter and apply it
% (not shown here)

%% At this point, we are mostly done with calculation

oi = oiSet(oi,'name','Almost final');
ieAddObject(oi); oiWindow;

%% The final steps involve naming and dealing with the depth map
%
% We usually attach the luminance image
%
oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));
%
% Indicate scene it is derived from
oi = oiSet(oi,'name',sceneGet(scene,'name'));
%
% Pad the scene dpeth map and attach it to the oi.   The padded values are
% set to 0, though perhaps we should pad them with the mean distance.
% CHANGED BUT NOT TESTED YET!
oi = oiSet(oi,'depth map',oiPadDepthMap(scene,[],'pad','zero'));

oi = oiSet(oi,'name','Final');
ieAddObject(oi); oiWindow;

%%
