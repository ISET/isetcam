function t_wvfZernickeSet
% Illustrate the effects of adjusting Zernicke coefficients on the PSF
%
% Syntax:
%   t_wvfZernickeSet
%
% Description:
%    Illustrate the effects on the PSF of adjusting different Zernicke
%    polynomial coefficients.
%
%    We create an image of the slanted bar and pass it through the optics.
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

% History:
%    xx/xx/14  BW   Wavefront Toolbox Team, 2014
%    01/01/18  dhb  Handled JNM notes
%    09/25/18  jnm  Formatting

%% Initialize & Create a Scene
ieInit;
scene = sceneCreate('slanted bar');

%% Create wavefront object and push it into an optical image object
wvf = wvfCreate;
wvf = wvfComputePSF(wvf);

% Plot for wavefront object
% Args give plot type, plot units, wavefront list, plot range
wvfPlot(wvf, '2dpsfspace', 'um', 550, 20);
oi = wvf2oi(wvf);

%% Compute the optical image
oi = oiCompute(oi, scene);
vcAddObject(oi);
oiWindow;

%% Change the defocus coefficient
% The ranges for coefficients here and below are reasonable given typical
% variation within human population. If we look at the diagonal of the
% covariance matrix for coefficients that we get from the Thibos
% measurements (see wvfLoadThibosVirtualEyes we see that for the third
% through sixth coefficients, the standard deviations (sqrt of variances on
% the diagonal) range between about 0.25 and about 0.5.
wvf = wvfCreate;
D = [0, 0.5, 1];
for ii = 1:length(D)
    wvf = wvfSet(wvf, 'zcoeffs', D(ii), {'defocus'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf, '2dpsfspace', 'um', 550, 20);
    oi = wvf2oi(wvf);
    oi = oiCompute(oi, scene);
    oi = oiSet(oi, 'name', sprintf('D %.1f', D(ii)));
    vcAddObject(oi);
    oiWindow;
end

%% Now astigmatism with a little defocus
wvf = wvfCreate;
A = [-0.5, 0, 0.5];
for ii = 1:length(A)
    wvf = wvfSet(wvf, 'zcoeffs', [0.5, A(ii)], ...
        {'defocus', 'vertical_astigmatism'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf, '2dpsfspace', 'um', 550, 20);
    oi = wvf2oi(wvf);
    oi = oiCompute(oi, scene);
    oi = oiSet(oi, 'name', sprintf('D %.1f, A %.1f', 0.5, A(ii)));
    vcAddObject(oi);
    oiWindow;
end
