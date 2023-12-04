function ls = westheimerLSF(xSec)
% Westheimer line spread function
%
% Syntax:
%   ls = westheimerLSF(xSec)
%
% Description:
%    Spatial position is x in secs of arc of visual angle.
%
%    Westheimer calculated that the linespread function of the human eye,
%    specified in terms of minutes of arc and using a 3mm pupil, should be
%    approximated using the following formula
%
%      LineSpread = 0.47 * exp(-3.3 * (x .^ 2)) + ...
%           0.53 * exp(-0.93 * abs(x));
%
%    This function contains examples of usage inline. To access, type 'edit
%    westheimerLSF.m' into the Command Window.
%
% Inputs:
%    xSec - (Optional) Vector. The Spatial samples. Default is -300:1:300.
%
% Outputs:
%    ls   - Vector. Line spread function
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    07/09/18  jnm  Formatting

% Examples:
%{
    vcNewGraphWin;
    xSec = -300:300; % Open window and set spatial samples
    plot(xSec, westheimerLSF(xSec));
    grid on; % Plot the line spread
    xlabel('Position (arc sec)');
    ylabel('Relative intensity');
%}
%{
    xSec = -300:300;
    westheimerOTF = abs(fft(westheimerLSF(xSec)));
    % (One cycle spans 10 min of arc, so freq=1 is 6 cyc/deg)
    freq = [0:11] * 6;
    vcNewGraphWin;
    semilogy(freq, westheimerOTF([1:12]));
    grid on;
    xlabel('Freq (cpd)');
    ylabel('Relative contrast');
    set(gca, 'ylim', [0.01 1.1])
%}

if notDefined('xSec'), xSec = -300:1:300; end

xMin = xSec / 60;
ls = 0.47 * exp(-3.3 *(xMin .^ 2)) + 0.53 * exp(-0.93 * abs(xMin));
ls = ls / sum(ls);

end
