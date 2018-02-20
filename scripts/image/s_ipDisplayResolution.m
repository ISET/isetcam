%% Display and camera resolution compared
%
% When we convert sensor data to a display, we need to convert
% the sensor data to match spatial resolution of the display. In
% this script we define some terms and analyze how the relative
% resolutions work together.
%
% We assume that a typical sensor acquires information about a
% scene that is 40 deg of visual angle.  Also, we assume that
% sensor pixels are counted as 'photo-sites', and that these are
% typically organized into 2x2 arrays as in the Bayer-style
% pattern.
%
% Copyright ImagEval Consultants, LLC, 2010

%% Typical display sizes (see also sensorFormats)
%
% Remember that each display pixel comprises an RGB group of sub-pixels.
HD1080 =[1920,1080];
HD720 = [1280  720];
LCD  =  [1024  780];
WVGA =  [800,  480];
WUXGA = [1920 1200];
WXGA1 = [1280  768];
WXGA2 = [1280  800];
WSXGAP= [1680,1050];
WSVGA = [1020, 600];
XGA   = [1024  768];
UXGA  = [1600,1200];
QXGA  = [2048,1536];
SXGAP = [1400,1050];
SXGA  = [1280,1024];
SVGA  = [800,  600];
VGA   = [640,  480];
CGA   = [320,  200];
QVGA  = [320,  240];
QQCIF = [72,    88];
QCIF =  [144,  176];
QQVGA = [120,  160];
CIF  =  [288,  352];

MPEG1   = [352 240];
IPHONE  = [480 320];  % iPhone
YOUTUBE = [560 340];  % YouTube
PAL     = [768 576];
NTSC    = [720 480];

%% Sensor calculations
%
% We calculate the example of packing each display pixel (RGB)
% with the data from a single 2x2 Bayer super-pixel in the
% sensor. This requires no demosaicking.  We would just average
% the two green and shove the values at each super-pixel into a
% display pixel.  (Most people don't think of it this way).

d = ieN2MegaPixel(prod(2*XGA),1);
fprintf('2xXGA %.2f\n',d);

% Alternatively, if we demosaick the display and sensor pixel
% counts are matched.
d = ieN2MegaPixel(prod(XGA),1);
fprintf('XGA %.2f\n',d);

% Now, if we want to render on a small display (iPhone), using a
% demosaicked image then we need only
d = ieN2MegaPixel(prod(IPHONE),2);
fprintf('iPhone %.2f\n',d);

% If we have a very large sensor (e.g., 4 Mpix) we reduce the
% sensor spatial resolution to only a small percentage of its
% natural size to fit everything into an iPhone display.  We
% define a notion of resolution gain, (rg), to calculate this.
%
% Specifically, resolution gain (rg) is the reduction in the
% megapixel count of the camera needed to fill up the display
%
%   sensorMP*rg = displayMP
%
% so for a small display (iPhone), assuming demosaicking, we have
% a resolution gain

sensorMP = 4;
d = ieN2MegaPixel(prod(IPHONE),2)/sensorMP;
fprintf('sensorMP %d and iPhone %.2f\n',sensorMP, d);

% For a big display we have an rg value of
d = ieN2MegaPixel(prod(HD1080),2)/sensorMP;
fprintf('sensorMP %d and HD1080 %.2f\n',sensorMP, d);

% Without demosaicking, just a super-pixel to pixel match, we have
d = ieN2MegaPixel(prod(2*IPHONE),2)/sensorMP;
fprintf('sensorMP %d and 2*iPhone %.2f\n',sensorMP, d);

% For a big display we have an rg value of
d = ieN2MegaPixel(prod(2*HD1080),2)/sensorMP;
fprintf('sensorMP %d and 2*HD1080 %.2f\n',sensorMP, d);

% In the HD1080 case without demosaicking, we need an 8 Mpix camera to
% achieve a unit resolution gain 
sensorMP = 8;
ieN2MegaPixel(prod(2*HD1080),2)/sensorMP;
fprintf('sensorMP %d and 2*HD1080 %.2f\n',sensorMP,d);

% We could calculate things like how much you can zoom an image
% for a given display and sensor.  You might assume that it is OK
% to zoom an image up to the native resolution of the sensor, for
% example.  Zooming beyond that enters the real of upsampling and
% the dreaded image processing world. Eeek.
%
% You could also consider issues about cropping.
%
% You can also note that binning means you lose the native
% resolution early on, and it can never be retrieved because it
% never comes off the sensor. The field of view is preserved (no
% cropping) but the spatial resolution is destroyed by the
% binning.
%

%% 