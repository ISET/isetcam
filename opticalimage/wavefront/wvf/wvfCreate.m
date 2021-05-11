function wvf = wvfCreate(varargin)
% Create the wavefront parameters structure.
%
% Syntax
%   wvf = wvfCreate([parameter],[value])
%
% Inputs
%  None
%
% Returns a wavelength structure
%  Default:   a diffraction limited PSF for a 3 mm pupil.
%  varargin:  Parsed as (param, val) pairs to call wvfSet()
%
% The list of settable parameters is in wvfSet.
%
% Examples:
%    wvf = wvfCreate('wave',[400:10:700],'pupil diameter',5, 'z pupil diameter ', 8);
%
% Wandell, Imageval LLC
%
% Adapted from wavefront toolbox with DHB
% Modified heavily for use in ISET, 2015
% See also
%    wvfGet, wvfSet, wvfComputePSF

%% Book-keeping
wvf = [];
wvf = wvfSet(wvf, 'name', 'default');
wvf = wvfSet(wvf, 'type', 'wvf');

%% Spatial sampling parameters

% I think this means the calculations are based on the wavefront at the
% pupil, separated from the image plane.  Consequently the frequency
% representation at the image plane is wavelength dependent.  This is the
% only case we run in ISETCam.  ISETBio permits an additional option.
wvf = wvfSet(wvf, 'sample interval domain', 'pupil');

% This was the alternative domain.  All this has me worried (BW).
% wvf = wvfSet(wvf,'sample interval domain','psf');  % Original default.

wvf = wvfSet(wvf, 'spatial samples', 201); % I wonder what happens if we increase/decrease this?
wvf = wvfSet(wvf, 'ref pupil plane size', 16.2120); % Original 16.212.  Not sure what this is.

%% Calculation parameters
wvf = wvfSet(wvf, 'pupil size', 3); % Currently mm, but we should change to meters!
wvf = wvfSet(wvf, 'wavelengths', 400:10:700);
wvf = wvfSet(wvf, 'focal length', 17e-3); % This is our estimate near fovea

%% Zernike coefficient set up for diffraction limited case.

% The polynomial coefficients were measured for a particular pupil diameter
% and a specific wavelength.  Those are stored here.  By default, we assume
% that the zcoeffs were measured on an 8 mm pupil diameter.  That's because
% human measurements are often like that.  But the reality could be quite
% different.
zcoeffs = zeros(1, 15);
wvf = wvfSet(wvf, 'zcoeffs', zcoeffs);
wvf = wvfSet(wvf, 'z pupil diameter', 8);

% We are not properly accounting for the difference between the assumed z
% coefficient measurement wavelength and the calculation.  We do this
% correctly in ISETBio where we know the defocus as a function of
% wavelength.  But in ISETCam we do not generally have this information for
% the lens.
wvf = wvfSet(wvf, 'z wavelength', 550);

%% Handle any additional arguments via wvfSet
if ~isempty(varargin)
    if isodd(length(varargin))
        error('Arguments must be (pair, val) pairs');
    end
    for ii = 1:2:(length(varargin) - 1)
        wvf = wvfSet(wvf, varargin{ii}, varargin{ii + 1});
    end
end

end
