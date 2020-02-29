%% Macbeth Gretag Color Data
%
% These are the MCC names and LAB data tabulated by Danny Pascale in
%   RGB coordinates of the Macbeth ColorChecker
%   The BabelColor Company
%   www.BabelColor.com
%
% We confirm that the reflectances we have are quite close to the values in
% this publication.
%
% BW (c) Imageval Corporation LLC, 2013

%% List of names
mcc.names = cell(4,6);
mcc.names{1,1} = 'dark skin';
mcc.names{2,1} = 'orange';
mcc.names{3,1} = 'blue';
mcc.names{4,1} = 'white 9.5 (.05D)';
mcc.names{1,2} = 'light skin';
mcc.names{2,2} = 'purplish blue';
mcc.names{3,2} = 'green';
mcc.names{4,2} = 'neutral 8 (.23D)';
mcc.names{1,3} = 'blue sky';
mcc.names{2,3} = 'moderate red';
mcc.names{3,3} = 'red';
mcc.names{4,3} = 'neutral 6.5(.44D)';
mcc.names{1,4} = 'foliage';
mcc.names{2,4} = 'purple';
mcc.names{3,4} = 'yellow';
mcc.names{4,4} = 'neutral 5 (.70D)';
mcc.names{1,5} = 'blue flower';
mcc.names{2,5} = 'yellow green';
mcc.names{3,5} = 'magenta';
mcc.names{4,5} = 'neutral 3.5 (1.05D)';
mcc.names{1,6} = 'bluish green';
mcc.names{2,6} = 'orange yellow';
mcc.names{3,6} = 'cyan';
mcc.names{4,6} = 'black 2 (1.5D)';

%% Gretag L*a*b* values for D50
%
% The LAB are listed in Table 1a and 1b. The ordering matches the names
% above. In this format, the names are across the top row, and then down to
% the next row.
%
% D50 illuminant is (Table 7)
%   WhiteD650 = [96.422, 100, 82.521];
%

% Consider this as XW format data copied
lab = ...
    [37.99 13.56 14.06;
    65.71 18.13 17.81;
    49.93 -4.88 -21.93;
    43.14 -13.10 21.91;
    55.11 8.84 -25.40;
    70.72 -33.40 -0.199;
    62.66 36.07 57.10;
    40.02 10.41 -45.96;
    51.12 48.24 16.25;
    30.33 22.98 -21.59;
    72.53 -23.71 57.25;
    71.94, 19.36, 67.86;
    28.78, 14.18 -50.30;
    55.26, -38.34 31.37;
    41.10 53.38 28.19;
    81.73 4.04 79.82;
    51.94, 49.99, -14.57;
    51.04, -28.63, -28.64;
    96.54, -0.425, 1.186;
    81.26, -0.638, -0.335;
    66.77, -0.734, -0.504;
    50.87, -0.153, -0.270;
    35.66, -0.421, -1.231;
    20.46, -0.079 -0.973];

% Convert to RGB format in the same ordering as we usually use, with white
% to black in bottom row
mcc.lab = imageTranspose(XW2RGBFormat(lab,6,4));

vcNewGraphWin;
colormap(gray)
imagesc(mcc.lab(:,:,1))

%% This is how we calculate XYZ and xy of the chart
WhiteD50 = [96.422, 100, 82.521];
% Matlab also has this as
% whitepoint('d50')

XYZ = lab2xyz(mcc.lab,WhiteD50);

vcNewGraphWin;
colormap(gray)
imagesc(XYZ(:,:,2))

% Chromaticity values of the chart under D50
xy = chromaticity(RGB2XWFormat(XYZ));
chromaticityPlot(xy)

%% Compare to the measured chart used by Imageval
%
% We measured the reflectance values and so we calculate from first
% principles

% These wavelengths
w = 400:700;
r = macbethReadReflectance(w);  % The reflectances
d50 = vcReadSpectra('D50',w);   % The D50 illuminant

% Calculate the radiance
radiance = diag(d50)*r;
ieXYZ = ieXYZFromEnergy(radiance',w);
whiteXYZ = ieXYZFromEnergy(d50',w);

% Scale so that the Y of the illuminant is 100
% s = 100/whiteXYZ(2);
% ieXYZ    = s * ieXYZ;
% whiteXYZ = s * whiteXYZ;
ieLAB = xyz2lab(ieXYZ,whiteXYZ);

%% Compare the official data and our measured and calculated under D50
iexy = chromaticity(ieXYZ);
chromaticityPlot(iexy);
hold on; plot(xy(:,1),xy(:,2),'.')

vcNewGraphWin
plot(ieXYZ(:),XYZ(:),'.')
xlabel('ie XYZ'), ylabel('XYZ')
set(gca,'xtick',0:25:100,'ytick',0:25:100)
axis square, grid on

vcNewGraphWin
plot(iexy(:),xy(:),'.')
xlabel('ie xy'), ylabel('xy')
set(gca,'xtick',0.1:0.1:0.6,'ytick',0.1:0.1:0.6)
axis equal, grid on

% All the way back to LAB
vcNewGraphWin
plot(ieLAB(:),mcc.lab(:),'o')
xlabel('ie LAB'), ylabel('LAB')
set(gca,'xtick',-100:25:100,'ytick',-100:25:100)
axis equal, grid on

%%  We could calculate srgb as well

% This is for the official
vcNewGraphWin([],'tall')
sRGB = xyz2srgb(XYZ);
subplot(2,1,1)
imagesc(sRGB)
title('OFFICIAL sRGB')

% This is for Imageval
tmp = XW2RGBFormat(ieXYZ,4,6);
iesRGB = xyz2srgb(tmp);
subplot(2,1,2)
imagesc(iesRGB)
title('IMAGEVAL sRGB')

%% Compare the sRGB values

% They are very linearly related
corrcoef(sRGB(:),iesRGB(:))

% But they are off by a small scale factor.  Notice that the diagonals in W
% are a little different from 1
% sRGB = iesRGB * W
W = RGB2XWFormat(sRGB) \ RGB2XWFormat(iesRGB);
W

imagescRGB(imageLinearTransform(iesRGB,W));

vcNewGraphWin;
plot(iesRGB(:),sRGB(:),'.')
xlabel('ie sRGB'), ylabel('sRGB');
set(gca,'xtick',0:.2:1,'ytick',0:.2:1);
axis equal, grid on
