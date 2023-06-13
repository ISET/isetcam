function t_wvfIBIOZernike
% Representing wavefront aberrations using Zernike polynomials.
%
% Syntax:
%   t_wvfZernike
%
% Description:
%    This tutorial explains a method of representing the wavefront
%    aberration function using a set of functions known as Zernike
%    polynomials. The wavefront aberration function models the effect of
%    the human cornea, lens, and pupil on the optical wavefront propagating
%    through them. Absorption is modeled by an amplitude < 1, and phase
%    aberrations are modeled by a complex phasor of the form
%
%       exp(i * 2 * pi * [summation of Zernike polynomials] / wavelength).
%
%    From Fourier optics, the eye's point spread function (PSF) can be
%    computed from the wavefront aberration function, or pupil function, by
%    taking the Fourier transform: PSF = fft2(pupil function). We tend to
%    do this through PsfToOtf, however, so that we can keep all the
%    fftshift and ifftshift information consistent across routines. See
%    also OtfToPsf.
%
%    The Zernike polynomials form an orthogonal basis set over a unit disk.
%    They are useful because they can isolate aberrations into separate
%    components, each of which is given a weight and has potential for
%    being corrected. For example, rather than seeing an entire aberrated
%    wavefront, we can instead look at the amount of astigmatism in the 45
%    degree direction and how it contributes to the PSF on its own by
%    knowing the measured Zernike coefficient associated with it.
%
%    The tutorial:
%       - Introduces the concept of Zernike polynomials
%       - Shows pupil function & how it is formed using Zernkie polynomials
%       - Shows associated point-spread functions for given pupil functions
%       - Demonstrates and explains longitudinal chromatic aberration
%       - Demonstrates and explains Stiles-Crawford effect
%       - Looks at measured human data and shows how eyeglasses only allow
%         us to correct certain wavefront aberrations.
%
%    The fact that for an aberrated eye, the best optical quality does not
%    occur when nominal defocus wl matches the calculated wavelength is not
%    considered here, but can be quite important when thinking about real
%    optical quality. An interesting extension of this tutorial would be to
%    use a figure of merit for the optical quality (e.g., the Strehl
%    ratio) and show how it varies as a function of defocus.
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
% References:
%   http://white.stanford.edu/teach/index.php/Wavefront_optics_toolbox
%   http://www.traceytechnologies.com/resources_wf101.htm
%
% See Also:
%    OtfToPsf, wvfOSAIndexToVectorIndex
%

% History:
%    xx/xx/11       (c) Wavefront Toolbox Team 2011, 2012
%    03/12/12  baw, mdl, kp  Created.
%    04/29/12  dhb  Tried to tighten vertical spacing and apply uniform
%                   convention. Some editing of text for clarity.
%    10/30/17  jnm  Comments & formatting
%    11/08/17  jnm  Second commenting pass, cleaning up and enforcing
%                   general commenting conventions	
%    01/01/18  dhb  Handled notes.

%% Zernike polynomials
% Zernike polynomials consist of:
%   -a weighting coefficient (Zernike coeff),
%   -a normalization factor,
%   -a radially-dependent polynomial,
%   -an azimuthally-dependent sinusoid
%
% For example, one such polynomial (known as Astigmatism along 45 degrees)
% is given by:
%
%          Z3 * sqrt(6) * rho^2 * cos(2 * theta)
%
% Where rho and theta are natural polar coordinates representing radial
% norm and angle on a disk. These can be easily converted to rectangular
% coordinates, making the Zernike polynomial representation useful for
% computing the wavefront aberrations.
%
% Zernike polynomials can be expressed using two indices, one representing
% the highest order of the radial polynomial term (n), and the other
% representing the frequency of the azimuthal sinusoid (m). (See wiki for
% more details.)
%
% The polynomials can also be represented in a single-indexing scheme (j)
% using OSA standards, which is easier to manage in vector form for Matlab,
% so we will use it here.
%
% Each radial order has (order + 1) number of polynomial terms (and
% therefore, order+1 number of Zernike coefficients to represent them).
% Thus, 0th order has 1 term, 1st order has 2 terms, etc.
%
% In this tutorial we will be working with up to 10 orders of Zernike
% polynomials. Counted out, this represents 1 + 2 + 3 + ... + 11 = 66 terms
% for radial orders 0 through 10. The 0th order term (piston) doesn't
% affect the PSF and we will leave it at 0. Additionally, the 1st order
% terms (coeffs 1 and 2, known as tip and tilt) only serve to shift the PSF
% along the x or y axis. They will also be left at 0 for this tutorial.

%% Initialize
close all;
ieInit;
maxMM = 2;
maxUM = 20;
pupilfuncrangeMM = 5;

%% Use Zernike polynomials to specify a diffraction limited PSF.
% Use wvfCreate to create a wavefront variable to explore with.
%
% This wavefront by default has the 0's for all zernike coeffs. Notice that
% the calcpupilMM is by default 3, meaning we are simulating the wavefront
% PSF for a pupil of 3MM diameter. This code dumps out the structure so you
% can get a sense of what is in it.
%
% The validation script v_wvfDiffractionPSF compares the diffraction
% limited PSFs obtained in this manner with those obtained by computing an
% Airy disk and shows that they match.
wvf0 = wvfCreate;
wvfPrint(wvf0);

% Look at the plot of the normalized PSF within 1 mm of the center.
% Variable maxUM is used to specify size of plot from center of the PSF.
%
% The plot shows an airy disk computed from the Zernike polynomials; that
% is representing the diffraction-limited PSF obtained when the Zernike
% coefficients are all zero.
wvf0 = wvfComputePSF(wvf0);
wList = wvfGet(wvf0, 'calc wave');
wvfPlot(wvf0, '2dpsfspacenormalized', 'um', wList, maxUM);

%% Examine how the first non-zero Zernike coefficient contributes to PSF.
% The j = 3 coefficient (4th entry in the Zernike vector is known as
% oblique astigmatism (with axis at 45 degrees.)
%
% We start with the default structure , wvf0 created above, which has its
% vector of zcoeffs set to 66 zeros. Then we use wvfSet to poke in some
% non-zero oblique astigmatism.
%
% Note that for low order coefficents with names, we wvfSet understands the
% names. See wvfOSAIndexToVectorIndex for a list of available names.
%
% We could also just specify 3 to the set function, as that is the
% corresponding OSA index. This direct usage is illustrated by the wvfGet
% call, and the same usage works for the wvfSet. (You can also get via
% names for the low order terms.)
oblique_astig = 0.75;
wvf3 = wvfSet(wvf0, 'zcoeffs', oblique_astig, {'oblique_astigmatism'});
fprintf('Third Zernike coefficient is %g\n', wvfGet(wvf3, 'zcoeffs', 3));

% Look at the pupil function:
% We have used wvfComputePupilFunction separately here, but it is actually
% also contained within wvfComputePSF, which we will use from now on.
%
% We can see that the phase changes seem to be aligned with the + and - 45
% degree axes, which makes sense for oblique astigmatism.
wvf3 = wvfComputePupilFunction(wvf3);
wvfPlot(wvf3, '2dpupilphasespace', 'mm', wList, pupilfuncrangeMM);

%% Plot the PSF
% While the pupil functions are well specified by Zernike polynomials, it's
% hard to get meaning from them. We'd much prefer to look at the PSF, which
% gives us an idea of how the pupil will blur an image. This is essentially
% done by applying a Fourier Transform to the pupil function.
wvf3 = wvfComputePSF(wvf3);

% Now we can plot the normalized PSF for a pupil only whose only aberration
% is the 45 degree astigmatism.
%
% As you can see, this no longer looks like the narrower diffraction-
% limited PSF. It has also lost its radial symmetry. We will see that the
% higher the order of Zernike polynomial, the more complex the associated
% PSF will be.
wvfPlot(wvf3, '2dpsfspacenormalized', 'um', wList, maxUM);

%% Examine effect of the j = 5 (6th entry), which is called vertical
% astigmatism, along the 0 or 90 degree axis. Again we begin with the wvf0,
% which has a vector of zero zcoeffs in it by default.
%
% We can see that unlike the 3rd coefficient, this coefficient for
% astigmatism is aligned to the x and y axes.
vertical_astig = 0.75;
wvf5 = wvfSet(wvf0, 'zcoeffs', vertical_astig, {'vertical_astigmatism'});
wvf5 = wvfComputePSF(wvf5);
wvfPlot(wvf5, '2dpupilphasespace', 'mm', wList, maxMM);
wvfPlot(wvf5, '2dpsfspacenormalized', 'um', wList, maxUM);

%% Make plots of various pupil functions and their respective
% point-spread functions for different Zernike polynomials of 1st through
% 3rd radial orders (OSA j indices 1 through 9).
%
% Each time through the loop we see the effect of wiggling one coefficient.
%
% In this loop, we plot the wavefront aberrations (measured in microns),
% in addition to the pupil function phase (radians), and the PSF.
%
% The wavefront aberration plots we get match those
%   http://www.traceytechnologies.com/resources_wf101.htm
% except for the fact that their green is postive and our red is positive.
% Note that there is considerable disagreement about the Zernikes in the
% pictures on the web. See comment in v_wvfZernikePolynomials for a more
% expansive discussion.
wvf0 = wvfCreate;
wvf0 = wvfSet(wvf0, 'calculated pupil', ...
    wvfGet(wvf0, 'measured pupil', 'mm'));
pupilfuncrangeMM = 4;
jindices = 1:9;
maxMM = 4;
for ii = jindices
    vcNewGraphWin;
    insertCoeff = 0.75;
    wvf = wvfSet(wvf0, 'zcoeffs', insertCoeff, ii);
    wvf = wvfComputePSF(wvf);
    [n, m] = wvfOSAIndexToZernikeNM(ii);

    subplot(3, 1, 1);
    wvfPlot(wvf, '2dwavefrontaberrationsspace', 'mm', [], ...
        pupilfuncrangeMM, 'no window');
    title(sprintf('Wavefront aberrations for j = %d (n = %d, m = %d)', ...
        ii, n, m));

    subplot(3, 1, 2);
    wvfPlot(wvf, '2dpupilphasespace', 'mm', wList, pupilfuncrangeMM, ...
        'no window');
    title(sprintf('Pupil function phase for j = %d (n = %d, m = %d)', ...
        ii, n, m));

    subplot(3, 1, 3);
    wvfPlot(wvf, '2dpsfspace', 'mm', wList, maxMM, 'no window');
end

%% How longitudinal chromatic aberration (LCA) affects the PSF / "Defocus"
% What happens if we want to know how the PSF looks for different
% wavelengths? You may have learned that optical systems can have chromatic
% aberration, where one wavelength is brought into focus but others may be
% blurry because they are refracted closer or farther from the imaging
% plane. In this case, the PSF is dependent on wavelength.
%
% We can set this using the  "in-focus wavelength" of our wvf. This code
% indicates that the data is given for a nominal focus of 550 nm, which is
% also the default in wvfCreate. We also now explictly set the wavelength
% for which the PSF is calculated to 550 nm (this is also the default.
wvf0 = wvfCreate;
wvf0 = wvfSet(wvf0, 'measured wavelength', 550);
wvf0 = wvfSet(wvf0, 'calc wavelengths', 550);

% It turns out that all aberrations other than "Defocus" are known to vary
% only slightly with wavelength. As a result, the Zernike coefficients
% don't have to be modified, apart from one. This is the j = 0 "defocus"
% coefficient. It is what typical eyeglasses correct for using + or -
% diopters lenses. The wavefront toolbox combines the longitudinal
% chromatic aberration (LCA) into this coefficient when it calculates the
% pupil function. The LCA itself is computed based on the difference
% between the measurement wavelength (for which the defocus coefficient is
% specified) and the wavelength being calclated for.
wvf0 = wvfComputePSF(wvf0);
wList = wvfGet(wvf0, 'calc wavelengths');
vcNewGraphWin;
maxMM = 3;
wvfPlot(wvf0, '1dpsfspacenormalized', 'mm', wList, maxMM, 'no window');
hold on;

% Change the calculated wavelength to 600.
% The new psf is wider due to the longitudinal chromatic aberration, even
% though it's still just the diffraction-limited wavefront function (the
% Zernike coefficients are still 0).
theWavelength = 600;
wvf1 = wvfCreate;
wvf1 = wvfSet(wvf1, 'calc wavelengths', theWavelength);
wList = wvfGet(wvf1, 'calc wavelengths');
wvf1 = wvfComputePSF(wvf1);
wvfPlot(wvf1, '1dpsfspacenormalized', 'mm', wList, maxMM, 'no window');

% To unpack this, we can do explicitly what is done inside the pupil
% function calculation. First we get LCA from the wavelength difference,
% then act as if the measured wavelength (where there is no LCA) is the
% calculated wavelength. We do this by changing the measured wavelength
% specification. Finally, we add in the LCA to the current defocus
% coefficient.
wvf2 = wvf1;
lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf2, ...
    'measured wavelength', 'nm'), wvfGet(wvf2, 'calc wavelengths', 'nm'));
lcaMicrons = wvfDefocusDioptersToMicrons(-lcaDiopters, ...
    wvfGet(wvf2, 'measured pupil size'));
wvf2 = wvfSet(wvf2, 'measured wavelength', ...
    wvfGet(wvf2, 'calc wavelengths', 'nm'));
wList = wvfGet(wvf2, 'calc wavelengths');
defocus = wvfGet(wvf2, 'zcoeffs', {'defocus'});
defocus = defocus + lcaMicrons;
wvf2 = wvfSet(wvf2, 'zcoeffs', defocus, {'defocus'});
wvf2 = wvfComputePSF(wvf2);
[~, pData] = wvfPlot(wvf2, '1dpsfspacenormalized', 'mm', wList, ...
    maxMM, 'no window');
set(pData, 'color', 'b', 'linewidth', 2);

%% How cone geometry affects the PSF: the Stiles-Crawford effect (SCE)
% The cones that line our retinas are tall rod-shaped cells. They act like
% waveguides, such that rays parallel to their long axis excite the
% photoreceptors more readily than rays that are travelling at skewed
% angles. This has the benefit of reducing the chance that scattered or
% aberrated rays will excite the cone cells. Although this effect
% physically comes from the retina, it can be modeled using the pupil
% function discussed above. The amplitude of the pupil function is altered,
% such that it decays in the form exp(-alpha *((x - x0)^2 + (y - y0)^2)).
% This physically attenuates rays that enter near the edges of the pupil
% and lens. Since the phase aberration at the edges of the pupil is usually
% most severe, SCE can actually improve vision. Note that generally the
% position of the pupil with highest transmission efficiency does not lie
% in the exact center of the pupil (x0, y0 are nonzero).

% Begin with an unaberrated pupil and see what its amplitude and phase look
% like. We'll also plot the associated diffraction-limited PSF.
wvf0 = wvfCreate;
wvf0 = wvfComputePSF(wvf0);
maxMM = 2; %MM from the center of the PSF
pupilfuncrangeMM = 5;
vcNewGraphWin;
subplot(2, 2, 1);
wvfPlot(wvf0, '2dpupilamplitudespace', 'mm', [], pupilfuncrangeMM, ...
    'no window');
subplot(2, 2, 2);
wvfPlot(wvf0, '2dpupilphasespace', 'mm', [], pupilfuncrangeMM, ...
    'no window');
subplot(2, 2, 3:4);
wvfPlot(wvf0, '2dpsfspace', 'mm', [], maxMM, 'no window');
sce1DFig = vcNewGraphWin;
hold on
wvfPlot(wvf0, '1dpsfspace', 'mm', [], maxMM, 'no window');

% To this unaberrated pupil function, we add the Stiles-Crawford
% parameters, with peakedness taken from Berendschot et al. 2001 (see
% sceCreate for details). This adds a decaying exponential amplitude to the
% pupil function, causing less light to be transmitted to the retina.
%
% Compare the diffraction-limited PSF without SCE to the one with SCE. What
% are the differences? Is the amplitude different? Why? Is the width of the
% PSF different? Why?
wvf0SCE = wvfSet(wvf0, 'sceParams', ...
    sceCreate(wvfGet(wvf0, 'calc wave'), 'berendschot_data'));
wvf0SCE = wvfComputePSF(wvf0SCE);
vcNewGraphWin;
subplot(2, 2, 1);
wvfPlot(wvf0SCE, '2dpupilamplitudespace', 'mm', [], ...
    pupilfuncrangeMM, 'no window');
subplot(2, 2, 2);
wvfPlot(wvf0SCE, '2dpupilphasespace', 'mm', [], pupilfuncrangeMM, ...
'no window');
subplot(2, 2, 3:4);
wvfPlot(wvf0SCE, '2dpsfspace', 'mm', [], maxMM, 'no window');
figure(sce1DFig);
[~, pData] = wvfPlot(wvf0SCE, '1dpsfspace', 'mm', [], maxMM, ...
    'no window');
set(pData, 'color', 'b', 'linewidth', 1);

% Compare the above with how the SCE affects an aberrated PSF. Let's create
% a PSF with moderate astigmatism along the xy axes.
wvf5 = wvfSet(wvf0, 'zcoeffs', 0.75, {'vertical_astigmatism'});
wvf5 = wvfComputePSF(wvf5);
vcNewGraphWin;
subplot(2, 2, 1);
wvfPlot(wvf5, '2dpupilamplitudespace', 'mm', [], pupilfuncrangeMM, ...
    'no window');
subplot(2, 2, 2);
wvfPlot(wvf5, '2dpupilphasespace', 'mm', [], pupilfuncrangeMM, ...
    'no window');
subplot(2, 2, 3:4);
wvfPlot(wvf5, '2dpsfspace', 'mm', [], maxMM, 'no window');
sce1DFig2 = vcNewGraphWin;
hold on
wvfPlot(wvf5, '1dpsfspace', 'mm', [], maxMM, 'no window');

% Add SCE to the aberrated pupil function.
% Compare the two aberrated PSFs. How do their peak amplitudes compare?
% How do their widths compare? How did the symmetry of the PSF change?
% Which PSF would create a "better image" on the retina?
wvf5SCE = wvfSet(wvf5, 'sceParams', sceCreate(wvfGet(wvf5, ...
    'calc wave'), 'berendschot_data'));
wvf5SCE = wvfComputePSF(wvf5SCE);
vcNewGraphWin;
subplot(2, 2, 1);
wvfPlot(wvf5SCE, '2dpupilamplitudespace', 'mm', [], ...
    pupilfuncrangeMM, 'no window');
subplot(2, 2, 2);
wvfPlot(wvf5SCE, '2dpupilphasespace', 'mm', [], pupilfuncrangeMM, ...
    'no window');
subplot(2, 2, 3:4);
wvfPlot(wvf5SCE, '2dpsfspace', 'mm', [], maxMM, 'no window');
figure(sce1DFig2);
[~, pData] = wvfPlot(wvf5SCE, '1dpsfspace', 'mm', [], maxMM, ...
    'no window');
set(pData, 'color', 'b', 'linewidth', 1);

%% Wavefront measurements of human eyes and the effects of single-vision
% corrective eyeglasses:
% We have access to measurements of the pupil function of real human eyes.
% The optics of these eyes are not perfect, so they have interesting pupil
% functions and PSF shapes.

% Set up the wvf structure
measMM = 6;
calcMM = 3;
maxMM = 3;
theWavelengthNM = 550;
wvfHuman0 = wvfCreate('measured pupil', measMM, ...
    'calc pupil size', calcMM);
wvfHuman0 = wvfSet(wvfHuman0, 'wavelength', theWavelengthNM);

% Load in some measured data
sDataFile = fullfile(wvfRootPath, 'data', 'sampleZernikeCoeffs.txt');
theZernikeCoeffs = importdata(sDataFile);
whichSubjects = [3 7];
theZernikeCoeffs = theZernikeCoeffs(:, whichSubjects);
nSubjects = size(theZernikeCoeffs, 2);

% Stiles Crawford
wvfHuman0 = wvfSet(wvfHuman0, 'sceParams', ...
    sceCreate(wvfGet(wvfHuman0, 'calc wave'), 'berendschot_data'));

% Plot subject PSFs, one by one
for ii = 1:nSubjects
    fprintf('** Subject %d\n', whichSubjects(ii))

    wvfHuman = wvfSet(wvfHuman0, 'zcoeffs', theZernikeCoeffs(:, ii));
    wvfHuman = wvfComputePSF(wvfHuman);

    vcNewGraphWin;
    subplot(2, 2, 1);
    wvfPlot(wvfHuman, '2dpupilamplitudespace', 'mm', [], calcMM, ...
        'no window');
    subplot(2, 2, 2);
    wvfPlot(wvfHuman, '2dpupilphasespace', 'mm', [], calcMM, ...
        'no window');
    subplot(2, 2, 3:4);
    wvfPlot(wvfHuman, '2dpsfspace', 'mm', [], maxMM, 'no window');
end

%% Single-vision eyewear generally corrects only the lowest-order
% Zernike aberrations (defocus given in diopters) and astigmatism (cylinder
% correction also given in diopters). The Zernike coefficients give us an
% easy and convenient way to simulate corrective lenses; we can simply set
% those Zernike coefficients to zero and see what the PSFs look like!
%
% Plot their corrected PSFs, one by one, How do the corrected PSFs compare
% to the uncorrected ones? their peaks? their widths?
%
% Try changing the whichSubjects array above to look at other sample data.
% Do eyeglasses help correct the aberrations in those subjects?
%
% If you were to spend thousands of dollars on laser eye surgery, would you
% want them to only correct the first order of wavefront aberrations, like
% eyeglasses, or do a full wavefront measurement?
%
% Suppose you knew that such surgery would correct some of the lower order
% aberrations but some of the higher order aberrations worse. How would you
% compute the net effect of something like that?
for ii = 1:nSubjects
    fprintf('** Subject %d corrected\n', whichSubjects(ii))

    % Correct defocus and astigmatism
    zCoeffs = theZernikeCoeffs(:, ii);
    zCoeffs(4:6) = 0;
    wvfHuman = wvfSet(wvfHuman0, 'zcoeffs', zCoeffs);
    wvfHuman = wvfComputePSF(wvfHuman);

    vcNewGraphWin;
    subplot(2, 2, 1);
    wvfPlot(wvfHuman, '2dpupilamplitudespace', 'mm', [], calcMM, ...
        'no window');
    subplot(2, 2, 2);
    wvfPlot(wvfHuman, '2dpupilphasespace', 'mm', [], calcMM, ...
        'no window');
    subplot(2, 2, 3:4);
    wvfPlot(wvfHuman, '2dpsfspace', 'mm', [], maxMM, 'no window');
end
%% End
