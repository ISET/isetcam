function optics = wvf2optics(wvf,varargin)
% Convert wavefront data to optics
%
% Syntax:
%   optics = wvf2optics(wvf,varargin)
%
% Description:
%    Convert a wavefront structure into an ISETCam optics struct whose
%    OTF, frequency data and other parameters match the wvf.
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
%    optics  - ISETCam Optics struct
%
% See also
%   s_wvfDiffraction
%
% Notes:
%
% See Also:
%    oiCreate, opticsCreate, oiPlot
%

% Examples:
%{
wvf = wvfCreate;
wvf = wvfCompute(wvf);
optics = wvf2optics(wvf);
%}

%% Set up parameters
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wvf',@isstruct);
p.parse(wvf,varargin{:});

%% First we figure out the frequency support.

wave    = wvfGet(wvf, 'calc wave');

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


%% Start building the optics struct

optics = opticsCreate('empty');

optics = opticsSet(optics, 'name', 'wvf');
optics = opticsSet(optics, 'model', 'shiftinvariant');

% Standard 1/4-inch sensor parameters
% sensorDiagonal = 0.004;
% FOV = 46;
% fLength = inv(tan(FOV / 180 * pi) / 2 / sensorDiagonal) / 2;

% Collect up basic wvf parameters
fnumber = wvfGet(wvf,'fnumber');
flength = wvfGet(wvf,'flength','m');

optics = opticsSet(optics, 'fnumber', fnumber);  
optics = opticsSet(optics, 'focalLength', flength);

% Copy the OTF parameters.
optics = opticsSet(optics,'OTF fx', fx);
optics = opticsSet(optics,'OTF fy', fy);
optics = opticsSet(optics,'otfdata', otf);
optics = opticsSet(optics,'OTF wave', wave);
optics = opticsSet(optics,'wave', wave);

% We are planning to compute the OTF for shiftinvariant and
% diffraction limited on the fly.  We will do that by storing the
% zcoeffs in the optics.  The pupil aperture can be calculated from
% the fnumber and focal length (aperture = fLength/fNumber)
optics = opticsSet(optics,'zcoeffs',wvfGet(wvf,'zcoeffs'));
optics = opticsSet(optics,'zcoeffs diameter',wvfGet(wvf,'measured pupil diameter'));

% ISETCam transmittance representation initialized as 1s.
optics.transmittance.wave = opticsGet(optics,'wave');
optics.transmittance.scale = ones(size(optics.transmittance.wave));

end
