function [XYZ, xyY] = ieMunsell2XYZ(munsell)
% Convert Munsell notation to CIE XYZ (Illuminant C, 2-deg observer)
%
% Synopsis
%   [XYZ, xyY] = ieMunsell2XYZ(munsell)
%
% Brief description
%   Returns the CIE XYZ values of Munsell colors by interpolating the
%   Munsell renotation data (Newhall, Nickerson and Judd, 1943).  The XYZ
%   values are for CIE Illuminant C and the CIE 1931 2-deg observer.
%
% Inputs
%   munsell: Munsell colors as either
%            - Text: char, string array, or cell array of char, such as
%              '5R 4/14' or {'2.5YR 6/8','N 5/'}
%            - Numeric N x 3 [H V C], with the hue H on the 100-step hue
%              circle (5R = 5, 2.5YR = 12.5, ..., 10RP = 100).  See
%              ieMunsellNotation.
%
% Returns
%   XYZ: N x 3 CIE XYZ.  Y is scaled so that a perfect reflecting diffuser
%        has Y = 100 (Munsell Value 10).
%   xyY: N x 3 [x y Y], on the same scale.
%
%   Colors outside the renotation data, for example a chroma beyond the
%   data at that hue and value, or a chromatic color with Value below 0.2
%   or above 10, have XYZ = NaN.  In xyY their x and y are NaN, and Y is
%   still computed from the Value.
%
% Description
%   Value to Y.  Y is computed from Munsell Value with the ASTM D1535
%   polynomial
%
%     Y = 1.1914 V - 0.22533 V^2 + 0.23352 V^3 - 0.020484 V^4 + 0.00081939 V^5
%
%   This is the 1943 renotation formula multiplied by 0.975, which converts
%   the renotation scale (relative to magnesium oxide) to a perfect-diffuser
%   scale.  To compare Y with the published renotation tables, divide by
%   0.975.
%
%   Chromaticity.  The renotation data sample hue in steps of 2.5, Value in
%   integer steps (plus 0.2, 0.4, 0.6, 0.8), and chroma in steps of 2.  The
%   chromaticity of other colors is interpolated in three stages:
%
%     1. Hue: between the two neighboring sampled hues, in polar
%        coordinates (radius and angle about Illuminant C), at each of the
%        two sampled chromas that bracket the requested chroma.
%     2. Chroma: linearly in (x,y) between those two chromas.  Chroma 0 is
%        the Illuminant C chromaticity.
%     3. Value: linearly in (x,y), as a function of Y, between the two
%        sampled Values that bracket the requested Value.
%
%   Edge of the data.  The highest chroma in the data differs between
%   neighboring hues and Values.  To smooth this ragged edge, wherever a
%   neighboring hue or Value has a higher chroma, the series is extended by
%   one chroma step (linear extrapolation in x,y).  Also, where only one of
%   the two bracketing Value planes has the requested chroma, a Value
%   within 0.01 of that plane uses that plane alone.  Neither rule changes
%   any color that is inside the data.
%
%   At the renotation samples the result is the (x,y) published in the
%   'all' dataset (see ieMunsellRenotation).  ASTM
%   D1535 and implementations such as Paul Centore's and the colour-science
%   Python package choose between linear and polar hue interpolation region
%   by region.  This function always uses polar interpolation, so between
%   samples the results can differ slightly from those implementations.
%
%   The Munsell system is defined for Illuminant C.  XYZ values for another
%   illuminant must be chromatically adapted before comparing with these.
%
% See also
%   ieXYZ2Munsell, ieMunsellNotation, ieMunsellRenotation, xyy2xyz

% Examples:
%{
XYZ = ieMunsell2XYZ('5R 4/14')
%}
%{
% A hue circle at Value 5, chroma 8
hvc = [(2.5:2.5:100)', 5*ones(40,1), 8*ones(40,1)];
[~, xyY] = ieMunsell2XYZ(hvc);
chromaticityPlot(xyY(:,1:2));
%}
%{
% Values between the samples
[XYZ, xyY] = ieMunsell2XYZ({'4.2YR 8.1/5.3','N 5/','7.5PB 2.5/11'})
%}

%%
if ~exist('munsell','var') || isempty(munsell)
    error('Munsell notation or [H V C] values are required.');
end

if isnumeric(munsell)
    if size(munsell,2) ~= 3, error('Numeric input must be N x 3 [H V C].'); end
    hvc = double(munsell);
else
    hvc = ieMunsellNotation(munsell);
end

H = hvc(:,1);
V = hvc(:,2);
C = hvc(:,3);

xy  = munsellChromaticity(H, V, C);
Y   = munsellValue2Y(V);
xyY = [xy, Y];
XYZ = xyy2xyz(xyY);
XYZ(any(isnan(xy), 2), :) = NaN;

end

%% ---------------------------------------------------------------------
function Y = munsellValue2Y(V)
% ASTM D1535 Value to luminance factor (perfect diffuser = 100)
Y = V.*(1.1914 + V.*(-0.22533 + V.*(0.23352 + V.*(-0.020484 + V*0.00081939))));
Y(V < 0) = NaN;
end

%% ---------------------------------------------------------------------
function xy = munsellChromaticity(H, V, C)
% Interpolate the renotation chromaticity at [H V C]

persistent grid
if isempty(grid), grid = buildGrid(); end

xy = nan(numel(H), 2);

% Neutrals have the Illuminant C chromaticity at any Value
neutral = (C == 0) & (V >= 0);
xy(neutral,:) = repmat(grid.white, sum(neutral), 1);

chromatic = (C > 0) & ~isnan(H) & (V >= grid.values(1)) & (V <= grid.values(end));
if ~any(chromatic), return; end

h = mod(H(chromatic), 100);
v = V(chromatic);
c = C(chromatic);

% Bracketing Value planes.  Interpolation is linear in Y.
lo  = discretize(v, grid.values);
hi  = lo + 1;
wV  = (munsellValue2Y(v) - grid.Y(lo)) ./ (grid.Y(hi) - grid.Y(lo));
xyLo = planeChromaticity(grid, h, c, lo);
xyHi = planeChromaticity(grid, h, c, hi);

% Near the edge of the data, a Value just off a sampled plane can need a
% chroma that the neighboring plane lacks.  Within tolV of a sampled
% Value, use that plane alone in this case.
tolV = 0.01;
wV((v - grid.values(lo) <= tolV) & any(isnan(xyHi), 2)) = 0;
wV((grid.values(hi) - v <= tolV) & any(isnan(xyLo), 2)) = 1;

% At a sampled Value only one plane is needed, and the other may lack data
xyHi(wV == 0,:) = xyLo(wV == 0,:);
xyLo(wV == 1,:) = xyHi(wV == 1,:);
xy(chromatic,:) = (1 - wV).*xyLo + wV.*xyHi;

end

%% ---------------------------------------------------------------------
function xy = planeChromaticity(grid, h, c, m)
% Chromaticity at hue h and chroma c within Value plane m

% Neighboring hues.  Hue index j is hue 2.5*j, j = 1..40; hue 0 = 100.
u   = h/2.5;
j0  = floor(u);
wH  = u - j0;
jLo = j0;  jLo(jLo == 0) = grid.nHue;
jHi = j0 + 1;

% Neighboring chromas.  Chroma index k is chroma 2*(k-1); k = 1 is 0.
w   = c/2;
k0  = floor(w);
wC  = w - k0;
kLo = k0 + 1;
kHi = k0 + 2;

xyCLo = hueInterpolate(grid, jLo, jHi, kLo, m, wH);
xyCHi = hueInterpolate(grid, jLo, jHi, kHi, m, wH);
xyCHi(wC == 0,:) = xyCLo(wC == 0,:);
xy = (1 - wC).*xyCLo + wC.*xyCHi;

end

%% ---------------------------------------------------------------------
function xy = hueInterpolate(grid, jLo, jHi, k, m, wH)
% Polar interpolation about the white point between hues jLo and jHi

xy = nan(numel(k), 2);
ok = k <= grid.nChroma;
if ~any(ok), return; end

iLo = sub2ind(size(grid.x), jLo(ok), k(ok), m(ok));
iHi = sub2ind(size(grid.x), jHi(ok), k(ok), m(ok));
w   = wH(ok);

x1 = grid.x(iLo) - grid.white(1);  y1 = grid.y(iLo) - grid.white(2);
x2 = grid.x(iHi) - grid.white(1);  y2 = grid.y(iHi) - grid.white(2);

% At a sampled hue only one hue is needed, and the other may lack data
x2(w == 0) = x1(w == 0);
y2(w == 0) = y1(w == 0);

r1 = hypot(x1, y1);    r2 = hypot(x2, y2);
t1 = atan2(y1, x1);    t2 = atan2(y2, x2);
dt = mod(t2 - t1 + pi, 2*pi) - pi;

r = (1 - w).*r1 + w.*r2;
t = t1 + w.*dt;
xy(ok,:) = [grid.white(1) + r.*cos(t), grid.white(2) + r.*sin(t)];

end

%% ---------------------------------------------------------------------
function grid = buildGrid()
% Arrange the renotation data on a hue x chroma x Value grid

d = ieMunsellRenotation('all');

grid.white   = [0.31006 0.31616];        % Illuminant C, CIE 1931 2-deg
grid.values  = unique(d.hvc(:,2));        % 0.2, 0.4, ..., 1, 2, ..., 10
grid.Y       = munsellValue2Y(grid.values);
grid.nHue    = 40;                        % Hue steps of 2.5
grid.nChroma = max(d.hvc(:,3))/2 + 1;     % Chroma 0, 2, 4, ...

sz = [grid.nHue, grid.nChroma, numel(grid.values)];
grid.x = nan(sz);
grid.y = nan(sz);
grid.x(:,1,:) = grid.white(1);
grid.y(:,1,:) = grid.white(2);

j = round(d.hvc(:,1)/2.5);
k = d.hvc(:,3)/2 + 1;
[~, m] = ismember(d.hvc(:,2), grid.values);
idx = sub2ind(sz, j, k, m);
grid.x(idx) = d.xyY(:,1);
grid.y(idx) = d.xyY(:,2);

% The highest chroma differs between neighboring hues and Values, so the
% edge of the data is ragged.  Where a neighboring hue or Value has a
% higher chroma, extend the series by one chroma step, extrapolating
% linearly in (x,y).
kMax = zeros(sz(1), sz(3));
for jj = 1:sz(1)
    for mm = 1:sz(3)
        kMax(jj,mm) = find(~isnan(grid.x(jj,:,mm)), 1, 'last');
    end
end
kNeighbor = kMax;
for dj = -1:1
    shifted = circshift(kMax, dj, 1);
    kNeighbor = max(kNeighbor, shifted);
    kNeighbor(:,2:end)     = max(kNeighbor(:,2:end),     shifted(:,1:end-1));
    kNeighbor(:,1:end-1)   = max(kNeighbor(:,1:end-1),   shifted(:,2:end));
end
[jj, mm] = find(kNeighbor > kMax & kMax >= 2 & kMax < sz(2));
for ii = 1:numel(jj)
    k1 = kMax(jj(ii), mm(ii));
    grid.x(jj(ii), k1+1, mm(ii)) = 2*grid.x(jj(ii), k1, mm(ii)) - grid.x(jj(ii), k1-1, mm(ii));
    grid.y(jj(ii), k1+1, mm(ii)) = 2*grid.y(jj(ii), k1, mm(ii)) - grid.y(jj(ii), k1-1, mm(ii));
end

end
