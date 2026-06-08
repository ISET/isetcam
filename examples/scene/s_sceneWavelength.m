%% Adjust the scene wavelength representation
%
% Wavelengths are adjusted by linear interpolation of the
% spectral radiance data.
%
% (c) Imageval Consulting, LCC 2012

%%
ieInit

%%
scene = sceneCreate;
sceneGet(scene,'wave')
ieAddObject(scene); sceneWindow;
fprintf('Note the wavelength representation in the window\n');

%% Adjust the wavelength to 5 nm spacing
scene = sceneSet(scene,'wave',400:5:700);
scene = sceneSet(scene,'name','5 nm spacing');
ieAddObject(scene); sceneWindow;
fprintf('Note the wavelength representation in the window\n');

%%  Now get a narrow band representation
scene = sceneSet(scene,'wave',500:2:600);
scene = sceneSet(scene,'name','2 nm narrow band spacing');
ieAddObject(scene); sceneWindow;
fprintf('Note the wavelength representation in the window\n');

%%