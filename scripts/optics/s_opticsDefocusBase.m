%% The impact of defocus, measured in D diopters, depends on the base level
%
% Description:
%  Uses the wavefront method to create diffraction-limited shift-invariant
%  optics with a 17 mm focal length (58 D power). Then introduce D diopters
%  of defocus and recompute.  Repeat this for an 8 mm focal length lens,
%  showing the change from the same D diopters.
%
%  Show the impact on rendering the radial line scene and show the impact
%  on the linespread ('ls wavelength') plot.
%
% Copyright ImagEval Consultants, LLC, 2011

%%
ieInit;

%% Test scene
% scene = sceneCreate('sweep frequency');
scene = sceneCreate('sweep frequency', 384, 30);

%% Compute a diffraction limited oi in the shift invariant model
oi = oiCreate('wvf');
D = 0;
oi = oiSet(oi, 'wvf zcoeffs', D, 'defocus');
oi = oiCompute(oi, scene);
ieAddObject(oi);
oiWindow;
oiPlot(oi, 'illuminance hline', [1, 50]);
title(sprintf('Defocus %.1f', D));

%%
D = 8;
oi = oiSet(oi, 'wvf zcoeffs', D, 'defocus');
oi = wvf2oi(wvfComputePSF(oi.wvf));
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', sprintf('Defocus %d', D));
ieAddObject(oi);
oiWindow;
oiPlot(oi, 'illuminance hline', [1, 50]);
title(sprintf('Defocus %.1f D on Power %.1f', D, 1 / oiGet(oi, 'wvf focal length')));

fprintf('\n---------\n');
flength = oiGet(oi, 'wvf focal length', 'm'); %
pDiameter = oiGet(oi, 'wvf pupil diameter', 'm'); % mm
fprintf('Focal length   %f m (%f power)\nPupil diameter %f m\n', flength, (1 / flength), pDiameter);
fprintf('F number       %f\n', oiGet(oi, 'wvf fnumber'));
fprintf('\n---------\n');

%% Change the power, but keep the fnumber

D = 0;
oi = oiCreate('wvf');
oi = oiSet(oi, 'wvf focal length', flength/2); % Much higher power
oi = oiSet(oi, 'wvf pupil diameter', 1e3*pDiameter/2); % Much higher power
oi = wvf2oi(wvfComputePSF(oi.wvf));
oi = oiCompute(oi, scene);
ieAddObject(oi);
oiWindow;
oiPlot(oi, 'illuminance hline', [1, 50]);
title(sprintf('Defocus %.1f D on Power %.1f', D, 1 / oiGet(oi, 'wvf focal length')));

%%  Smaller drop off
D = 8;
oi = oiSet(oi, 'wvf zcoeffs', D, 'defocus');
oi = wvf2oi(wvfComputePSF(oi.wvf));
oi = oiCompute(oi, scene);
ieAddObject(oi);
oiWindow;
oiPlot(oi, 'illuminance hline', [1, 50]);
title(sprintf('Defocus %.1f D on Power %.1f', D, 1 / oiGet(oi, 'wvf focal length')));

%%
D = 16;
oi = oiSet(oi, 'wvf zcoeffs', D, 'defocus');
oi = wvf2oi(wvfComputePSF(oi.wvf));
oi = oiCompute(oi, scene);
ieAddObject(oi);
oiWindow;
oiPlot(oi, 'illuminance hline', [1, 50]);
title(sprintf('Defocus %.1f D on Power %.1f', D, 1 / oiGet(oi, 'wvf focal length')));

%% Comments and Notes
%{
% Another useful plot
oiPlot(oi,'ls wavelength')
title('Diffraction limited');
%}
%{
% Sweep through a range, if you like.
for ii=2:2:8
    % Need to recompute the OTF/PSF
    % Perhaps this should always be done as part of the set?
    oi = oiSet(oi,'wvf zcoeffs',ii,'defocus');
    oi = wvf2oi(wvfComputePSF(oi.wvf));
    oi = oiCompute(oi,scene);
    oi = oiSet(oi,'name',sprintf('Defocus %d',ii));
    ieAddObject(oi); oiWindow;
end
oi = oiSet(oi,'wvf zcoeffs',0,'defocus');
oi = wvf2oi(wvfComputePSF(oi.wvf));
oi = oiSet(oi,'name',sprintf('Defocus %d',ii));
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('Diffraction'));
ieAddObject(oi); oiWindow;
%}
