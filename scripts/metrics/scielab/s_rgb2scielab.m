% s_rgb2scielab.m
%
% Illustrates the Spatial-CIELAB (SCIELAB) metric calculation using ISET.
%
% This scripts shows how to read an RGB image into a scene and calculate
% the scielab differences between two tif images.  We assume that the tif
% images are srgb.
%
% See Also: s_scielabExample
%   s_scielabExample shows the same basic calculation but in more detail.
%   It illustrates the conversion of the RGB data into XYZ data from the
%   calibrated display and it also shows how to set up the scielab()
%   arguments in the call.
%
% Copyright ImagEval, LLC, 2011

%%
ieInit

%% Specify the files

% There are lots of scenes remotely to use, also.
% rd = RdtClient('isetbio');
% rd.crp('/resources/scenes/hyperspectral/stanford_database/fruit');

file1 = fullfile(isetRootPath, 'data','images','rgb','hats.jpg');
file2 = fullfile(isetRootPath, 'data','images','rgb','hatsC.jpg');

%% some important viewing conditions
vDist = 0.3;          % 12 inch viewing distance
dispCal = 'crt.mat';   % Calibrated display

%% the scielab calculation (again, see s_scielabExample.m for a more detailed calculation
[eImage,s1,s2] = scielabRGB(file1, file2, dispCal, vDist);

% This is the mean delta E
mean(eImage(:))

% Show the RGB images as scenes, illustrating how the RGB data were
% converted to SPDs using the calibrated display
vcAddAndSelectObject(s1); vcAddAndSelectObject(s2);sceneWindow;


%% Examining and interpreting the results.
vcNewGraphWin;
imagesc(eImage);
colorbar('vert');
title('S-CIELAB error map')

vcNewGraphWin;
histogram(eImage(:),100)
title('S-CIELAB delta E histogram')


%% calculate the mean DE for values greater than 2
count = 0;
DEdifs = 0;
rows = max(size(eImage(:,1)));
cols = max(size(eImage(1,:)));
for ii = 1:max(rows)
    for jj = 1: max(cols)
        if eImage(ii,jj) > 2.0
            DEdifs = eImage(ii,jj) + DEdifs;
             count = count +1;
    end
    end
end
MeanAbove2 = mean(DEdifs/count);
percent = (count/ (rows * cols ))* 100;
fprintf('Mean of Delta E with values greater than 2: %f\n',MeanAbove2);
fprintf('Percent of Delta E with values greater than 2: %f\n',percent);

%%