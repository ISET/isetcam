function y = gammaPDF(t, tau, n)
% Gamma function - used for impulse response calculations and HIRF
%
% Syntax:
%	y = gammaPDF(t, [tau], [n])
%
% Description:
%    The gamma is essentially the convolution of n exponentials with time
%    constant of tau. The peak of the function is near tau * n
%
%    See formula various places, but Boynton et al. is a good place.
%
%    This is used to set the center and surround response in some of our
%    cell response modeling, although sometimes we use twoGammaResp.
%
%    For a reference to RGC impulse response functions see:
%      Udi Kaplan and Ethan Bardete (Chapter 2) They dynamics of primate
%      retinal ganglion cells Progress in Brain Research  2001, vol 134.
%
%    Examples are provided in the code.
%
% Inputs:
%    t   - Vector of input times.
%    tau - (Optional) Scalar. Time constant of the gamma. Default 1.
%    n   - (Optional) Scalar. The number parameter of the gamma. Default 2.
%
% Outputs:
%    y   - The gamma as a function of passed time.
%
% Optional key/value pairs:
%    None.
%  
% See Also:
%    twoGammaResp

% History
%    01/20/18  dhb  Fixed examples so they all work when run in a clean
%                   workspace. Document inputs and outputs.
%    01/24/18  jnm  Formatting

% Examples:
%{
    t = 0:0.01:1;
    tau = .05;
    n = 2;
    y = gammaPDF(t, tau, n);
    plot(t, y)
%}
%{
    t = 0:0.01:1;
    tau = .05;
    n = 4;
    y = gammaPDF(t, tau, n);
    plot(t, y)
%}
%{
    t = 0:0.01:1;
    tau = .03;
    n = 3;
    c = gammaPDF(t, tau, n);
    plot(t, c)
%}
%{
    %  Something like an RGC impulse response.
    t = 0:0.005:0.3;
    tau = .01;
    n = 3;
    c = gammaPDF(t, tau, n);
    plot(t, c)
    tau = 0.02;
    n = 3;
    s = gammaPDF(t, tau, n);
    plot(t, s)
    plot(t, c - 0.9 * s)
    grid on
%}

if notDefined('t'), error('Time steps required'); end
if notDefined('tau'), tau = 1; end
if notDefined('n'), n = 2; end

% After Boynton et al. See boyntonHIRF in mrVista
nCurves = length(tau);
for ii=1:nCurves
    y = (t ./ tau(ii)).^(n-1) .* exp(-t ./ tau(ii)) ...
        / (tau(ii) * factorial(n - 1));
    y = y / sum(y);
end

if y(end) / max(y) > 0.1
    warning('The total duration (t) is probably too short.');
end

end
