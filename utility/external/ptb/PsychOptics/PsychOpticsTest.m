% Basic tests and comparisons of PsychOptics routines
%
% Description:
%     Basic tests and comparisons of PsychOptics routines, in particular our ability
%     to go back and forth between LSFs and PSFs and between PSFs and OTFs.
% 
%     Also useful for remembering the usage of various routines.
% 
%     This also makes some useful plots that compare different estimates of
%     monochromatic human optics from the older literature.  These estimates
%     are probably not as good as using wavefront methods (see isetbio at
%     isetbio.org for data and code), but it is useful to have them for
%     comparing with calculations in the literature that used these estimates.

% History:
%   01/04/18  dhb   Added some regression tests.
%   01/25/18  dhb   Typo fix on direction of one check conversion.

%% Clear
clear; close all; 

%% LSF <-> PSF conversions

% Compute Westheimer and Davila/Geisler LSFs from the formulae provided.
%
% Set up spatial sampling in one-dimension, both in space domain and
% corresponding frequency domain.
% For the symmetric phase component to work nSamples MUST BE EVEN and the
% 1D LSF support must be long enough so that the LSF goes to zero

% Define spatial support.
%
% Number of samples can be even or odd.
nSpatialSamples = 513;
centerPosition = floor(nSpatialSamples/2)+1;
if (rem(nSpatialSamples,2) == 0)
    integerSamples1D = -nSpatialSamples/2:nSpatialSamples/2-1;
else
    integerSamples1D = -floor(nSpatialSamples/2):floor(nSpatialSamples/2);
end
maxPositionMinutes = 8;
maxSfCyclesPerDegree = 60*(nSpatialSamples/2)/(2*maxPositionMinutes);
positionMinutes1D = maxPositionMinutes*integerSamples1D/(centerPosition-1);

% These produce similar lsf's for the human eye, from the literature.
WestLSF = WestLSFMinutes(abs(positionMinutes1D));
GeislerLSF = GeislerLSFMinutes(abs(positionMinutes1D));
DavilaGeislerLSF = DavilaGeislerLSFMinutes(abs(positionMinutes1D));

% Westheimer also gives a formula for the PSF (in addition to the LSF).
%
% Get this for comparison.
[xGridMinutes,yGridMinutes] = meshgrid(positionMinutes1D,positionMinutes1D);
radiusMinutes2D = sqrt(xGridMinutes.^2 + yGridMinutes.^2);
WestPSFFormula = WestPSFMinutes(abs(radiusMinutes2D));
WestPSFFormula = WestPSFFormula/sum(WestPSFFormula(:));
if (WestPSFFormula(centerPosition,centerPosition) ~= max(WestPSFFormula(:)))
    error('We don''t understand spatial coordinates as well as we should.');
end

%% Get PSFs from LSF
WestPSFDerived = LsfToPsf(WestLSF);
GeislerPSFDerived = LsfToPsf(GeislerLSF);
DavilaGeislerPSFDerived = LsfToPsf(DavilaGeislerLSF);

%% And get LSF back again.
%
% This is done by convolution and if things are working will produce
% what we started with to good approximation.
WestLSFFromPSFFormula = PsfToLsf(WestPSFFormula);
WestLSFFromPSFDerived = PsfToLsf(WestPSFDerived);
DavilaGeislerLSFFromPSFDerived = PsfToLsf(DavilaGeislerPSFDerived);

%% Check that max of returned psf is where we think it should be.
%
% This check does assume an PSF with its max at 0, which is true for the
% Westheimer and Davila-Geisler cases.
if (WestPSFDerived(centerPosition,centerPosition) ~= max(WestPSFDerived(:)))
    error('We don''t understand spatial coordinates as well as we should.');
end
if (DavilaGeislerPSFDerived(centerPosition,centerPosition) ~= max(DavilaGeislerPSFDerived(:)))
    error('We don''t understand spatial coordinates as well as we should.');
end

%% Make a figure that compares the original and derived LSFs
%
% The LSF we get by going from LSF -> PSF -> LSF matches pretty
% well.  The LSF we get from Westheimer's PSF differs, which I
% believe is real inconsitency between Westheimer's PSF and LSF.
fig1 = figure;
set(gcf,'Position',[100 100 1200 800]);
set(gca, 'FontSize', 14);
subplot(2,2,1); hold on
plot(positionMinutes1D,WestLSF,'r','LineWidth',4);
plot(positionMinutes1D,WestLSFFromPSFDerived,'g-', 'LineWidth', 2);
plot(positionMinutes1D,WestLSFFromPSFFormula,'k-', 'LineWidth', 2);
xlim([-4 4]);
xlabel('Position (minutes');
ylabel('Normalized LSF');
title('Westheimer')
legend({'Original','Recovered from Derived PSF','Recovered from Formula PSF'},'Location','NorthEast');
if (max(abs(WestLSF(:)-WestLSFFromPSFDerived(:))) > 5e-3)
    error('Westheimer LSF -> PSF -> LSF is not close enough');
end

subplot(2,2,2); hold on
plot(positionMinutes1D,DavilaGeislerLSF,'r','LineWidth',4);
plot(positionMinutes1D,DavilaGeislerLSFFromPSFDerived,'g-', 'LineWidth', 2);
xlim([-4 4]);
xlabel('Position (minutes)');
ylabel('Normalized LSF');
title('Davila-Geisler');
legend({'Original','Recovered from PSF'},'Location','NorthEast');
if (max(abs(DavilaGeislerLSF(:)-DavilaGeislerLSFFromPSFDerived(:))) > 5e-3)
    error('DavilaGeisler LSF -> PSF -> LSF is not close enough');
end    

subplot(2,2,3); hold on
plot(positionMinutes1D,WestPSFDerived(centerPosition,:)/max(WestPSFDerived(centerPosition,:)),'r','LineWidth',4);
plot(positionMinutes1D,WestPSFFormula(centerPosition,:)/max(WestPSFFormula(centerPosition,:)),'k-','LineWidth',2);
xlim([-4 4]);
title('Westheimer')
xlabel('Position (minutes)');
ylabel('Normalized PSF Slice');
legend({'Derived from LSF','Formula PSF'},'Location','NorthEast');

subplot(2,2,4); hold on
plot(positionMinutes1D,GeislerPSFDerived(centerPosition,:)/max(GeislerPSFDerived(centerPosition,:)),'r','LineWidth',3);
plot(positionMinutes1D,DavilaGeislerPSFDerived(centerPosition,:)/max(DavilaGeislerPSFDerived(centerPosition,:)),'b','LineWidth',3);
xlim([-4 4]);
xlabel('Position (minutes');
ylabel('Normalized PSF Slice');
title('Davila-Geisler and Williams et al. PSFs')

%% PSF <-> OTF conversions

% Make a diffraction limited psf and convert to OTF.
%
% This is a nice case because we have independent analytic formulae for
% both psf and otf.
%
% The AiryPattern function takes its angle in radians, just to keep us on
% our toes.  So we get the analytic psf and then convert it to the otf.
Diffraction_3_633_PSFAnalytic = AiryPattern((pi/180)*(radiusMinutes2D/60),3,633);
Diffraction_3_633_PSFAnalytic = Diffraction_3_633_PSFAnalytic/sum(Diffraction_3_633_PSFAnalytic(:));
[xSfGridCyclesDeg,ySfGridCyclesDeg,Diffraction_3_633_OTFFromPSFAnalytic] = PsfToOtf(xGridMinutes,yGridMinutes,Diffraction_3_633_PSFAnalytic);

% Convert the otf back to psf.  This should definitely match what we started with or else
% something is badly wrong.
[xGridMinutes,yGridMinutes,Diffraction_3_633_PSFFromOTFFromPSFAnalytic] = OtfToPsf(xSfGridCyclesDeg,ySfGridCyclesDeg,Diffraction_3_633_OTFFromPSFAnalytic);

% Make an OTF directly from an analytic formula that is different from the Airy function and convert that back to PSF
radiusSfCyclesDeg2D = sqrt(xSfGridCyclesDeg.^2 + ySfGridCyclesDeg.^2);
Diffraction_3_633_OTFFromAnalytic = DiffractionMTF(radiusSfCyclesDeg2D,3,633);
[xGridMinutes1,yGridMinutes1,Diffraction_3_633_PSFFromOTFAnalytic] = OtfToPsf(xSfGridCyclesDeg,ySfGridCyclesDeg,Diffraction_3_633_OTFFromAnalytic);

% Let's get the point spread function from Williams et al.
WilliamsOTF = WilliamsMTF(radiusSfCyclesDeg2D);
[xGridMinutes2,yGridMinutes2,WilliamsPSF] = OtfToPsf(xSfGridCyclesDeg,ySfGridCyclesDeg,WilliamsOTF);
[WilliamsTablePositions,WilliamsTablePSF] = WilliamsTabulatedPSF;

% Compare these wonderful things
%
% First the otfs. These are very close, although not exactly the same.  Not
% sure if this is just a numerical thing, or maybe the result of not quite
% converting between position and spatial frequency exactly right, or some similar
% subtle problem in the routines that computer the Airy pattern and the diffraction
% limited otf.  Clearly this is working well enough for practical purposes.
fig2 = figure;
set(gcf,'Position',[100 100 1200 800]);
set(gca, 'FontSize', 14);
subplot(2,2,1); hold on
plot(xSfGridCyclesDeg(centerPosition,:),abs(Diffraction_3_633_OTFFromPSFAnalytic(centerPosition,:)),'r','LineWidth',4);
plot(xSfGridCyclesDeg(centerPosition,:),abs(Diffraction_3_633_OTFFromAnalytic(centerPosition,:)),'g-','LineWidth',2);
xlim([-100 100]); ylim([0 1]);
xlabel('Cycles/Deg');
ylabel('OTF');
title('Diffraction Limited OTFs');
legend({'Derived from Anaytic PSF', 'Analytic OTF'},'Location','NorthEast');
if (max(abs(Diffraction_3_633_OTFFromPSFAnalytic(:) - Diffraction_3_633_OTFFromAnalytic(:))) > 5e-2)
    error('Diffraction limited analytic and derived OTFs are not close enough');
end  

% Then the psfs.
subplot(2,2,2); hold on
plot(xGridMinutes(centerPosition,:),Diffraction_3_633_PSFFromOTFFromPSFAnalytic(centerPosition,:)/max(Diffraction_3_633_PSFFromOTFFromPSFAnalytic(centerPosition,:)),'r','LineWidth',4);
plot(positionMinutes1D,Diffraction_3_633_PSFAnalytic(centerPosition,:)/max(Diffraction_3_633_PSFAnalytic(centerPosition,:)),'g-','LineWidth',2);
xlim([-4 4]);
xlabel('Position (minutes');
ylabel('Normalized PSF Slice');
title('Diffraction Limited PSFs')
legend({'Derived from Anaytic OTF', 'Analytic PSF'},'Location','NorthEast');
if (max(abs(Diffraction_3_633_PSFFromOTFFromPSFAnalytic(:)/max(Diffraction_3_633_PSFFromOTFFromPSFAnalytic(centerPosition,:)) - Diffraction_3_633_PSFAnalytic(:)/max(Diffraction_3_633_PSFAnalytic(centerPosition,:)))) > 1e-10)
    error('Diffraction limited analytic and derived PSFs are not close enough');
end  

% Williams otf along with tabulated points from their Table 1.
% The fit in the paper smooths the measurements and by eye the deviations
% are not out of line with measurement variability.
subplot(2,2,3); hold on
plot(xSfGridCyclesDeg(centerPosition,:),abs(WilliamsOTF(centerPosition,:)),'r','LineWidth',4);
plot([10 20 30 40 50],[0.458 0.291 0.178 0.147 0.119],'ko','MarkerSize',4,'MarkerFaceColor','k');
xlim([-100 100]); ylim([0 1]);
xlabel('Cycles/Deg');
ylabel('OTF');
title('Williams et al. OTF');
legend({'Williams et al. formula','Tabulated data'});

% And the corresponding PSF, along with their tabulated PSF from their Table 2.
% The agreement here is reassuring, since those points were computed from
% the same otf many years ago, albeit through a different bit of code than
% is being used here.  The fft still works.
subplot(2,2,4); hold on
plot(xGridMinutes2(centerPosition,:),WilliamsPSF(centerPosition,:)/max(WilliamsPSF(centerPosition,:)),'r','LineWidth',4);
plot(WilliamsTablePositions,WilliamsTablePSF/max(WilliamsTablePSF(:)),'ko','MarkerSize',4,'MarkerFaceColor','k');
xlim([-4 4]);
xlabel('Position (minutes');
ylabel('Normalized PSF Slice');
title('Williams et al. PSF')
legend({'Derived PSF','Tabulated data'});

% And stick the Williams PSF into Figure 1, for comparison to
% Davila-Geisler.
figure(fig1);
subplot(2,2,4); hold on
plot(xGridMinutes2(centerPosition,:),WilliamsPSF(centerPosition,:)/max(WilliamsPSF(centerPosition,:)),'g-','LineWidth',2);
legend({'G Derived from LSF', 'D-G Derived from LSF', 'Williams et al. from OTF'},'Location','NorthEast');

