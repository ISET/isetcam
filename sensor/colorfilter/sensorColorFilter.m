function [fData, wave] = sensorColorFilter(cfType,wave, varargin)
% Create color filters for use in a sensor
%
% Syntax:
%     [fData, wave] = sensorColorFilter(cfType, wave, varargin)
%
% Description:
%  Gateway routine for creating sensor color filter curves.
%
% Required Inputs:
%  cfType:  One of:  Gaussian, irFilter, uvFilter
%  wave:    Wavelength samples
%  
% Optional inputs
%  if Gaussian:   wave, cPos,  widths
%  if uv filter:  wave, uvCut, smooth
%  if ir filter:  wave, irCut, smooth
%
% Outputs:
%   fData - Matrix of filter data in columns.  nWave x nFilters
%
% Copyright ImagEval Consultants, LLC, 2010
%
% See also: 
%  

%  
% Examples:
%{
% Gaussian type:
 cfType = 'gaussian'; 
 [fData,wave] = sensorColorFilter(cfType);
 plot(wave,fData)
%}
%{
 wave = [400:10:700]; cPos = [500,600]; width = [40,40];
 fData = sensorColorFilter(cfType,wave, cPos, width);
 plot(wave,fData);
%}
%{
  cfType = 'gaussian'; wave = [350:850];
  cPos = 450:50:750; width = ones(size(cPos))*25;
  fData = sensorColorFilter(cfType,wave, cPos, width);
  plot(wave,fData)
%}
%{
  cfType = 'ir filter'; wave = 400:800; irCut = 680; smooth = 5;
  f = sensorColorFilter(cfType,wave,irCut,smooth);
  vcNewGraphWin; plot(wave,f);
%}
%{
  cfType = 'uv Filter'; wave = 350:800; uvCut = 440; smooth = 7;
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
    g = fspecial('gaussian',[5*smooth,1],smooth);
    fData = conv(fData,g,'same');
    
    switch (cfType)
        case 'gaussian'
            % No more smoothing.  User should change width
            disp('No gaussian smoothing');
        case 'uvfilter'
            fData((end-(2*smooth)):end) = 1;
        case 'irfilter'
            fData(1:(2*smooth)) = 1;
    end
    
end