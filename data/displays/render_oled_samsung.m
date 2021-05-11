function outImg = render_oled_samsung(inImg, d, sz)
% render image for Samsung S-strip display
%
%     I = render_oled_samsung
%
% This is the render function for OLED-Samsung display
% The display can be created with
%    d = displayCreate('OLED-Samsung');
%
% The sub-pixel design is Samsung S-strip, whose repeating unit contains
% 2x2 pixels
%
% Inputs:
%   inImg  - input image, size(inImg, 3) should be same as nprimaries
%   d      - display structure, can be created by displayCreate
%
% Output:
%   outImg - rendered image
%
% Example:
%   d = displayCreate('OLED-Samsung');
%   I = 0.5*(sin(2*pi*(1:32)/32)+1); I = repmat(I,32,1);
%   outI = render_oled_samsung(I, d);
%
% See also:
%   displayCompute
%
%  HJ, ISETBIO TEAM, 2014

%% Init
if notDefined('inImg'), error('input image required'); end
if notDefined('d'), d = displayCreate('OLED-Samsung'); end

%% Render
% Get parameters from display structure
pixels_per_dixel = displayGet(d, 'pixels per dixel');
nprimaries = size(inImg, 3);

if notDefined('sz')
    s = displayGet(d, 'over sample');
    controlMap = displayGet(d, 'dixel control map');
else
    s = round(sz./displayGet(d, 'pixels per dixel'));
    controlMap = displayGet(d, 'dixel control map', sz);
end

% process by block
outImg = zeros(size(inImg, 1)*s(1), size(inImg, 2)*s(2), nprimaries);
for ii = 1:nprimaries
    % define function handle
    hf = @(x) x.data(controlMap(:, :, ii));

    % process
    outImg(:, :, ii) = blockproc(inImg(:, :, ii), pixels_per_dixel, hf);
end

end