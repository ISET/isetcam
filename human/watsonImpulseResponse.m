function [impResp, t, tMTF, freq] = ...
    watsonImpulseResponse(t, transientFactor)
% Implementation of the Watson impulse response function
%
% Syntax:
%   [impResp, t, tMTF, freq] = watsonImpulseResponse(t, transientFactor)
%
% Description:
%    Calculation for time points t (in sec). All entries of t must be > 0.
%
%    This function contains examples of usage inline. To access, type 'edit
%    watsonImpulseResponse.m' into the Command Window.
%
% Inputs:
%    t               - (Optional) Vector. Time points vector. Default is
%                      [0.001:0.002:1.00] seconds.
%    transientFactor - (Optional) Numeric. Transient factor. Default is 0.5
%
% Outputs:
%    impResp         - Vector. The impulse response.
%    t               - Vector. The time points vector.
%    tMTF            - Vector. The modulation transfer function.
%    freq            - Vector. The frequencies.
%
% Optional key/value pairs:
%    None.
%
% References:
%   This formula and the rationale for it are defined in Basic Sensory
%   Processing:Temporal Sensitivity, Boff et al. Chapter 6, equations 40-41
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    07/04/18  jnm  Formatting

% Examples:
%{
    figure;
    t = (0.00:0.005:0.5);
    [iResp, t] = watsonImpulseResponse(t);
    plot(t, iResp);
    grid on;
%}
%{
    t = (0.00:0.005:0.5);
    [h1, t] = watsonImpulseResponse(t, 0);
    h1Plush2 = watsonImpulseResponse(t, -1);
    h2 = h1Plush2 - h1;
    plot(t, h1, 'g-', t, -1 * h2, 'r--');
%}

if notDefined('t'), t = 0.001:0.002:1.00; end
if notDefined('transientFactor'), transientFactor = 0.5; end

% t must be greater than 0. Sorry for that.
tmp = t(t > 0);
t = tmp;

% When transientFactor is 0, the response is sustained, with only a
% positive lobe.

tau = 0.00494;
kappa = 1.33;
n1 = 9;
n2 = 10;

h1 = ((t / tau) .^ (n1 - 1)) .* exp(-t ./ tau) ./ (t .* factorial(n1 - 1));
% plot(t, h1)
h2 = ((t / (kappa * tau)) .^ (n2 - 1)) .* exp(-t ./ (kappa * tau)) ...
    ./ (t .* factorial(n2 - 1));
% plot(t, h2)
% plot(t, h1, 'g-', t, h2, 'r--')

impResp = h1 - transientFactor * h2;
% plot(t, impResp)

% Always return a unit area so that a constant input yields a constant
% output at the same level
impResp = impResp / sum(impResp(:));

% If the user asks ...
if nargout > 2, tMTF = abs(fft(impResp)); end
if nargout > 3, freq =1 / max(t) * (1:length(t)); end

% l = (freq < 100);
% plot(freq(l), tMTF(l));
% grid on

end