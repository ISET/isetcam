function oi = wvf2oi(wvf,varargin)
% Convert wavefront data to ISETBIO optical image with optics
%
% Syntax:
%   oi = wvf2oi(wvf)
%
% Description:
%    Convert a wavefront structure into an optical image whose optics match
%    the data in wvf.
%
%    Before calling this function, compute the pupil function and PSF,
%    using wvfCompute.
%
%    Non-optics aspects of the oi structure are assigned default values.
%
% Inputs:
%    wvf - A wavefront parameters structure (with a computed PF and PSF)
%
% Outputs:
%    oi  - Optical image struct
%
% See also
%   s_wvfDiffraction
%
% Notes:
%  * BW:  The wvf2oi(wvf) function did not match the wvf and oi.  I spent a
%     bunch of time checking for the diffraction limited case on both the
%     wvf side and the oi side.  Still more to check (07.01.23). But
%     setting the umPerDeg is important (was not always done properly and
%     consistently with focal length. Also understanding the different
%     models (diffraction, humanmw, wvf human) will be important. See
%     s_wvfDiffraction.m
%  * [NOTE: DHB - There is an interpolation in the loop that computes the
%     otf wavelength by wavelength.  This appears to be there to handle the
%     possibility that the frequency support in the wvf structure could be
%     different for different wavelengths. Does that ever happen?  If we
%     check and it doesn't, I think we could save a little time by getting
%     rid of the interpolation.]
%  * [NOTE: DHB - NCP and I spent a lot of time last summer suffering
%     through the psf <-> otf calculations as part of the IBIOColorDetect
%     project, and the fftshift conventions.]
%  * [NOTE: DHB - There is a note that PSF might start real but that the
%     PSF implied by the OTF computed here might not be.  We should check
%     into that.  We don't want imaginary PSFs showing up in calculations.
%     Perhaps this is handled by the oi methods, in that perhaps they
%     enforce that the psf obtained from the otf is in fact real.]
%  * [NOTE: DHB - It might be worth checking that it is OK just to set the
%     wavelength on the OTF, even if the oi itself has different wavelength
%     sampling.]
%
% See Also:
%    oiCreate, opticsCreate, oiPlot
%

% History:
%	 xx/xx/12       Copyright Wavefront Toolbox Team 2012
%    11/13/17  jnm  Comments & formatting
%    01/01/18  dhb  Set name and oi wavelength from wvf.
%              dhb  Check for need to interpolate, skip if not.
%    01/11/18  jnm  Formatting update to match Wiki
%    04/14/21  dhb  Set fNumber to correspond to wvf calc pupil size.
%                   Previously this was the oi default of 3 mm pupil.

% Examples:
%{
    wvf = wvfCreate;
    wvf = wvfCompute(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}
%{
    wvf = wvfCreate('wave', [400 550 700]');
    wvf = wvfSet(wvf, 'zcoeff', 1, 'defocus');
	wvf = wvfCompute(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}

%% Set up parameters
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wvf',@isstruct);
p.addParameter('model','shiftinvariant',@(x)(ismember(x,{'shiftinvariant','humanmw','human','wvfhuman','humanwvf'})));
p.parse(wvf,varargin{:});
model = p.Results.model;

%% Collect up basic wvf parameters
wave    = wvfGet(wvf, 'calc wave');
fnumber = wvfGet(wvf,'fnumber');
flength = wvfGet(wvf,'flength','m');

%% First we figure out the frequency support.
fMax = 0;
for ww = 1:length(wave)
    f = wvfGet(wvf, 'otf support', 'mm', wave(ww));
    if max(f(:)) > fMax
       fMax = max(f(:));
       maxWave = wave(ww);
    end
end

% Copy the frequency support from the wvf struct into ISET.  We match the
% number of frequency samples and wavelength.
%
% The wvf otf representation has DC frequency at the center of the matrix.
% But ISETCam uses OTF with DC represented in the upper left corner (1,1).
% We manage the difference with fftshift calls.
%

% Set up the frequency parameters and the X,Y mesh grids.
fx = wvfGet(wvf, 'otf support', 'mm', maxWave);
fy = fx;
[X, Y] = meshgrid(fx, fy);

%% Set up the OTF variable

% Allocate space.
otf    = zeros(length(fx), length(fx), length(wave));

%% Interpolate the WVF OTF data into the ISET OTF data for each wavelength.
%
% The interpolation is here in case there is different frequency
% support in the wvf structure at different wavelengths.
for ww=1:length(wave)


    %{
    % Over the years, we have not seen this error.  It tests whether f=0
    % (DC) is in the position we expect.
    f = wvfGet(wvf, 'otf support', 'mm', wave(ww));
    if (f(floor(length(f) / 2) + 1) ~= 0)
        error(['wvf otf support does not have 0 sf in the '
            'expected location']);
    end
    %}
    
    % The OTF has DC in the center.
    thisOTF = wvfGet(wvf,'otf',wave(ww));
    % ieNewGraphWin; mesh(X,Y,abs(thisOTF));

    if (all(f == fx))
        % Straight assignment.  No interpolation.  This is the usual
        % path.
        est = thisOTF;
    else
        warning('Interpolating OTF from wvf to oi.')
        est = interp2(f, f', thisOTF, X, Y, 'cubic', 0);
    end
    
    % ISETCam and ISETBio have the OTF with (0, 0) sf at the upper left. At
    % this point, the data have (0,0) in the center.  Thus we use ifftshift
    % to the wvf centered format. Using fftshift() can invert this
    % reorganization of the data.
    otf(:, :, ww) = ifftshift(est);
end

%{
% Stored format
ieNewGraphWin; mesh(X,Y,abs(otf(:,:,ww)));
% This plots it centered.
ieNewGraphWin; mesh(X,Y,abs(ifftshift(otf(:,:,ww))));
%}

%% Set the frequency support and OTF data into the optics slot of the OI

% This code works for the shiftinvariant optics, replacing the default
% OTF.
% pupilSize = wvfGet(wvf,'calcpupilsize');
% zcoeffs   = wvfGet(wvf,'zcoeffs');

oi = oiCreate('empty');

optics = wvf2optics(wvf);
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi, 'name', wvfGet(wvf, 'name'));

% Copy the OTF parameters.
% oi = oiSet(oi, 'optics OTF fx', fx);
% oi = oiSet(oi, 'optics OTF fy', fy);
% oi = oiSet(oi, 'optics otfdata', otf);
% oi = oiSet(oi, 'optics OTF wave', wave);
% oi = oiSet(oi, 'wave', wave);

% 9/25/2023.  Adding the wvf to the oi.  This already happens in
% oiCreate('wvf');
%
% We decided against because when the oi itself is updated the wvf is
% not updated.  This leads to mismatches.
% oi = oiSet(oi, 'wvf', wvf);

end
