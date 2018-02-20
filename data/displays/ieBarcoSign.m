%% Create the Barco LED Sign display model
%
% This sign model is used for assessing algorithms for autonomous vehicles.
% The data about this LED display is in the WLletterClass directory,
% provided by Gari Lerma
%
% Copyright Imageval Consulting, LLC, 2015

ieInit

%% Start with default display structure.

% We don't have the color properties yet, so we will use the OLED.
% Probably more saturated than the LED.  But that's how we are starting.
d = displayCreate('OLED-Sony');

%% Set some of the parameters

% Dots per inch
dpi = mperdot2dpi(0.0083);                % 8.3 mm per dot
d = displaySet(d,'dpi',dpi);

% Typical
d = displaySet(d,'viewing distance',50);  % Typical viewing distance is 50 meters away

% As per the spec
d = displaySet(d,'gamma','linear',2^16);  % Linear, 16 bit gamma

% As per the spec
% Set the peak brightness to 5000 cd/m2, as per the document (nits)
wXYZ = displayGet(d,'white xyz');
s = 5000/wXYZ(2);
spd = displayGet(d,'spd');
spd = spd*s;
d = displaySet(d,'spd',spd);
wXYZ = displayGet(d,'white xyz');
fprintf('Peak luminance %.1f\n',wXYZ(2));

% Out of curiosity
fprintf('Correlated color temperature %f\n',cct(displayGet(d,'white xy')'));

%% Save
d = displaySet(d,'name','Barco C8');
fname = fullfile(isetRootPath,'data','displays','LED-BarcoC8.mat');
save(fname,'d');

%%  Bring up a scene with this display

% Just to show the display structure works.  Notice the peak luminance is
% about 5000 cd/m2 and the sample spacing is 8.3 mm, as per the
% specification.  The viewing distance is 50 m, like for a car.
fname = fullfile(isetRootPath,'data','images','rgb','bears.png');
scene = sceneFromFile(fname,'rgb',[],'LED-BarcoC8.mat');
ieAddObject(scene); sceneWindow;


%%  Bring up the display itself

% When the focal length is very short, the pixels oi samples are finely
% spaced and within the blur circle of the diffraction limited optics.
ieAddObject(d);
displayWindow;
