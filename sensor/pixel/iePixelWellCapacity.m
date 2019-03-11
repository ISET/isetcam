function electrons = iePixelWellCapacity(pixelSize)
% Return estimated well capacity (electrons) for a pixel size (microns)
%
% Syntax:
%     iePixelWellCapacity(pixelSize)
%
% Input
%   pixelSize:  Pixel size in microns
%
% Key-Value parameters
%   N/A
%
% Output
%   electrons:  Well capacity in electrons
%
% Description:
%    From an online reference.
%    http://www.clarkvision.com/articles/digital.sensor.performance.summary/
%
%    These data are approximately the values in the Canon pixel sizes.
%    Other vendors have different well capacity and pixel size
%    relationships.
%
% Wandell, 2019
%
% See also
%

% Examples:
%{
  pSizeUM = 1;
  fprintf('Well capacity %d\n',round(iePixelWellCapacity(pSizeUM)))
%}

%
%%
p = inputParser;
p.addRequired('pixelSize',@isscalar);
p.parse(pixelSize);

if pixelSize < 1 || pixelSize > 8
    warning('Pixel size (%.2f microns) out of typical range',pixelSize);
end

%%  Interpolate this lookup table, which is based on ...

fname = fullfile(isetRootPath,'data','sensor','wellCapacity');

% Pixel size in microns vs. well capacity in electrons
% Snagged from the Roger Clark graph at the link above.  
% May be updated with newer information from Boyd and others over time.
load(fname,'wellCapacity');

electrons = interp1(wellCapacity(:,1),wellCapacity(:,2),pixelSize,'linear','extrap');
% ieNewGraphWin;
% plot(wellCapacity(:,1),wellCapacity(:,2),'--',pixelSize,electrons,'o');

end