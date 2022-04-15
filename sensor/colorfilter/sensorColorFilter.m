function [fData, wave] = sensorColorFilter(cfType, wave, varargin)
% Create color filters for use in a sensor
%
% Syntax:
%   [fData, wave] = sensorColorFilter(cfType, wave, varargin)
%
% Description:
%  Gateway routine for creating sensor color filter curves.  Useful
%  for making an array of Gaussian filters, or an IR cut filter, or an
%  UV cut filter.
%
% Required Inputs:
%  cfType:  One of:  Gaussian, irFilter, uvFilter
%  wave:    Wavelength samples
%
% Optional inputs
%  if Gaussian:   [cPos,  widths] - Center positions and widths in nm
%  if uv filter:  [uvCut, smooth] - Cut wavelength and smooth SD (nm)
%  if ir filter:  [irCut, smooth] - Cut wavelength and smooth SD (nm)
%
% Outputs:
%   fData - Filter data in columns. [nWave x nFilters]
%
% Copyright ImagEval Consultants, LLC, 2010
%
% See also:
%  oeSensorCreate

%
% Examples:
%{
% Gaussian type:
 cfType = 'gaussian';
 [fData,wave] = sensorColorFilter(cfType);
 vcNewGraphWin; plot(wave,fData)
%}
%{
 wave = [400:10:700]; cPos = [500,600]; width = [40,40];
 fData = sensorColorFilter(cfType,wave, cPos, width);
 vcNewGraphWin; plot(wave,fData);
%}
%{
  cfType = 'gaussian'; wave = [350:850];
  cPos = 450:20:750; width = ones(size(cPos))*15;
  fData = sensorColorFilter(cfType,wave, cPos, width);
  ieNewGraphWin; plot(wave,fData)
%}
%{
  cfType = 'ir filter'; wave = 400:800; irCut = 680; smooth = 5;
  f = sensorColorFilter(cfType,wave,irCut,smooth);
  vcNewGraphWin; plot(wave,f);
%}
%{
  cfType = 'uv Filter'; wave = 350:800; uvCut = 440; smooth = 20;
  f = sensorColorFilter(cfType,wave,uvCut,smooth);
  vcNewGraphWin; plot(wave,f);
%}

if ieNotDefined('cfType'), cfType = 'gaussian'; end
if notDefined('wave'),     wave = 400:700; end

smooth = -1;

cfType = ieParamFormat(cfType);

switch lower(cfType)
    case 'gaussian'
        % A set of gaussian filters centered at cPos (vector) and widths
        % (vector)
        
        if length(varargin)<1, cPos = [450,550,650];
        else, cPos = varargin{1}; end
        
        if length(varargin)<2, widths = ones(size(cPos))*40;
        else, widths = varargin{2}; end
        
        nFilters = length(cPos);
        fData = zeros(length(wave),nFilters);
        for ii=1:nFilters
            fData(:,ii) = exp(-1/2*( (wave-cPos(ii))/(widths(ii))).^2);
        end
        
    case 'irfilter'
        % Infrared blocking filter.
        if length(varargin) < 1, cPos = 700;
        else, cPos = varargin{1};
        end
        if length(varargin) > 1, smooth = varargin{2}; end
        
        fData = ones(size(wave));
        lst = (wave > cPos);
        fData(lst) = 0;
        
    case 'uvfilter'
        % Ultraviolet blocking filter.
        if length(varargin) < 1, cPos = 400;
        else, cPos = varargin{1};
        end
        if length(varargin) > 1, smooth = varargin{2}; end
        
        fData = ones(size(wave));
        lst = (wave < cPos);
        fData(lst) = 0;
        
    otherwise
        error('Unknown filter type %s\n',cfType)
end

if smooth > 0
    % Image processing toobox.
    fData = imgaussfilt(fData,smooth);
end