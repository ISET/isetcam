function [Sens, fs, ft] = kellySpaceTime(fs, ft)
% Formula for space-time sensitivity (1/threshold) from Kelly, 1979
%
% Syntax:
%   [Sens, fs, ft] = kellySpaceTime(fs, ft)
%
% Description:
%    Reference: Kelly (1979) JOSA, v. 69, no. 10, p. 1340
%    Motion and vision.  II. Stabilized spatio-temporal threshold surface
%    The space-time sensitivity function is defined in Equation 8.
%
%    This function contains examples of usage inline. To access, type 'edit
%    kellySpaceTime.m' into the Command Window.
%
% Inputs:
%    fs   - (Optional) Vector. The spatial frequencies, in cycles per
%           degree. Default is 10 .^ (-.5:.05:1.3).
%    ft   - (Optional) Vector. The temporal frequencies, in hertz. Default
%           is 10 .^ (-.5:.05:1.7).
%
% Outputs:
%    Sens - Matrix. The space-time sensitivity.
%    fs   - Matrix. The spatial frequencies.
%    ft   - Matrix. The temporal frequences.
%
% Optional key/value pairs:
%    None.
%
% See Also:
%    humanSpaceTime
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/29/18  jnm  Formatting

% Example:
%{
    [Sens, fs, ft] = kellySpaceTime;
    surf(fs, ft, Sens);
    set(gca, 'zscale', 'log', 'yscale', 'log', 'xscale', 'log')
%}

if notDefined('fs'), fs = 10 .^ (-.5:.05:1.3); end
if notDefined('ft'), ft = 10 .^ (-.5:.05:1.7); end

[ft, fs] = meshgrid(ft, fs);

% Kelly '79 formula
alpha = 2 * pi * fs;
v = ft ./ fs;  %nu
k = 6.1 + 7.3 * (abs(log10( v / 3 ))) .^ 3;
amax = 45.9 ./ (v + 2);
Sens = k .* v .* (alpha .* alpha) .* exp(-2 * alpha ./ amax);

% Pull out the values above 1;
Sens(Sens < 1) = NaN;

% [Note: XXX - A student in Australia pointed out that to make this work
% for standing, rather than traveling, waves we need to plot Sens/2 (see
% Kelly, 1979, p. 1341 and related discussion.]
%
Sens = Sens/2;

end

% surf(ft, fs, G)
% set(gca, 'FontName', 'Bookman')
% set(gca, 'FontSize', 16)
%
% view(53, 40)
% set(gca, 'zscale', 'log', 'xscale', 'log', 'yscale', 'log');
% set(gca, 'zlim', [0.5 300], 'xlim', [mmin(ft) 1.2 * mmax(ft)], ...
%    'ylim', [mmin(fs), 1.2 * mmax(fs)]);
% set(gca, 'xtick', [1 2 4 8 16 32], 'ytick', [1 2 4 8 16 32], ...
%    'ztick', [1 10 100])
% grid on
% colormap(0.5 + gray(100) * 0.5)

% %
% %    TO print out for book
% %
%
% mp = [0.5 * gray(64) + .5];
% colormap(mp)

%
%    This makes figure 9 in Kelly 1979
%
% fs = [.1 .2 .4 .8 1.6 3.2 6.4 12.8 25];
% alpha = 2 * pi * fs;
%
% v = 3;
% k = 6.1 + 7.3 * abs(log10(v / 3) .^ 3)
% amax = 45.9 ./ (v + 2);
% G1 = k * v * (alpha .^ 2) .* exp( -2 * (alpha / amax ));
% plot(fs, G1)
% set(gca, 'xscale', 'log', 'yscale', 'log', 'xlim', [.15 8], ...
%     'ylim', [1 1000]);
%
% v = 32;
% k = 6.1 + 7.3 * abs(log10(v / 3) .^ 3)
% amax = 45.9 ./ (v + 2);
% G2 = k * v * (alpha .^ 2) .* exp( -2 * (alpha / amax ));
% plot(fs, [G1;G2])
% set(gca, 'xscale', 'log', 'yscale', 'log', 'xlim', [.15 8], ...
%     'ylim', [1 1000]);
%
