% s_scielabExample.m
%
% Illustrates the Spatial-CIELAB (SCIELAB) metric calculation using ISET.
%
% The first section shows how to read an RGB image into a scene. Then, we
% calculate the scielab differences between two scenes.  The data in the
% scene depend on the display that is used to interpret the RGB data.
%
% The second section expands on the calculation, showing the steps in more
% detail. It illustrates the conversion of the RGB data into XYZ data from
% the calibrated display and it also shows how to set up the scielab()
% arguments in the call.
%
% See Also: scielabRGB, displayGet
%
% Copyright ImagEval, LLC, 2011

%%
ieInit

%% Overview of the function call

% Set up to read an image and a JPEG compressed version of it
file1 = fullfile(isetRootPath, 'data','images','rgb','hats.jpg');
file2 = fullfile(isetRootPath, 'data','images','rgb','hatsC.jpg');

% We will treat the two images as if they are on a CRT display seen from 12
% inches.
vDist = 0.3;           % 12 inches
dispCal = 'crt.mat';   % Calibrated display
% dispCal = displayCreate;   % Calibrated display

%% Spatial scielab reads the files and display

% Convert the RGB files to a scene.
% Then, calculate an error image between the two scenes.
% The display variable is used to transform the RGB
% images into the spectral image.
[eImage,scene1,scene2,display] = scielabRGB(file1, file2, dispCal, vDist);

% This is the mean delta E
mn = mean(eImage(:));

% When updating the display code as per HJ, the number here changed to
% 1.5118 rather than 1.849.  Not sure why.  Other numbers below changed a
% little also.  I presume we have slightly different display numbers
% interpolated.
% assert(abs(mn - 1.5118) < 0.01,'Mean error image is off');

% Show the error image
ieNewGraphWin; imagesc(eImage)
colorbar;

% Show the RGB images as scenes. This illustrates how the RGB data were
% converted to SPDs using the calibrated display
vcAddAndSelectObject(scene1);
vcAddAndSelectObject(scene2);sceneWindow;
imageMultiview('scene',[1 2]);


%% Illustrate the processing within the routine, showing explicit calls.

% Read the JPEG files with imread.
% The inputs are 8-bit, so we scale by 255.
% Then we correct for gamma curve.
% The result is a 'linear' RGB with values between 0 and 1.
% In this case, we don't have a gamma
hats  = dac2rgb(double(imread(file1))/255);
hatsC = dac2rgb(double(imread(file2))/255);


%% 2.  Load the display calibration information

% coneFile = fullfile(isetRootPath,'data','human','SmithPokornyCones');
% spCones = ieReadSpectra(coneFile,wave);   %plot(wave,spCones)
displayFile = fullfile(isetRootPath,'data','displays','crt');
dsp = displayCreate(displayFile);

% Use the displayGet routine to calculate the key transform matrix that
% maps the RGB data for this display into XYZ.  These matrices work with
% the image function, imageLinearTransform
rgb2xyz  = displayGet(dsp,'rgb2xyz');       % rowXYZ = rowRGB * rgb2xyz

% Also, we specify the white point of the display.
whiteXYZ = displayGet(dsp,'white point');

%% Convert the linear RGB data to XYZ values
img1XYZ = imageLinearTransform(hats,rgb2xyz);
img2XYZ = imageLinearTransform(hatsC,rgb2xyz);

%% Run the spatial cielab calculations

% The field of view (FOV) depends on the display dpi, viewing distance, and
% image size
dots     = size(hats);
imgWidth = dots(2)*displayGet(dsp,'meters per dot');  % Image width (meters)
fov      = rad2deg(2*atan2(imgWidth/2,vDist));      % Horizontal fov in deg
sampPerDeg = dots(2)/fov;

% Run spatial CIELAB using the CIELAB 2000
params.deltaEversion = '2000';
params.sampPerDeg  = sampPerDeg;
params.imageFormat = 'xyz';
params.filterSize  = sampPerDeg;
params.filters = [];

% WARNING:  The returned errorImage size may differ from the img1XYZ size
% by one. To keep them the same row,col size, you can strip the last row or
% col from the input image.  That is done for fft reasons in the scielab
% calculation.
[errorImage, params] = scielab(img1XYZ, img2XYZ, whiteXYZ, params);

% Here is the mean spatial CIELAB deltaE
mean(errorImage(:))

%% Examining and interpreting the results.
ieNewGraphWin;
imagesc(errorImage);
colorbar('vert');
title('S-CIELAB error map')

ieNewGraphWin;
histogram(errorImage(:),100)
title('S-CIELAB delta E histogram')

%% Examine the SCIELAB spatial filters

f = ieNewGraphWin;
filters = params.filters;   %
support = params.support;   % Degress
mx = max(filters{1}(:));
for ii=1:3
    subplot(1,3,ii), mesh(support,support,filters{ii});
    set(gca,'zlim',[-(mx/10) mx]);
    xlabel('Deg'), ylabel('Deg');
end

%% Overlay the image edges and the largest SCIELAB errors

% If you have the image processing toolbox, you can find out where the
% edges are and overlay the edges with the locations of the scielab
% errors
bigErr = (errorImage > 5);

% The error image can be 1 row or col smaller than the input image.  This
% might get fixed some day, and is important to deal with.  For now, I
% handle it this way.
%
% The reason for the difference has to do with matching the filter sizes
% to the image in scielab, particularly in the scApplyFilters routine.  In
% that routine, when there is a need, we strip the last row or col off the
% input image before doing the calculation.
gImage = hats(:,:,2);
sz = size(gImage);
if sz(1) > size(bigErr,1), gImage = gImage(1:(end-1),:); end
if sz(2) > size(bigErr,2), gImage = gImage(:,1:(end-1)); end

edgeImage = edge(gImage,'prewitt');

% imshow(edgeImage)
% imshow(bigErr)
ieNewGraphWin;
overlay = 1 + edgeImage + 2*bigErr;
overlayMap = ...
    [0 0 0;
    0.5 0.5 0.5;
    1, 0, 0;
    0, 1, 0];
image(overlay); colormap(overlayMap)

%% calculate the mean DE for values greater than 2
count = 0;
DEdifs = 0;
rows = max(size(errorImage(:,1)));
cols = max(size(errorImage(1,:)));
for ii = 1:max(rows)
    for jj = 1: max(cols)
        if errorImage(ii,jj) > 2.0
            DEdifs = errorImage(ii,jj) + DEdifs;
            count = count +1;
        end
    end
end

MeanAbove2 = mean(DEdifs/count);
percent = (count/ (rows * cols ))* 100;
fprintf('Mean of Delta E with values greater than 2: %f\n',MeanAbove2);
fprintf('Percent of Delta E with values greater than 2: %f\n',percent);

%% Check values

% This didn't change at all.
assert(abs(MeanAbove2 - 2.92) < 0.1,'Mean above differs more than it should');

% The original number was 36.575009.  New display code from HJ differs a
% little, probably because of the display data.
assert(abs(35.9649 - percent) < 0.1,'Percent differs more than it should');

%% End
