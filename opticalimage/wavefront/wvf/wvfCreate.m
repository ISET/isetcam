function wvf = wvfCreate(varargin)
% Create the wavefront parameters structure.
%
%      wvf = wvfCreate([parameter],[value])
%
% Default:   a diffraction limited PSF for a 3 mm pupil.
% varargin:  Parsed as (param, val) pairs
%   
% See also:  wvfSet, wvfGet, sceCreate, sceGet
%
% The list of settable parameters is in wvfSet.
%
% Examples:
%    wvf = wvfCreate('wave',[400:10:700],'pupil diameter',5);
%
% Adapted from wavefront toolbox with DHB
% Modified heavily for use in ISET, 2015
% Still various things to check/fix.  See comments below.

%% Book-keeping
wvf = [];
wvf = wvfSet(wvf,'name','default');
wvf = wvfSet(wvf,'type','wvf');

%% Zernike coefficient set up for diffraction limited case.

% Maybe this should be 
zcoeffs = zeros(1,15);
wvf = wvfSet(wvf,'zcoeffs',zcoeffs);

%% Spatial sampling parameters

% I think this means the calculations are based on the wavefront at the
% pupil, separated from the image plane.  Consequently the frequency
% representation at the image plane is wavelength dependent.
wvf = wvfSet(wvf,'sample interval domain','pupil');  

% This was the alternative domain.  All this has me worried (BW).
% wvf = wvfSet(wvf,'sample interval domain','psf');  % Original default.

wvf = wvfSet(wvf,'spatial samples',201);             % I wonder what happens if we increase/decrease this?
wvf = wvfSet(wvf,'ref pupil plane size',16.2120);    % Original 16.212.  Not sure what this is.

%% Calculation parameters
wvf = wvfSet(wvf,'pupil size',3);   % Currently mm, but we should change to meters!
wvf = wvfSet(wvf,'wavelengths',400:10:700);

%% Handle any additional arguments via wvfSet
if ~isempty(varargin)
    if isodd(length(varargin))
        error('Arguments must be (pair, val) pairs');
    end
    for ii=1:2:(length(varargin)-1)
        wvf = wvfSet(wvf,varargin{ii},varargin{ii+1});
    end
end

end
