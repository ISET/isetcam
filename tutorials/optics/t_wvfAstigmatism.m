%% Wavefront calculations of astigmatism
%
% Compute the wavefront-based PSF for various astigmatism and
% blur levels. These values are controlled by the Zernike
% coefficients in the wavefront toolbox ( *wvf* ) functions.
%
% See also:  wvfCreate, wvfComputePSF
%
% (c) Wavefront Toolbox Team, 2012

%% Initialize
ieInit;

%% Range of sizes for for plotting PSFs
maxMM  = 1;
maxUM  = 8;

%% Set up default parameters structure with diffraction limited default
wvfP = wvfCreate;
wvfParams = wvfComputePSF(wvfP);
z = wvfGet(wvfParams,'zcoeffs');

% The fourth and fifth coefficients are defocus and vertical
% astigmatism.
zDefocus = -2:2:2; zAstigmatism = -1:1:1;   % Diopters
[Z4,Z5] = meshgrid(zDefocus,zAstigmatism);
Zvals = [Z4(:), Z5(:)];

%% Vary defocus and vertical astigmatism

% Make a plot of the psf for each case.
h = vcNewGraphWin;
set(h,'Position',[0.5 0.5 0.45 0.45]);
wList = 550; % wvfGet(wvfParams,'wave');
for ii=1:size(Zvals,1)
    wvfParams = wvfSet(wvfParams,'zcoeffs',Zvals(ii,:),{'defocus' 'vertical_astigmatism'});
    wvfParams = wvfComputePSF(wvfParams);
    
    % Don't open a new window with each plot.  Let them accumulate in the
    % subplots.
    subplot(3,3,ii)
    wvfPlot(wvfParams,'image psf space','um',wList,maxUM,'nowindow');
    title(sprintf('Defocus = %.1f Astig == %.1f\n',Zvals(ii,1),Zvals(ii,2)));
end

%%





