% Convert data from Williams JOV paper into Matlab files.
%
% Syntax:
%   convertFiles2M.m
%
% Description:
%    The data include the spatial array of L, M, and S cone positions in
%    five subjects.
%
%    The data also include the estimated pointspread functions for 500,
%    550, and 600nm.  These are all near the fovea (central 1.5 deg).
%
%    Subject-specific spatial scale and eccentricity of the various PSFs
%    and cone mosaics are {subject, arcmin/pixel, eccentricity}
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% If (0, 0) is the fovea, then we make nasal, inferior < 0, temporal,
% superior > 0
subjectInfo = {...
    {'HS', .113, [-1, 0]}, ...
    {'YY', .124, [-1, 1]}, ...
    {'AP', .117, [-1.25, 0]}, ...
    {'MD', .127, -1, 0}, ...
    {'BS', .120, [-1.25, 0]}};
save subjectInfo subjectInfo

% These are the cone x, y positions for the different types of cones.
% d = xlsRead('ConeSpacing.xls');  save ConeSpacing d
load ConeSpacing

% The point spread functions are 100x100 tab-delimited data sets.
% They can be read and plotted as
% psf = load('APPSF500.txt'); mesh(psf)

% Some units we will want later for plotting
% Arcmin / pixel.  Remember it is 300 microns/deg.  So it is 5 arcmin per
% pixel
umPerDeg = 300;          % SI units
arcminPerDeg = 60;       % SI units
arcminPerPixel = 0.113;  % arcmin per pixel
umPerPixel = arcminPerPixel * (1 / arcminPerDeg) * umPerDeg; % um per pixel

% Pull the cone mosaics for individual subjects and plot here
%-----------------------
subject = 'HS';
subNum = 1;
col = [1, 2, 3];
arcminPerPixel = 0.113;

% Read and spatially scale xy positions
nanList = find(isnan(d(:, col(1))));
if isempty(nanList), lastPoint = size(d, 1);
else, lastPoint = min(nanList);
end

umPerPixel = arcminPerPixel * (1 / arcminPerDeg) * umPerDeg;  %um per pixel

% Read and spatially scale xy positions
r = 1:lastPoint;
xy = d(r, col(1:2));
coneType = d(r, col(3));
xy = umPerPixel * xy;

L = coneType == 1;
M = coneType == 2;
S = coneType == 3;
plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    xy(S, 1), xy(S, 2), 'bo');

clear psf;
psf{1} = load([subject, 'PSF500.txt']);
psf{2} = load([subject, 'PSF550.txt']);
psf{3} = load([subject, 'PSF600.txt']);

comment = subjectInfo{subNum};
save(subject, 'xy', 'coneType', 'arcminPerPixel', 'umPerPixel', ...
    'psf', 'comment')

%-----------------------
subject = 'YY';
subNum = 2;
col = [5, 6, 7];
arcminPerPixel = 0.124;  % arcmin per pixel

% Read and spatially scale xy positions
nanList = find(isnan(d(:, col(1))));
if isempty(nanList), lastPoint = size(d, 1);
else, lastPoint = min(nanList);
end

umPerPixel = arcminPerPixel * (1 / arcminPerDeg) * umPerDeg;  %um per pixel

% Read and spatially scale xy positions
r = 1:lastPoint;
xy = d(r, col(1:2)); coneType = d(r, col(3));
xy = umPerPixel*xy;

clear psf;
psf{1} = load([subject, 'PSF500.txt']);
psf{2} = load([subject, 'PSF550.txt']);
psf{3} = load([subject, 'PSF600.txt']);

L = coneType == 1;
M = coneType == 2;
S = coneType == 3;
plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    xy(S, 1), xy(S, 2), 'bo');

comment = subjectInfo{subNum};
save(subject, 'xy', 'coneType', 'arcminPerPixel', 'umPerPixel', ...
    'psf', 'comment')

%-----------------------
subject = 'AP';
subNum = 3;
col = [9, 10, 11];
arcminPerPixel = 0.117;  % arcmin per pixel

% Read and spatially scale xy positions
nanList = find(isnan(d(:, col(1))));
if isempty(nanList), lastPoint = size(d, 1);
else, lastPoint = min(nanList);
end

r = 1:lastPoint;
xy = d(r, col(1:2));
coneType = d(r, col(3));
xy = umPerPixel * xy;

umPerPixel = arcminPerPixel * (1 / arcminPerDeg) * umPerDeg;  %um per pixel

L = coneType == 1;
M = coneType == 2;
S = coneType == 3;
plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    xy(S, 1), xy(S, 2), 'bo');

clear psf;
psf{1} = load([subject, 'PSF500.txt']);
psf{2} = load([subject, 'PSF550.txt']);
psf{3} = load([subject, 'PSF600.txt']);

comment = subjectInfo{subNum};
save(subject, 'xy', 'coneType', 'arcminPerPixel', 'umPerPixel', ...
    'psf', 'comment')

%-----------------------
subject = 'MD';
subNum = 3;
col = [13, 14, 15];
arcminPerPixel = 0.127;  % arcmin per pixel

% Read and spatially scale xy positions
nanList = find(isnan(d(:, col(1))));
if isempty(nanList), lastPoint = size(d, 1);
else, lastPoint = min(nanList);
end

r = 1:lastPoint;
xy = d(r, col(1:2));
coneType = d(r, col(3));
xy = umPerPixel * xy;

umPerPixel = arcminPerPixel * (1 / arcminPerDeg) * umPerDeg;  %um per pixel

L = coneType == 1;
M = coneType == 2;
S = coneType == 3;
plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    xy(S, 1), xy(S, 2), 'bo');

clear psf;
psf{1} = load([subject, 'PSF500.txt']);
psf{2} = load([subject, 'PSF550.txt']);
psf{3} = load([subject, 'PSF600.txt']);

comment = subjectInfo{subNum};
save(subject, 'xy', 'coneType', 'arcminPerPixel', 'umPerPixel', ...
    'psf', 'comment')

%-----------------------
subject = 'BS';
subNum = 3;
col = [17, 18, 19];
arcminPerPixel = 0.120;  %arcmin per pixel

% Read and spatially scale xy positions
nanList = find(isnan(d(:, col(1))));
if isempty(nanList), lastPoint = size(d, 1);
else, lastPoint = min(nanList);
end

r = 1:lastPoint;
xy = d(r, col(1:2));
coneType = d(r, col(3));
xy = umPerPixel * xy;

umPerPixel = arcminPerPixel*(1/arcminPerDeg)*umPerDeg;  %um per pixel

L = coneType == 1;
M = coneType == 2;
S = coneType == 3;
plot(xy(L, 1), xy(L, 2), 'ro', xy(M, 1), xy(M, 2), 'go', ...
    xy(S, 1), xy(S, 2), 'bo');

clear psf;
psf{1} = load([subject, 'PSF500.txt']);
psf{2} = load([subject, 'PSF550.txt']);
psf{3} = load([subject, 'PSF600.txt']);

comment = subjectInfo{subNum};
save(subject, 'xy', 'coneType', 'arcminPerPixel', 'umPerPixel', ...
    'psf', 'comment')
