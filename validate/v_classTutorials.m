% v_tutorials
%
% Quick run through class homework files to verify that they run
% This requires having the teaching repository on your path.
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Run through all the tutorial files
if exist('hwImageFormation','file')
    hwImageFormation
    disp('Image Formation confirmed');
    close all
else
    disp('Psych 221 tutorials not on path and thus not checked')
    return;
end


%%
hwColorMatching
disp('Color Matching');
close all

%%
hwColorSpectrum
disp('Spectrum');
close all

%%
hwMetricsColor
disp('Metrics confirmed');
close all

%%
hwJPEGMonochrome
disp('JPEGMonochrome confirmed')
close all

%%
hwJPEGcolor
disp('JPEGColor confirmed')
close all

%%
hwSensorEstimation
disp('Sensor Estimation confirmed')
close all

%%
hwDisplayRendering
disp('Rendering confirmed')
close all

%%
hwDisplayRGB2Radiance
disp('RGB 2 Radiance confirmed')
close all

%%
hwPrinting
disp('Halftone confirmed')
close all

%% END
