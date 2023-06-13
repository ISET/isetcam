%% t_wvfMTF
%
%  Calculate and plot the MTF for different defocus values on the standard
%  human wvf
% 

%% 
ieInit

%% Base  wavefront objects

wave = 550;

wvfD = wvfCreate();                    % Diffraction limited
wvfD = wvfSet(wvfD, 'measured wavelength', 550);
wvfD = wvfSet(wvfD, 'calc wavelengths', 550);
wvfD = wvfComputePSF(wvfD);
wvfPlot(wvfD,'psf','min',wave,5);

%%
[~,wvfH] = opticsCreate('wvf human');  % Thibos human model
wvfH = wvfSet(wvfH, 'measured wavelength', 550);
wvfH = wvfSet(wvfH, 'calc wavelengths', 550);
wvfH = wvfComputePSF(wvfH);
wvfPlot(wvfH,'psf','min',wave,5);

%% Vary defocus and plot a slice through the diffraction limited PSF

% Diffraction limited

vcNewGraphWin;
d = [0 , 0.15, 0.5, 0.7];
thisL = cell(length(d),1);
for ii=1:length(d)
    wvf1 = wvfSet(wvfD,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d psf space', 'um', wave, 10, 'nowindow');
    hold on;
    thisL{ii} = sprintf('D = %0.2f',d(ii));
end

hold off
xlabel('um'); ylabel('Relative amp'); grid on
legend(thisL);

% Human version

vcNewGraphWin;
d = [0 , 0.15, 0.5, 0.7];
thisL = cell(length(d),1);
for ii=1:length(d)
    wvf1 = wvfSet(wvfH,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d psf space', 'um', wave, 10, 'nowindow');
    hold on;
    thisL{ii} = sprintf('D = %0.2f',d(ii));
end

hold off
xlabel('um'); ylabel('Relative amp'); grid on
legend(thisL);


%% PSFs

% Compare the two diffraction PSFs

vcNewGraphWin([],'tall');
subplot(2,1,1);
wvfPlot(wvfD, 'psf space', 'um', wave, 10,'no window');
legend({'Diffraction D=0'})

thisD = d(3);
subplot(2,1,2);
wvf1 = wvfSet(wvfD,'zcoeffs',thisD,{'defocus'});
wvf1 = wvfComputePSF(wvf1);
wvfPlot(wvf1, 'psf space', 'um', wave, 10,'no window');
legend({sprintf('Diffraction D=%1.1f',thisD)})

%% Compare the two human PSFs
vcNewGraphWin([],'tall');
subplot(2,1,1);
wvfPlot(wvfH, 'psf space', 'um', wave, 10,'no window');
legend({'Human D=0'})

thisD = d(3);
subplot(2,1,2);
wvf1 = wvfSet(wvfH,'zcoeffs',thisD,{'defocus'});
wvf1 = wvfComputePSF(wvf1);
wvfPlot(wvf1, 'psf space', 'um', wave, 10,'no window');
legend({sprintf('Human D=%1.1f',thisD)})

%%  Show the impact in diffraction MTF 

vcNewGraphWin;
for ii=1:length(d)
    wvf1 = wvfSet(wvfD,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d otf angle', 'deg', wave, 100, 'nowindow');
    hold on;
    thisL{ii} = sprintf('Diffraction D = %0.2f',d(ii));
end

hold off
xlabel('cycles/deg'); ylabel('Relative amp'); grid on
legend(thisL);

%%  Show the impact in human MTF version
%
% This is like a plot TL and BW spotted in a Navarrow paper.  Get the
% reference and put it here!
%

vcNewGraphWin;
for ii=1:length(d)
    wvf1 = wvfSet(wvfH,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d otf angle', 'deg', wave, 100, 'nowindow');
    hold on;
    thisL{ii} = sprintf('Human D = %0.2f',d(ii));
end

hold off
xlabel('cycles/deg'); ylabel('Relative amp'); grid on
legend(thisL);

%% Now plot this with respect to angle (cpd), not space

vcNewGraphWin;
for ii=1:length(d)
    wvf1 = wvfSet(wvfD,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d otf angle', 'deg', wave, 100, 'nowindow');
    hold on;
    thisL{ii} = sprintf('Diffraction D = %0.1f',d(ii));
end

hold off
xlabel('deg'); ylabel('Relative amp'); grid on
legend(thisL);

%%
vcNewGraphWin;
for ii=1:length(d)
    wvf1 = wvfSet(wvfH,'zcoeffs',d(ii),{'defocus'});
    wvf1 = wvfComputePSF(wvf1);
    wvfPlot(wvf1, '1d otf angle', 'deg', wave, 100, 'nowindow');
    hold on;
    thisL{ii} = sprintf('Human D = %0.1f',d(ii));
end

hold off
xlabel('cycles/deg'); ylabel('Relative amp'); grid on
legend(thisL);

%% Read to compute the MTF/OTF now!

%%


        