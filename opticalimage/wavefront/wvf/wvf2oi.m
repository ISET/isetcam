function oi = wvf2oi(wvf)
% Convert wavefront data to ISET optical image data strcuture
%
% Syntax:
%    oi = wvf2oi(wvf)
%
% Description:
%  The wvf structure is used to create a shift-invariant ISET optics
%  model.  The wvf structure is attached to the optical image
%  structure. Some of the key parameters from the wvf structure are
%  copied into the optics structure, for consistency.
%
% Input
%   wvf:      A wavefront parameters structure with a PSF
%
% Copyright Wavefront Toolbox Team 2012
%
% See also: oiCreate

% TODO
%   We need to worry about consistency between the wvf and optics
%   parameters.

% Example:
%{
 wvf = wvfCreate;
 wvf = wvfComputePSF(wvf);
 oi = wvf2oi(wvf);
 scene = sceneCreate;
 oi = oiCompute(oi,scene);
 ieAddObject(oi); oiWindow;
%}
%{
 oi = oiCreate('wvf');
 scene = sceneCreate;
 oi = oiCompute(oi,scene);
 ieAddObject(oi); oiWindow;
%}

%% Get the key parameters from the wvf structure

wave = wvfGet(wvf,'wave');

% First we figure out the frequency support.
fMax = 0;
for ww=1:length(wave)
    f = wvfGet(wvf,'otf support','mm',wave(ww));
    if max(f(:)) > fMax
        fMax = max(f(:)); maxWave = wave(ww);
    end
end

% Make the frequency support in ISET as the same number of samples with the
% wavelength with the highest frequency support from WVF.
fx = wvfGet(wvf,'otf support','mm',maxWave);
fy = fx;
[X,Y] = meshgrid(fx,fy);
c0 = find(X(1,:) == 0); r0 = find(Y(:,1) == 0);

%% Second, we set up the OTF variable for use in the ISET representation
nWave = length(wave); nSamps = length(fx);
otf = zeros(nSamps,nSamps,nWave);

% Interpolate the WVF OTF data into the ISET OTF data for each wavelength.
for ww=1:length(wave)
    f = wvfGet(wvf,'otf support','mm',wave(ww));
    thisOTF = wvfGet(wvf,'otf',wave(ww));
    est = interp2(f,f',thisOTF,X,Y,'cubic',0);
    
    % It is tragic that fftshift does not shift so that the DC term is in
    % (1,1). Rather, fftshift puts the DC at the the highest position.
    % So, we don't use this
    %
    %   otf(:,:,ww) = fftshift(otf(:,:,ww));
    %
    % Rather, we use circshift.  This is also the process followed in the
    % psf2otf and otf2psf functions in the image processing toolbox.  Makes
    % me think that Mathworks had the same issue.  Very annoying. (BW)
    
    % We identified the (r,c) that represent frequencies of 0 (i.e., DC).
    % We circularly shift so that that (r,c) is at the (1,1) position.
    otf(:,:,ww) = circshift(est,-1*[r0-1,c0-1]);
    
end

% I sure wish this was real all the time. Sometimes (often?) it is.
%  psf = otf2psf(otf(:,:,ww));
%  if ~isreal(psf), disp('psf not real'); end
%  vcNewGraphWin; mesh(psf)

%% Place the frequency support and OTF data into an ISET structure.

% Build template
oi = oiCreate('shift invariant');

% Copy the optics parameters to the main optics structure for
% consistency.  A little worrisome how to keep these in sync in
% general.
oi = oiSet(oi,'optics OTF fx', fx);
oi = oiSet(oi,'optics OTF fy', fy);
oi = oiSet(oi,'optics otfdata', otf);
oi = oiSet(oi,'optics OTF wave',wave);
oi = oiSet(oi,'optics fNumber',wvfGet(wvf,'fnumber'));
oi = oiSet(oi,'optics focal length',wvfGet(wvf,'focal length','m'));

% Z = wvfGet(wvf,'zcoeffs');
oi = oiSet(oi,'wvf',wvf);

end


