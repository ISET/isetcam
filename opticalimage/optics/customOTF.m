function [OTF2D, fSupport] = customOTF(oi,fSupport,wavelength,units)
%Interpolate optics OTF for shift-invariant calculation in optical image
% 
%  [OTF2D,fSupport] = customOTF(oi,[fSupport],[wavelength = :],[units='mm'])
%
% In the shift-invariant optics model, custom data are stored in the
% optics.OTF slot.  This routine reads the otf data and interpolates them
% to the fSupport and wavelength of the optical image or optics structure.
%
% The returned OTF is normalized so that all energy is transmitted (i.e.,
% the DC value is 1).  This is done by normalizing the peak value to one.
% If we ever have a case when the peak is other than the DC, we have a
% problem with energy conservation - where did the photons go?
%
% The units for the frequency support are cycles/millimeters.  
% Perhaps we should add a 'units' input argument here. 
% 
% Examples:
%
% See also: oiCalculateOTF, dlCore.m
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'),         error('Optical image required.'); end
if ieNotDefined('wavelength'), wavelength = oiGet(oi,'wavelength'); end

% In the custom case, I think the units should always be millimeters.
if ieNotDefined('units'),      units = 'mm'; end  

% These numbers appear a little off when the scene size is odd.
% 
if ieNotDefined('fSupport'),   fSupport = oiGet(oi,'fSupport',units); end

fx    = fSupport(:,:,1); fy = fSupport(:,:,2);
nX    = size(fx,2);      nY = size(fy,1);
nWave = length(wavelength);

optics     = oiGet(oi,'optics');

% This is the representation of the OTF
% The units should be specified and optional; we are using mm for
% now.  We can run into trouble if the values of fx or fy exceed those in X
% and Y.  This produces NaNs in the interpolated OTF2D, below.  We could
% check conditions on these variables:
%   max(abs(X(:))), max(abs(fx(:)))
%   max(abs(fy(:))), max(abs(Y(:)))
% I would like to replace the opticsGet here with an oiGet call with
% frequencySupport.  There are some inconsistencies that I don't understand
% and we have to clarify.
% BW, 2010 May
otfSupport = opticsGet(optics,'otfSupport');  
[X,Y]      = meshgrid(otfSupport.fy,otfSupport.fx);

% Find the OTF at each wavelength. We may be interpolating from the custom
% data.
if length(wavelength) == 1
    % Should we be interpolating here?
    OTF2D = opticsGet(optics,'otfData',wavelength);
    % figure(1); mesh(X,Y,OTF2D); 
    % figure(1); mesh(X,Y,abs(OTF2D))
    
    % See s_FFTinMatlab to understand the logic of the operations here.
    %
    % We interpolate the stored OTF2D onto the support grid for the
    % optical image. 
    % The OTF2D representation is on a frequency representation where DC is
    % in (1,1), so we would want the fSupport to run from 1:N.  
    % The fSupport that comes here, however, has the OTF2D from -N:N.  
    % To make things match up, we apply an fftshift to the OTF2D data prior to
    % interpolating.
    %    foo    = interp2(X, Y, fftshift(OTF2D), fx, fy, '*linear');
    %    figure(1); mesh(fx,fy,foo);
    %    OTF2D = fftshift(foo);
    %    figure(1); mesh(fx,fy,OTF2D); OTF2D(1,1)
    %    max(OTF2D(:))
    %
    % We have an error in the interpolation in some cases.
    % The interpolated OTF2D does not have a unit DC term because there is
    % a shift in position.  This happens rarely, but it happened in the
    % case of the filtered font.  We are tracking this down.  Odd and even
    % scene size is an issue.
    % Changed to ifftshift from fftshift on June 19,2011, as per AL
    OTF2D    = ifftshift(interp2(X, Y, fftshift(OTF2D), fx, fy, '*linear',0));

else
    disp('Warning:  unverified customOTF using multiple wavelengths')
    OTF2D = zeros(nY,nX,nWave);
    for ii=1:length(wavelength)
        tmp = opticsGet(optics,'otfData',wavelength(ii));
        OTF2D(:,:,ii) = ...
            fftshift(interp2(X, Y, fftshift(tmp), fx, fy, '*linear',0));

    end
end

return;
