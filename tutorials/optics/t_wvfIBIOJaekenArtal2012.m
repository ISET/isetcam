% Show the average PSF and OTF for emmetropes and myopes with J&A 2012 data
%
% Description:
%    Tutorial showing average point spread function (PSF) and average
%    optical transfer function (OTF) for emmetropes and myopes based on
%    Jaeken & Artal 2012 dataset.
%
%    In short, the Jaeken and Artal dataset provides higher order
%    aberrations along the horizontal meridian (central 80 degrees, sampled
%    at 1 degree) for both eyes. These data contain 15 zernike coefficients
%    (OSA j-indices: 0:14) for each sample, for 130 subjects. Data are
%    based on a 4 mm pupil diameter, measured at 780 nm. No correction for
%    chromatic aberration.
%
%    The subjects can be divided into emmetropes based on their mean
%    central refraction in diopters (central 5 degrees, using the defocus
%    only (OSA j-index = 4). In the corresponding published article, the
%    subjects are also dividied into 6 non-overlapping groups based on the
%    strength of central refractions. This division is visualized by the
%    function wvfSortSubjectDataJaekenArtal2012.
%
% References:
%    Jaeken, B. & Artal, P. (2012) Optical Quality of Emmetropic and Myopic
%    Eyes in the Periphery Measured with High-Angular Resolution.
%    Investigative Ophthalmology & Visual Science, June 2012, Volume 53,
%    No. 7. Link: https://www.ncbi.nlm.nih.gov/pubmed/22511633
%
% See Also:
%    wvfLoadJaekenArtal2012Data, and wvfSortSubjectDataJaekenArtal2012
%

% History:
%    05/03/18  ek (NYU) First version of function
%    05/05/18  dhb      Cosmetic.
%    09/26/18  jnm      Formatting

%% Define which zernike coefficients we want to use
%
% In this case, all of them.  
zIndices = 0:14; 
whichEye = 'left';

% Eccentricity is [horiz vert]. Artal data varies in horizontal
% dimension only. We think eccen might be on the pupillary axis, not
% on the fovea. Best focus is at 8 deg.  Worse at 3 or 15.
eccen = [3 0];        
whichGroup = 'emmetropes';
% whichGroup = 'singleRandomEmmetrope';

%% Get wavefront and optics from Artal data with the requested parameters:
% The function wvfLoadJaekenArtal2012Data loads the wavefront zernike
% aberration data, and reconstructs one PSF per subject, then converted to
% an OTF per subject, then we average the subject's OTFs. Lastly, the
% average OTF will get converted back to an average PSF. The individual
% PSFs are constructed under the measured wavelength (780 nm), but then
% calculated and plotted for a more sensible (i.e. in the range of human
% sensitivity) wavelength (550 nm).
[wvf, oi] = wvfLoadWavefrontOpticsData('source', 'JaekenArtal2012', ...
    'jIndex', zIndices, 'whichEye', whichEye, ...
    'eccentricity', eccen, 'whichGroup', whichGroup, 'verbose', false);

%{
    % Faster ISETBio way to get the plots
    % 8 deg is the smallest PSF
    % 3 deg is larger.
    % wvfGet(wvf,'zcoeffs')
    wvfPlot(wvf,'psf space','um');
    title(sprintf('%.2f deg eccen',eccen(1)));
%}
    
%% Plot OTF

% Get [x,y] support for plotting OTF
otfSupport = wvfGet(wvf, 'otfSupport', 'mm');

ieNewGraphWin;
surf(otfSupport, otfSupport, fftshift(wvf.otf{1}));
set(gca, 'XLim', [-100 100], 'YLim', [-100 100])
xlabel('Freq (lines/mm)');
ylabel('Freq (lines/mm)');
title(sprintf('%s: OTF 550 nm, pupil 4 mm, eccen %d deg, %s eye', ...
    whichGroup, eccen, whichEye))

%% Get [x,y] support and plot PSF
psfSupport = wvfGet(wvf, 'spatial Support', 'um');
centeredPSF = [wvf.psf{1}(101:end,:);
    wvf.psf{1}(1:100,:)];
centeredPSFNormalized = centeredPSF./sum(centeredPSF);

% Plot PSF
ieNewGraphWin;
surf(psfSupport, psfSupport, centeredPSF)
set(gca, 'XLim', [-40 40], 'YLim', [-40 40])
xlabel('Pos (um)');
ylabel('Pos (um)');
title(sprintf('%s: PSF 550 nm, pupil 4 mm, eccen %d deg, %s eye', ...
    whichGroup, eccen, whichEye))

%% Plot normalized PSF
ieNewGraphWin;
surf(psfSupport, psfSupport, centeredPSFNormalized)
set(gca, 'XLim', [-40 40], 'YLim', [-40 40])
xlabel('Pos (um)');
ylabel('Pos (um)');
title(sprintf(strcat("%s: Normalized PSF 550 nm, pupil 4 mm, ", ...
    "eccen %d deg, %s eye"), whichGroup, eccen, whichEye))

%% END
