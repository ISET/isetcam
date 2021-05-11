function outImg = render_lcd_samsung_rgbw(inImg, d, sz)
% render image for RGBW display
%
%     I = render_lcd_samsung_rgbw
%
% This is the render function for RGBW display
% The display can be created with
%    d = displayCreate('LCD-Samsung-RGBW');
%
% The sub-pixel design is RGBW, whose repeating unit is 1x1
%
% Inputs:
%   inImg  - input image, size(inImg, 3) should be same as nprimaries
%   d      - display structure, can be created by displayCreate
%
% Output:
%   outImg - rendered image
%
% Example:
%   d = displayCreate('LCD-Samsung-RGBW');
%   I = 0.5*(sin(2*pi*(1:32)/32)+1); I = repmat(I,32,1);
%   outI = render_oled_samsung(I, d);
%
% See also:
%   displayCompute
%
%  HJ, ISETBIO TEAM, 2014

%% Init
if notDefined('inImg'), error('input image required'); end
if notDefined('d'), d = displayCreate('LCD-Samsung-RGBW'); end

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

%create a blank upsampled whole image(h*subpixelhscalefactor,w*subpixelwscalefactor, nprimaries)
outImg = zeros(size(inImg, 1)*s(1), size(inImg, 2)*s(2), nprimaries);

%goal for this rendering is to set W to be minimum of RGB, and RGB pixels
%to be RGB-W

% loop over primaries
for ii = 1:nprimaries

    % example using block processing (but not for RGBW)
    %     % define function handle
    %     hf = @(x) x.data(controlMap(:,:,ii));
    %     % process
    %     outImg(:, :, ii) = blockproc(inImg(:,:,ii), pixels_per_dixel, hf);
    for h = 1:pixels_per_dixel(1):size(inImg, 1)
        for w = 1:pixels_per_dixel(2):size(inImg, 2)
            %cropping the input data needed to calculate a set of pixels within a repeating unit
            block_data = inImg(h:(h + pixels_per_dixel(1) - 1), w:(w + pixels_per_dixel(2) - 1), :); % RGBW values at each pixel position
            block_data = block_data(1:3); % W is pre-padded with 0 and it's not useful

            if ii <= 3 % for RGB
                outImg(((h - 1) * s(1) + 1):h*s(1), ((w - 1) * s(2) + 1):w*s(2), ii) = ...
                    (block_data(ii) - min(block_data)) * controlMap(:, :, ii);
            else
                outImg(((h - 1) * s(1) + 1):h*s(1), ((w - 1) * s(2) + 1):w*s(2), ii) = ...
                    min(block_data) * controlMap(:, :, ii);
            end


        end
    end


end

end