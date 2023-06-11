function DAC = rgb2dac(RGB, invGammaTable)
% Convert linear RGB values through a gamma table to DAC valuels
%
% DAC = rgb2dac(RGB, invGammaTable)
%
% RGB is the linear intensity of each gun, in the form of [r g b]. It RGB
% should be in the range [0 1].
%
% DAC contains the frame buffer values of the 3 color planes, in the form
%    of [DAC_r DAC_g DAC_b]. To separate the 3 planes, use GetPlanes.
%    The DAC values returned are in the range [0, 1].
%
% invGammaTable -- the look up table to go from linear RGB to DAC
%    If it has one column, all RGB values are changed according to this
%    If it is a scalar number, raise the RGB values to 1/invGammaTable.
%    If GammaTable is not given, use a default scalar of 1/2.2.
%
% Xuemei Zhang
% Last Modified 4/29/97

if (nargin==1), invGammaTable = 2.2; end

n = size(RGB);

if (numel(invGammaTable)==1)
    if (nargin==1)
        disp(['Raising RGB values to a power of 1/' num2str(invGammaTable)]);
    end
    DAC = RGB.^(1/invGammaTable);
else
    RGB = round(RGB * (size(invGammaTable,1)-1)) + 1;
    
    if (size(invGammaTable,2)==1)
        DAC = invGammaTable(RGB(:));
    else
        RGB = reshape(RGB, prod(n)/3, 3);
        DAC = [invGammaTable(RGB(:,1),1) invGammaTable(RGB(:,2),2) ...
            invGammaTable(RGB(:,3),3)];
    end
    
    DAC = round(reshape(DAC, n));
    % DAC = DAC/max(invGammaTable(:));
end

end

