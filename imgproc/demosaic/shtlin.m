function out = shtlin(in)
% Smooth hue interpolation algorithm (not fully implemented)
%
%    out = shtlin(in)
%
% Demosaic'ing algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% Ting Chen evaluated this in my class.
%
% It only works on the following color array
%
%  ------------------> x
%  |  G R G R ...
%  |  B G B G ...
%  |  G R G R ...
%  |  B G B G ...
%  |  . . . . .
%  |  . . . .  .
%  |  . . . .   .
%  |
%  V y
%
%
% Input :
%
% in : original image matrix (mxnx3), m&n even
%
% Output :
%
% out : color interpolated image
%
% Last Modified : 03/09/99
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO
% Programming.  Much

m = size(in, 1);
n = size(in, 2);
inR = in(:, :, 1);
inG = in(:, :, 2);
inB = in(:, :, 3);
out = in;
outR = inR;
outG = inG;
outB = inB;

% G channel
for i = 2:2:m - 2,
    outG(i, 3:2:n-1) = 0.25 * (inG(i, 2:2:n - 2) + inG(i, 4:2:n) + inG(i - 1, 3:2:n - 1) + inG(i + 1, 3:2:n - 1));
end

for i = 3:2:m - 1,
    outG(i, 2:2:n-2) = 0.25 * (inG(i, 1:2:n - 3) + inG(i, 3:2:n - 1) + inG(i - 1, 2:2:n - 2) + inG(i + 1, 2:2:n - 1));
end

outG(1, 2:2:n-2) = 1 / 3 * (inG(1, 1:2:n - 3) + inG(3:2:n - 1) + inG(2, 2:2:n - 2));
outG(1, n) = 1 / 2 * (inG(1, n - 1) + inG(2, n));
outG(3:2:m-1, n) = 1 / 3 * (inG(2:2:m - 2, n) + inG(4:2:m, n) + inG(3:2:m - 1, n - 1));
outG(2:2:m-2, 1) = 1 / 3 * (inG(1:2:m - 3, 1) + inG(3:2:m - 1, 1) + inG(2:2:m - 2, 2));
outG(m, 1) = 1 / 2 * (inG(m - 1, 1) + inG(m, 2));
outG(m, 3:2:n-1) = 1 / 3 * (inG(m, 2:2:n - 2) + inG(m, 4:2:n) + inG(m - 1, 3:2:n - 1));

outG = round(outG);
ind = find(outG > 255);
outG(ind) = 255;

% R channel
for i = 1:2:m - 1,
    outR(i, 3:2:n-1) = 1 / 2 * outG(i, 3:2:n-1) .* (inR(i, 2:2:n - 2) ./ outG(i, 2:2:n - 2) + inR(i, 4:2:n) ./ outG(i, 4:2:n));
end

for i = 2:2:m - 2,
    outR(i, 2:2:n) = 1 / 2 * outG(i, 2:2:n) .* (inR(i - 1, 2:2:n) ./ outG(i - 1, 2:2:n) + inR(i + 1, 2:2:n) ./ outG(i + 1, 2:2:n));
    outR(i, 3:2:n-1) = 1 / 4 * outG(i, 3:2:n-1) .* (inR(i - 1, 2:2:n - 2) ./ outG(i - 1, 2:2:n - 2) + inR(i - 1, 4:2:n) ./ outG(i - 1, 4:2:n) + inR(i + 1, 2:2:n - 2) ./ outG(i + 1, 2:2:n - 2) + inR(i + 1, 4:2:n) ./ outG(i + 1, 4:2:n));
end

outR = round(outR);
ind = find(outR > 255);
outR(ind) = 255;

% B channel
for i = 2:2:m,
    outB(i, 2:2:n-2) = 1 / 2 * outG(i, 2:2:n-1) .* (inB(i, 1:2:n - 3) ./ outG(i, 1:2:n - 3) + inB(i, 3:2:n - 1) ./ outG(i, 3:2:n - 1));
end

for i = 3:2:m - 1,
    outB(i, 1:2:n-1) = 1 / 2 * outG(i, 1:2:n-1) .* (inB(i - 1, 1:2:n - 1) ./ outG(i - 1, 1:2:n - 1) + inB(i + 1, 1:2:n - 1) ./ outG(i + 1, 1:2:n - 1));
    outB(i, 2:2:n-2) = 1 / 4 * outG(i, 2:2:n-2) .* (inB(i - 1, 1:2:n - 3) ./ outG(i - 1, 1:2:n - 3) + inB(i - 1, 3:2:n - 1) ./ outG(i - 1, 3:2:n - 1) + inB(i + 1, 1:2:n - 3) ./ outG(i + 1, 1:2:n - 3) + inB(i + 1, 3:2:n - 1) ./ outG(i + 1, 3:2:n - 1));
end

outB = round(outB);
ind = find(outB > 255);
outB(ind) = 255;

out(:, :, 1) = outR;
out(:, :, 2) = outG;
out(:, :, 3) = outB;
