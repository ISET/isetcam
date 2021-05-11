function out = shtlog(in)
% smooth hue transition interpolation algorithm in logarithmic exposure space
%
%   out = shtlog(in)
%
% Demosaic'ing algorithms estimate missing color information by
% interpolation of the known color information across different color
% planes.
%
% Ting Chen implementation.  Must be re-written entirely.
%
%
% Assumptions : in has following color patterns
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

%TODO
% Much

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

outB_log = log(outB);
outR_log = log(outR);
outG_log = log(outG);
inB_log = log(inB);
inR_log = log(inR);

% R channel
for i = 1:2:m - 1,
    outR_log(i, 3:2:n-1) = outG_log(i, 3:2:n-1) + 1 / 2 * (inR_log(i, 2:2:n - 2) - outG_log(i, 2:2:n - 2) + inR_log(i, 4:2:n) - outG_log(i, 4:2:n));
end

for i = 2:2:m - 2,
    outR_log(i, 2:2:n) = outG_log(i, 2:2:n) + 1 / 2 * (inR_log(i - 1, 2:2:n) - outG_log(i - 1, 2:2:n) + inR_log(i + 1, 2:2:n) - outG_log(i + 1, 2:2:n));
    outR_log(i, 3:2:n-1) = outG_log(i, 3:2:n-1) + 1 / 4 * (inR_log(i - 1, 2:2:n - 2) - outG_log(i - 1, 2:2:n - 1) + inR_log(i - 1, 4:2:n) - outG_log(i - 1, 4:2:n) + inR_log(i + 1, 2:2:n - 2) - outG_log(i + 1, 2:2:n - 2) + inR_log(i + 1, 4:2:n) - outG_log(i + 1, 4:2:n));
end

outR = exp(outR_log);
outR = round(outR);
ind = find(outR > 255);
outR(ind) = 255;

% B channel
for i = 2:2:m,
    outB_log(i, 2:2:n-2) = outG_log(i, 2:2:n-1) + 1 / 2 * (inB_log(i, 1:2:n - 3) - outG_log(i, 1:2:n - 3) + inB_log(i, 3:2:n - 1) - outG_log(i, 3:2:n - 1));
end

for i = 3:2:m - 1,
    outB_log(i, 1:2:n-1) = outG_log(i, 1:2:n-1) + 1 / 2 * (inB_log(i - 1, 1:2:n - 1) - outG_log(i - 1, 1:2:n - 1) + inB_log(i + 1, 1:2:n - 1) - outG_log(i + 1, 1:2:n - 1));
    outB_log(i, 2:2:n-2) = outG_log(i, 2:2:n-1) + 1 / 4 * (inB_log(i - 1, 1:2:n - 3) - outG_log(i - 1, 1:2:n - 3) + inB_log(i - 1, 3:2:n - 1) - outG_log(i - 1, 3:2:n - 1) + inB_log(i + 1, 1:2:n - 3) - outG_log(i + 1, 1:2:n - 3) + inB_log(i + 1, 3:2:n - 1) - outG_log(i + 1, 3:2:n - 1));
end

outB = exp(outB_log);
outB = round(outB);
ind = find(outB > 255);
outB(ind) = 255;

out(:, :, 1) = outR;
out(:, :, 2) = outG;
out(:, :, 3) = outB;

return;