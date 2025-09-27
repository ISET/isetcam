function XYZ = ieXYZFromEnergy(energy,wave)
% CIE XYZ values from spectral radiance (watts/nm/sr/m2) or irradiance (watts/nm/m2)
%
%    XYZ = ieXYZFromEnergy(energy,wave)
%
% Calculate the XYZ values of the spectral radiance or irradiance functions
% in the variable ENERGY.  The input format of energy can be either XW
% (space-wavelength) or RGB. The wavelength samples of energy are stored in
% the variable WAVE.
%
% Notice, that XW is AN UNUSUAL FORMAT for energy.  Often, we put the SPDs
% into the columns of the matrix.  But in the XW format, the SPDs are in
% the rows. Sorry.
%
% The returned values, XYZ, are X,Y,Z in the columns of the matrix. Each
% row of energy has a corresponding XYZ value in the corresponding row of
% XYZ. This is what we call XW format.
%
%    * We return in RGB format if it is sent in that way.
%    * If the input is monochromatic we assume a 10 nm bandwidth (see
%    line 77.  We no longer warn about this.)
%    * The units of Y are candelas/meter-squared if energy is radiance
%    and lux if energy is irradiance.
%
% See also: 
%    ieXYZFromPhotons, imageSPD
%

% Examples:
%{
% energy is in XW format here
wave = 400:10:700;
tmp = load('CRT-Dell'); dsp = tmp.d;
energy = displayGet(dsp,'spd',wave);
energy = energy';
size(energy)
displayXYZ = ieXYZFromEnergy(energy,wave)
%}
%{
% The energy is in RGB format here
patchSize = 1;
macbethChart = sceneCreate('macbeth',patchSize);
p = sceneGet(macbethChart,'photons'); 
wave = sceneGet(macbethChart,'wave'); 
energy = Quanta2Energy(wave,p);
size(energy)
XYZ = ieXYZFromEnergy(energy,wave)
%}


% Force data into XW format.
if ndims(energy) == 3
    if length(wave) ~= size(energy,3)
        error('Bad format for input variable energy.');
    end
end

% Returning in RGB format is new.  I tested it in the scielab branch with
% v_ISET and some other calls.  But it might cause something to break
% somewhere.  Stay alert!
iFormat = vcGetImageFormat(energy,wave);
switch iFormat
    case 'RGB'
        % [rows,cols,w] = size(data);
        [xwData,r,c] = RGB2XWFormat(energy);
        % disp('RGB return')
    otherwise
        % XW format
        xwData = energy;
end

% xwData = ieConvert2XW(energy,wave);
if size(xwData,2) ~= length(wave)
    error('Problem converting input variable energy into XW format.');
end

% IF we are OK to here, then the spectra of the energy points are in the
% rows of xwData.  We ready the XYZ color matching functions into the
% columns of S.
%
% Until July 31 2025, we printed out the 10 nm default bandwidth to
% alert the user to this assumption. Then it started annoying me.
% Maybe we should put it back. (BW).
S = ieReadSpectra('XYZ',wave);
if numel(wave) > 1,  dWave = wave(2) - wave(1);
else,                dWave = 10;   % disp('10 nm band assumed');
end

% The return value has three columns, [X,Y,Z].
XYZ = 683*(xwData*S) * dWave;

% If it was sent in RGB, return it in RGB
switch iFormat
    case 'RGB'
        XYZ = XW2RGBFormat(XYZ,r,c);
    otherwise
        % XW format
end

return;