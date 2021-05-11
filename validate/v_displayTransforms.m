%% v_displayTransforms
%
% Test display transforms between spaces
%
% Check RGB2XYZ and XYZ2LMS and RGB2LMS relationships

%%
ieInit

%% Test display transforms between spaces

% This Apple display has a peak luminance of about 120 cd/m2
d = displayCreate('LCD-Apple');

% Here is the transform
rgb2xyz = displayGet(d, 'rgb2xyz');
% [1 0 0]* rgb2xyz;
whiteXYZ = [1, 1, 1] * rgb2xyz;
fprintf('Calculated whiteXYZ \n');
disp(whiteXYZ);

% This is the same calculation just showing the white point
disp('From displayGet\n');
displayGet(d, 'white point')

%% Now let's check out the rgb2lms calculation

% The lms in this case is the Stockman
rgb2lms = displayGet(d, 'rgb2lms');
LMS = [1, 1, 1] * rgb2lms;
fprintf('LMS 0.5*L+M: %.2f and XYZ white %.2f\n', (LMS(1) + LMS(2))/2, whiteXYZ(2));

%% Compare the colorTransformMatrix with the calculated Stockman

% Master calculation - not wavelength sampling depend, so only approximate
xyz2lms = colorTransformMatrix('xyz2lms');
lms2xyz = colorTransformMatrix('lms2xyz');
xyz2lms * lms2xyz

% Compare rgb2lms with rgb2xyz * xyz2lms
fprintf('Near one\n');
rgb2lms ./ (rgb2xyz * xyz2lms)

% Calculate it
w = 400:10:700;
xyz = ieReadSpectra('XYZ.mat', w);
% plot(w,xyz)
stockman = ieReadSpectra('stockman', w);
% plot(w,stockman)

% XYZ = Stockman * sto2xyz
sto2xyz = stockman \ xyz;

% stockman = XYZ*xyz2sto
xyz2sto = xyz \ stockman;
% est = stockman*sto2xyz;
%
% vcNewGraphWin;
% plot(est(:),xyz(:),'o')

% This should be close to 1 everywhere
fprintf('Near one, mostly'); % Except for the S and Z terms
xyz2lms ./ xyz2sto
lms2xyz ./ sto2xyz

%% END
