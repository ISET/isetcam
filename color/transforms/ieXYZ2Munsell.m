function [hvc, notation] = ieXYZ2Munsell(XYZ)
% Convert CIE XYZ (Illuminant C, 2-deg observer) to Munsell notation
%
% Synopsis
%   [hvc, notation] = ieXYZ2Munsell(XYZ)
%
% Brief description
%   Finds the Munsell hue, value, and chroma of CIE XYZ values by
%   inverting ieMunsell2XYZ, which interpolates the Munsell renotation data
%   (Newhall, Nickerson and Judd, 1943).
%
% Inputs
%   XYZ: N x 3 (XW format) or r x c x 3 (RGB format) CIE XYZ values for
%        Illuminant C and the CIE 1931 2-deg observer.  Y is scaled so that
%        a perfect reflecting diffuser has Y = 100.
%
% Returns
%   hvc:      [H V C] in the same format as the input (N x 3 or r x c x 3).
%             H is on the 100-step hue circle (see ieMunsellNotation).
%             Neutral colors have H = NaN and C = 0.
%   notation: Munsell notation as a string array (N x 1 or r x c), such
%             as "4.2YR 8.1/5.3" or "N 5/".  Values are rounded to one
%             decimal place.
%
% Description
%   Value is found by inverting the ASTM D1535 Value-to-Y polynomial (see
%   ieMunsell2XYZ).  Hue and chroma are then found by Newton iteration: at
%   that Value, search for the hue and chroma whose ieMunsell2XYZ
%   chromaticity matches the input chromaticity.  The search starts from
%   an interpolation of the renotation data, and it runs in Cartesian
%   coordinates, (C cos(theta), C sin(theta)), so that it behaves well
%   near the neutral axis.  Consequently ieMunsell2XYZ(ieXYZ2Munsell(XYZ))
%   returns the input chromaticity to within 1e-10, or 1e-7 for colors at
%   the edge of the data.
%
%   Colors outside the renotation data have H and C returned as NaN and
%   produce a warning.  These include chromatic colors with Value below
%   0.2 or above 10, and chromaticities beyond the highest chroma in the
%   data at that hue and Value.
%
%   The Munsell system is defined for Illuminant C.  XYZ values for another
%   illuminant (such as D65) must be chromatically adapted to Illuminant C
%   first.
%
% See also
%   ieMunsell2XYZ, ieMunsellNotation, ieMunsellRenotation, ieXYZ2LAB

% Examples:
%{
[hvc, notation] = ieXYZ2Munsell([30 25 10])
%}
%{
% Round trip from notation to XYZ and back
XYZ = ieMunsell2XYZ({'4.2YR 8.1/5.3','5PB 3/10','N 7/'});
[~, notation] = ieXYZ2Munsell(XYZ)
%}
%{
% Munsell notation of the Macbeth ColorChecker under Illuminant C
wave = 400:10:700;
reflectance = ieReadSpectra('macbethChart', wave);
illC = ieReadSpectra('illuminantC', wave);
XYZ = ieXYZFromEnergy((reflectance .* illC)', wave);
white = ieXYZFromEnergy(illC', wave);
XYZ = 100 * XYZ / white(2);
[~, notation] = ieXYZ2Munsell(XYZ)
%}

%%
if ~exist('XYZ','var') || isempty(XYZ), error('XYZ values are required.'); end

isRGB = (ndims(XYZ) == 3);
if isRGB
    [r, c, ~] = size(XYZ);
    XYZ = RGB2XWFormat(XYZ);
end
if size(XYZ,2) ~= 3, error('XYZ must be N x 3 or r x c x 3.'); end
XYZ = double(XYZ);

white  = [0.31006 0.31616];   % Illuminant C, CIE 1931 2-deg
vRange = [0.2 10];            % Value range of the renotation data

nSamples = size(XYZ,1);
hvc = nan(nSamples, 3);

% Value
hvc(:,2) = munsellY2Value(XYZ(:,2));

% Chromaticity.  Black and the white point are neutral.
xy = XYZ(:,1:2) ./ sum(XYZ, 2);
neutral = (XYZ(:,2) == 0) | (hypot(xy(:,1) - white(1), xy(:,2) - white(2)) < 1e-9);
neutral = neutral & ~isnan(hvc(:,2));
hvc(neutral,3) = 0;

% Hue and chroma
todo = ~neutral & all(isfinite(xy), 2) & ...
    (hvc(:,2) >= vRange(1)) & (hvc(:,2) <= vRange(2));
if any(todo)
    [hvc(todo,1), hvc(todo,3)] = solveHueChroma(xy(todo,:), hvc(todo,2));
end

nBad = sum(~neutral & ~isnan(hvc(:,2)) & isnan(hvc(:,3)));
if nBad > 0
    warning('ieXYZ2Munsell:outOfRange', ...
        '%d of %d colors are outside the Munsell renotation data; their hue and chroma are NaN.', ...
        nBad, nSamples);
end

if nargout > 1, notation = ieMunsellNotation(hvc); end

if isRGB
    hvc = XW2RGBFormat(hvc, r, c);
    if nargout > 1, notation = reshape(notation, r, c); end
end

end

%% ---------------------------------------------------------------------
function V = munsellY2Value(Y)
% Invert the ASTM D1535 polynomial (see ieMunsell2XYZ) by Newton iteration

coef  = [0.00081939 -0.020484 0.23352 -0.22533 1.1914 0];
dcoef = polyder(coef);

V = nan(size(Y));
ok = (Y >= 0);
y = Y(ok);

% Start from the CIELAB lightness approximation, V ~ L*/10
v = max(11.6*(y/100).^(1/3) - 1.6, y/1.1914);
for ii = 1:50
    dv = (polyval(coef, v) - y) ./ polyval(dcoef, v);
    v  = v - dv;
    if all(abs(dv) < 1e-13), break; end
end
V(ok) = v;

end

%% ---------------------------------------------------------------------
function [H, C] = solveHueChroma(xyTarget, V)
% Newton search for the hue and chroma at Value V with chromaticity xy

persistent guess
if isempty(guess), guess = buildInitialGuess(); end

tol      = 1e-10;   % Converged chromaticity error
tolFinal = 1e-7;    % Larger errors are reported as out of range
step     = 1e-4;    % Finite-difference step (chroma units)

% Cartesian Munsell coordinates p = C*[cos(theta), sin(theta)]
p = [guess.a(xyTarget(:,1), xyTarget(:,2), V), ...
     guess.b(xyTarget(:,1), xyTarget(:,2), V)];
err = chromaticityError(p, V, xyTarget);

% The initial guess can land just outside the data.  Pull it toward the
% neutral axis, which is always inside.
for ii = 1:100
    bad = isnan(err);
    if ~any(bad), break; end
    p(bad,:) = 0.9*p(bad,:);
    err(bad) = chromaticityError(p(bad,:), V(bad), xyTarget(bad,:));
end

active = (err > tol);
for iter = 1:100
    if ~any(active), break; end
    pA = p(active,:);   vA = V(active);   tA = xyTarget(active,:);
    f0 = forwardChromaticity(pA, vA) - tA;
    e0 = hypot(f0(:,1), f0(:,2));

    % Jacobian by finite differences.  Step backward where a forward step
    % leaves the data.
    J = cell(1,2);
    for dim = 1:2
        dp = zeros(size(pA));  dp(:,dim) = step;
        J{dim} = (forwardChromaticity(pA + dp, vA) - tA - f0) / step;
        bad = any(isnan(J{dim}), 2);
        if any(bad)
            J{dim}(bad,:) = (f0(bad,:) - forwardChromaticity(pA(bad,:) - dp(bad,:), vA(bad)) + tA(bad,:)) / step;
        end
    end

    % Newton step: solve the 2 x 2 system J * delta = -f0 for each sample
    J11 = J{1}(:,1);  J12 = J{2}(:,1);
    J21 = J{1}(:,2);  J22 = J{2}(:,2);
    d   = J11.*J22 - J12.*J21;
    delta = -[(J22.*f0(:,1) - J12.*f0(:,2)) ./ d, ...
              (J11.*f0(:,2) - J21.*f0(:,1)) ./ d];
    delta(~isfinite(delta)) = 0;

    % Backtrack until the error decreases
    lambda = ones(size(e0));
    pNew = pA + delta;
    eNew = chromaticityError(pNew, vA, tA);
    for k = 1:30
        worse = ~(eNew < e0);
        if ~any(worse), break; end
        lambda(worse) = lambda(worse)/2;
        pNew(worse,:) = pA(worse,:) + lambda(worse).*delta(worse,:);
        eNew(worse) = chromaticityError(pNew(worse,:), vA(worse), tA(worse,:));
    end

    improved = (eNew < e0);
    pA(improved,:) = pNew(improved,:);
    e0(improved)   = eNew(improved);

    idx = find(active);
    p(idx,:) = pA;
    err(idx) = e0;

    % Stop samples that converged or can no longer improve
    active(idx(e0 <= tol | ~improved)) = false;
end

[H, C] = cartesian2HueChroma(p);

failed = ~(err <= tolFinal);
H(failed) = NaN;
C(failed) = NaN;

neutral = ~failed & (C < 1e-8);
H(neutral) = NaN;
C(neutral) = 0;

end

%% ---------------------------------------------------------------------
function e = chromaticityError(p, V, xyTarget)
f = forwardChromaticity(p, V) - xyTarget;
e = hypot(f(:,1), f(:,2));
end

function xy = forwardChromaticity(p, V)
[H, C] = cartesian2HueChroma(p);
[~, xyY] = ieMunsell2XYZ([H, V, C]);
xy = xyY(:,1:2);
end

function [H, C] = cartesian2HueChroma(p)
H = mod(atan2(p(:,2), p(:,1)) * 50/pi, 100);
H(H == 0) = 100;
C = hypot(p(:,1), p(:,2));
end

%% ---------------------------------------------------------------------
function guess = buildInitialGuess()
% Interpolate Cartesian Munsell coordinates from (x, y, Value)

d = ieMunsellRenotation('all');
white  = [0.31006 0.31616];
values = unique(d.hvc(:,2));
n = numel(values);

theta = d.hvc(:,1) * pi/50;
x = [d.xyY(:,1); repmat(white(1), n, 1)];
y = [d.xyY(:,2); repmat(white(2), n, 1)];
v = [d.hvc(:,2); values];
a = [d.hvc(:,3).*cos(theta); zeros(n,1)];
b = [d.hvc(:,3).*sin(theta); zeros(n,1)];

guess.a = scatteredInterpolant(x, y, v, a, 'linear', 'nearest');
guess.b = guess.a;
guess.b.Values = b;

end
