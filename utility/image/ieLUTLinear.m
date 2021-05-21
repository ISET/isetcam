function DAC = ieLUTLinear(RGB, gTable)
% Convert linear RGB values through a gamma table to DAC values
%
%   DAC = ieLUTLinear(RGB, invGammaTable)
%
% The RGB values are assumed to be in the range of [0,1].  They are assumed
% to be linear with respect to radiance (intensity).
%
% The returned DAC values are digital values with a bit depth that is
% determined by the entries in the gTable.
%
% We define
%  * The gamma table maps the digital values to the display intensity.
%  * The inverse gamma table maps the display intensity to the digital values.
%
%  We expect a gTable to have size 2^nBits x 3.  If the gTable has size
%  2^nBits x 1, we assume the three channels are the same. In this
%  application, we expect that  gTable to be the inverse gamma table.
%
%  We store the gamma table in display calibration files.  We invert a
%  typical gTable using ieLUTInvert.
%
%  If the gTable is a single number, we raise the data to the power
% (1/gTable).
%
% See also:  ieLUTDigital, ieLUTInvert
%
% Example:
%   d = displayCreate;
%   rgb = rand(10,10,3);
%   foo = ieLUTLinear(rgb, d.gamma.^(1/2.2));
%   vcNewGraphWin; plot(foo(:),rgb(:),'.')
%
% (c) Imageval Consulting, LLC 2013

if (nargin==1), gTable = 2.2; end

if (numel(gTable) == 1)
    % Single number.  Raise to a power.
    DAC = RGB.^(1/gTable);
else
    if size(gTable,2) == 1
        % If only one column, repmat to number of display colors
        gTable = repmat(gTable,1,size(RGB,3));
    end
    
    % Scale the linear RGB values so that that largest value, 1 maps to the
    % row size of the gTable.
    tMax = size(gTable,1);
    RGB = floor(RGB*tMax) + 1;
    
    % Sometimes there is a perfect 1 so the floor above doesn't quite work
    RGB(RGB>tMax) = tMax;
    
    % Convert through the gamma table.
    DAC = zeros(size(RGB));
    for ii=1:size(RGB,3)
        thisTable = gTable(:,ii);
        DAC(:,:,ii) = thisTable(RGB(:,:,ii));
    end
    
end

