function energy = Quanta2Energy(wavelength, photons)
%Convert quanta (photons) to energy (watts)
%
%  energy = Quanta2Energy(WAVELENGTH,PHOTONS)
%
% Convert PHOTONS represented at the sampled WAVELENGTH positions to
% energy (watts or joules).
%
% WAVELENGTH is a column vector describing the wavelength samples [nm]
% PHOTONS can be a matrix in either RGB or XW (space-wavelength) format.
% In the XW format each spatial position is in a row and the wavelength
% varies across columsn.  The output, ENERGY, [watts or Joules] is
% returned in  same format as input (RGB or XW).
%
% CAUTION: The input form differs from the Energy2Quanta() call, which has
% the energy spectra in the columns.
%
% Examples:
%   wave = 400:10:700;
%   p = blackbody(wave,3000:1000:8000,'photons');
%   tic, e = Quanta2Energy(wave,p'); toc
%   e = diag(1./e(:,11))*e;
%   figure; plot(wave,e')
%
%   p1 = blackbody(wave,5000,'photons');
%   e = Quanta2Energy(wave,p1);            % e is a row vector in XW format
%   p2 = Energy2Quanta(wave,transpose(e)); % Notice the TRANSPOSE
%   figure; plot(wave,p1,'ro',wave,p2,'k-')
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
%   We should regularize the calls to Energy2Quanta() and this routine,
%   probably by making the other routine take RGB or XW format as well.
%   Old legacy issues, sigh.

if isempty(photons), energy = []; return; end
wavelength = wavelength(:)'; % make wave as row vector

% Fundamental constants
h = vcConstants('h');		% Planck's constant [J sec]
c = vcConstants('c');		% speed of light [m/sec]

% Main routine handles RGB or XW formats
iFormat = vcGetImageFormat(photons, wavelength);

switch iFormat
    case 'RGB'
        [n,m,w] = size(photons);
        if w ~= length(wavelength)
            error('Quanta2Energy:  photons third dimension must be nWave');
        end
        photons = RGB2XWFormat(photons);
        % energy = (h*c/(1e-9))*(photons ./ repmat(wavelength,n*m,1) );
        energy = (h*c/1e-9) * bsxfun(@rdivide, photons, wavelength);
        energy = XW2RGBFormat(energy,n,m);
        
    case 'XW'
        % If photons is a vector, it must be a row
        if isvector(photons), photons = photons(:)'; end
        if size(photons, 2) ~= length(wavelength)
            error('Quanta2Energy: quanta must have length of nWave');
        end
        energy = (h*c/1e-9) * bsxfun(@rdivide, photons, wavelength);
    otherwise
        error('Unknown image format');
        
end

end