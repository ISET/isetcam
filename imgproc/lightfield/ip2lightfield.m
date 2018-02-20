function lightfield = ip2lightfield(ip,varargin)
% Convert IP data obtained from light field sensor into lightfield array
%
% Syntax:
%  lightfield = ip2lightfield(ip,varargin)
%
% The lightfield dimensions are (superH, superW, nPinholesH, nPinholesW, 3)
% The pinholes can also be microlenses.  The super pixels mean clusters of
% pixels under the pinholes/microlenses.
%
% Required Inputs:
%   ip - ISET image processing object
%
% Parameters
%   pinholes:    vector of row/col number of pinholes (microlenses)
%   colorspace:  Output color space is linear rgb or srgb (default lrgb)
% 
% Output:
%   lightfield:  5-d light field data.  Four spatial dimensions and one
%                color dimension. The lightfield format is used by the Matlab
%                Central library 
%     <https://www.mathworks.com/matlabcentral/fileexchange/49683-light-field-toolbox-v0-4> 
%
% See also:  s_lfNotes and s_piReadRenderLF in pbrt2ISET; s_lfIntro in CISET
%
% HB/BW, SCIEN Stanford 2016 

% Examples:
%{
 % When you have a recipe (thisR) and matched oi/sensor/ip
 nPinholes  = thisR.get('n microlens');
 lightfield = ip2lightfield(ip,'pinholes',nPinholes);
 LFDispVidCirc(lightfield);
%}

%% Parse inputs

p = inputParser;
p.addRequired('ip',@isstruct);
p.addParameter('pinholes',[0 0],@isvector);
p.addParameter('colorspace','linear',@ischar);

p.parse(ip,varargin{:});
nPinholes  = p.Results.pinholes;
colorspace = p.Results.colorspace;

%% Get the results and convert to the right color space

rgb = ipGet(ip,'result');

% IP always has RGB color data ... but just in case.
cDim = size(rgb,3);

switch colorspace
    case {'linear','lrgb'}
        % Nothing
    case 'srgb'
        rgb = lrgb2srgb(double(rgb));
    otherwise
        error('Unknown color space %s\n',colorspace);
end

%% Repack the rgb data into lightfield format

superPixelH = size(rgb,1)/nPinholes(1);
superPixelW = size(rgb,2)/nPinholes(2);
lightfield = zeros(superPixelH, superPixelW, nPinholes(1), nPinholes(2), cDim);

% For lightfield calculations, we use this rgb format
for i = 1:nPinholes(2)
    for j = 1:nPinholes(1)
        lightfield(:,:, j, i, :) = ...
            rgb(((j-1)*superPixelH + 1):(j*superPixelH), ...
            ((i-1) * superPixelW + 1):(i*superPixelW), :);
    end
end

end