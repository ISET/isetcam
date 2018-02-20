function [fData, wave] = sensorColorFilter(cfType,varargin)
% Create color filters for use in a sensor
%
%     [fData, wave] = sensorColorFilter(cfType,varargin)
%
% Gateway routine for creating sensor color filter curves.
%
%  Gaussian:(Others to come)
%
%  
% Examples:
% Gaussian type:
%  cfType = 'gaussian'; 
%  [fData,wave] = sensorColorFilter(cfType);
%  plot(wave,fData)
%
%  wave = [400:10:700]; cPos = [500,600]; width = [40,40];
%  fData = sensorColorFilter(cfType,wave, cPos, width);
%  plot(wave,fData);
%
%  cfType = 'gaussian'; wave = [350:850];
%  cPos = 450:50:750; width = ones(size(cPos))*25;
%  fData = sensorColorFilter(cfType,wave, cPos, width);
%  plot(wave,fData)
%
% See also: 
%  
% Copyright ImagEval Consultants, LLC, 2010

if ieNotDefined('cfType'), cfType = 'gaussian'; end

switch lower(cfType)
    case 'gaussian'  
        if isempty(varargin), wave = 400:700; 
        else wave = varargin{1}; end
        if length(varargin)<2, cPos = [450,550,650]; 
        else cPos = varargin{2}; end
        if length(varargin)<3, widths = ones(size(cPos))*40; 
        else widths = varargin{3}; end

        nFilters = length(cPos);
        fData = zeros(length(wave),nFilters);
        for ii=1:nFilters
            fData(:,ii) = exp(-1/2*( (wave-cPos(ii))/(widths(ii))).^2);
        end
        % plot(wave,fData)
    otherwise
        error('Unknown filter type')
end

return