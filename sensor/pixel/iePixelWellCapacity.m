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
%    From an online reference to be cited here.
%
% Wandell, 2019
%
% See also
%

%%
p = inputParser;
p.addRequired('pixelSize',@isscalar);
p.parse(pixelSize);

%%  Interpolate this lookup table, which is based on ...

dataSize = [];
dataElectrons = [];
electrons = interp(dataSize,dataElectrons,pixelSize);

end