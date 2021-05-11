function MP = ieN2MegaPixel(N, precision)
% Compute megapixel count from N
%
% The decimal precision defaults to 1, but you can ask for more.
%
% Example:
%   N = 1024*1024; MP = ieN2MegaPixel(N)
%
%   N = 1920*1024; MP = ieN2MegaPixel(N,2)
%   MP = ieN2MegaPixel(N,0)

if ieNotDefined('precision'), precision = 1; end

MP = round(N*1e-6*(10^precision)) / 10^precision;

return;