function [coneIsolating, spd] = humanConeIsolating(dsp)
% Each column has linear (R, G, B) that is cone isolation
%
% Syntax:
%   [coneIsolating, spd] = humanConeIsolating(display)
%
% Description:
%    The columns of coneIsolating are the linear RGB vector directions that
%    isolate the L, M, and S (Stockman) cones. The linear RGB are scaled so
%    that max(abs(x)) = 0.5, making it possible to add these vectors into a
%    background with linear RGB of [0.5, 0.5, 0.5]
%
%    The Examples show how to calculate with the display spectral power
%    distribution of the monitor to compute cone contrast.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanConeIsolating.m' into the Command Window.
%
% Inputs:
%    dsp           - Struct. A display model (displayCreate)
%
% Outputs:
%    coneIsolating - Matrix. The linear RGB cone isolating values, scaled
%                    to max(abs(x)) = 0.5
%    spd           - Matrix. The spectral power distributions of the three
%                    directions (x, y, and z).
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Note: JNM - The first example does not appear to use the function
%      whatsoever, is there a reason why it is included here?]
%
% See Also:
%    humanConeContrast, displayCreate
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/13/18  jnm  Formatting

% Examples:
%{
    % Set the default color order starting with RGB
    co = [1  0  0;
      0 0.5 0;
      0  0  1;
      0 0.75 0.75;
      0.75 0 0.75;
      0.75 0.75 0;
      0.25 0.25 0.25];
    set(groot, 'defaultAxesColorOrder', co)
%}
%{
    % Calculate RGB directions for cone isolation on this monitor
    dsp = displayCreate('LCD-Apple');
    [rgbDirs, spd] = humanConeIsolating(dsp);
    disp(rgbDirs)
%}
%{
    % Make it work
    dsp = displayCreate('LCD-Apple');
    [rgbDirs, spd] = humanConeIsolating(dsp);

    % Plot the spd
    wave = displayGet(dsp, 'wave');
    vcNewGraphWin;
    plot(wave, spd);
    grid on
    xlabel('Wave (nm)');
    ylabel('Relative energy')
    legend('L-isolating', 'M-isolating', 'S-isolating');
%}
%{
    % Make it work
    dsp = displayCreate('LCD-Apple');
    [rgbDirs, spd] = humanConeIsolating(dsp);
    wave = displayGet(dsp, 'wave');

    % Check that these spd values are cone isolating
    coneFile = fullfile(isetbioDataPath, 'human', 'stockman');
    cones = ieReadSpectra(coneFile, wave);
    id = cones' * spd;
    id = id / max(id(:))
%}

% This is a row transform, [r, g, b] * rgb2lms
coneIsolating = displayGet(dsp, 'lms2rgb');

% Convert to the column form for easier computing
coneIsolating = coneIsolating';

% Scale so that the largest value in any column is abs(0.5)
% That way, when we add these into a background that is 0.5, 0.5, 0.5 we
% get a realizable display stimulus
mx = max(abs(coneIsolating));
coneIsolating = coneIsolating ./ (2 * mx);

% If the user asked for the three spds, compute them
if nargout == 2, spd = displayGet(dsp, 'spd') * coneIsolating; end

end
