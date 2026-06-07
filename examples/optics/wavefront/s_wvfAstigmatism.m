%% Wavefront calculations of astigmatism
%
% Compute the wavefront-based PSF for various astigmatism and
% blur levels. These values are controlled by the Zernike
% coefficients in the wavefront toolbox ( *wvf* ) functions.
%
% See also:  wvfCreate, wvfCompute
%
% (c) Wavefront Toolbox Team, 2012

%% Initialize
ieInit;

%% Range for plotting
maxUM  = 20;

%% Set up default parameters structure with diffraction limited default

% The ranges for coefficients here and below are reasonable given typical
% variation within human population.  If we look at the diagonal of the
% covariance matrix for coefficients that we get from the Thibos
% measurements (see wvfLoadThibosVirtualEyes we see that for the third
% through sixth coefficients, the standard deviations (sqrt of variances on
% the diagonal) range between about 0.25 and about 0.5.
wvfP = wvfCreate;
wvfP = wvfSet(wvfP,'lcaMethod','human');
wvfParams = wvfCompute(wvfP);

% The fourth and fifth coefficients are defocus and vertical
% astigmatism.
z4 = -0.5:0.5:0.5;
z5 = -0.5:0.5:0.5;
[Z4, Z5] = meshgrid(z4, z5);
Zvals = [Z4(:), Z5(:)];

%% Vary defocus and vertical astigmatism

% Make a plot of the psf for each case.
h = ieFigure;
set(h,'Position',[0.5 0.5 0.45 0.45]);
wList = 550; % wvfGet(wvfParams,'wave');

%%
for ii=1:size(Zvals,1)
    wvfParams = wvfSet(wvfParams,'zcoeffs',Zvals(ii,:),{'defocus' 'vertical_astigmatism'});
    wvfParams = wvfSet(wvfParams,'lcaMethod','human');
    wvfParams = wvfCompute(wvfParams);
    
    % Mesh
    subplot(3, 3, ii)
    wvfPlot(wvfParams, 'psf normalized', 'unit','um', 'wave', wList, 'plot range', maxUM, 'window', false);
    title('');
    if ii==1
        subtitle(sprintf('[Defocus,Astig] = (%.1f, %.1f)', Zvals(ii, 1), ...
        Zvals(ii, 2)));
    else
        subtitle(sprintf('(%.1f, %.1f)', Zvals(ii, 1), ...
        Zvals(ii, 2)));
    end


end

%%





