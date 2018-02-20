function [lineSpread,xDim,wave] = humanLSF(pupilRadius,dioptricPower,unit,wave)
% Calculate the human linespread function at a range of wavelengths
%
%   [lsf,xDim,wave] = humanLSF([pupilRadius=0.0015],[dioptricPower=59.9404],[unit='degree'],[wave=400:700]);
%
% The pupil radius is typically 0.5-3mm and specified in meters
% The dioptric power is around 1/0.017mm
% The returned units are either degrees (default), 'um' or 'mm'
% wave samples are typically 400:700 nm
%
% The human line spread function includes optical defocus and chromatic
% aberration. The spatial extent (and spatial frequency) range are
% determined by the spatial extent and sampling density of the original
% scene.
%
% See also:  humanOTF and discussion therein.
%
% Reference: 
%   Marimont & Wandell (1994 --  J. Opt. Soc. Amer. A,  v. 11, 
%   p. 3113-3122 -- see also Foundations of Vision by Wandell, 1995.
%
% Examples:
%  [lsf,xDim,wave]  = humanLSF; colormap(jet); mesh(xDim,wave,lsf);
%  xlabel('wave'); ylabel('mm')
%  [lsf,xDim,wave]  = humanLSF([],[],[],'mm'); colormap(jet); mesh(xDim,wave,lsf)
%
%  radius = 0.003/2;  % In meters
%  dioptricPower = 60;% In diopters (1/m)
%  unit = 'mm';
%  [lsf,xDim,wave]  = humanLSF([],radius,dioptricPower,'mm'); colormap(jet); mesh(xDim,wave,lsf)
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'),            oi = vcGetObject('OI'); end
if ieNotDefined('pupilRadius'),   p  = 0.0015;   else p = pupilRadius;   end   % Default pupil radius is 3mm 
if ieNotDefined('dioptricPower'), D0 = 59.9404;  else D0 = dioptricPower;end   % dioptric power of unaccomodated eye
if ieNotDefined('unit'), unit = 'mm';    end
if ieNotDefined('wave'), wave = 400:700; end  % Default wavelength sampes

% We could put in a higher spatial sample frequency and get a finer spatial
% sampling resolution.

% I may change the humanOTF return format to include the fftshift ... be
% aware that may break this code.  And I may forget to come back and clean
% this  -- BW, 12.06.2006
% The pupil size is used here ('p')
[combinedOTF,sampleSf,wave] = humanOTF(p,D0,[],wave);
% mesh(sampleSf(:,:,1),sampleSf(:,:,2),combinedOTF(:,:,15))

nWave = length(wave);
% Compute the linespread functions, under the assumption of symmetry.  We
% compute the line spread in the row direction.
nSamples   = size(combinedOTF,1);
lineSpread = zeros(nWave,nSamples);

for ii = 1:nWave
    tmp = squeeze(combinedOTF(:,:,ii));
    OTFcenterLine  = tmp(:,1);                     % plot(OTFcenterLine)
    thisLSF = fftshift(abs(ifft(OTFcenterLine)));  % plot(thisLSF)
    lineSpread(ii,:) = thisLSF; 
    % sum(thisLSF), max(OTFcenterLine)  % I don't understand why this
    % doesn't add up
end

% The max is the Nyquist frequency (deg/samp)
% There are two samples at the Nyquist frequency
deltaSpace       = 1/(2*max(sampleSf(:)));   
spatialExtentDeg = deltaSpace*size(lineSpread,2);
fList            = unitFrequencyList(nSamples);
xDim             = fList * spatialExtentDeg;

% 330 microns/deg
mmPerDeg = 0.330;
switch lower(unit)
    case 'mm'
        xDim = xDim*mmPerDeg;
    case 'um'
        xDim = xDim*mmPerDeg*10^3;
    otherwise
        error('Unknown unit %s',unit);
end

return;