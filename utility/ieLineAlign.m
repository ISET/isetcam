function [estP, estY] = ieLineAlign(D1, D2)
% Aligns the data in D1 and D2 by a shift and scale
%
% Synopsis
%  [p, estY] = ieLineAlign(D1,D2);
%
% Inputs
%   D1 - a struct with x,y such that D1.x, D1.y = func(D1.x))
%   D2 - a struct with x,y such that D2.x, D2.y = func(p(1)*(D2.x - p(2)))
%
% Output
%   p    - Estimated scale (p(1)) and shift (p(2)) parameters. (The
%          infrastructure for scaling) the y-value is also in place.
%   estY - The D2.y value we would have observed after accounting for the
%          scale and shift on the x-axis
%
% Description
%  The two data sets are related by a shift and scale of the x-axis such
%  that:
%
%     D2.x = p(1)*(D1.x - p(2))
%
%  The y-values are built on the same function,
%
%     D1.y = func(D1.x)
%     D2.y = func(D2.x) = func(p(1)*(D1.x - p(2)));
%
%  *ieLineAlign* estimates the scale and shift parameters (p). If they are
%  correctly estimated, then the D1 plot should align with the D2 plot
%  after we scale and shift the D2.x values
%
%     plot(D1.x, D1.y, 'k--', p(1)*(D2.x - p(2)), D2.y,'r-');
%
%  Also, the estY returned variable is D2.y after correcting for the  scale
%  and shift, in the sense that D1.y and estY are the same when plotted
%  against D1.x
%
%      plot(D1.x,D1.y,'k--', D1.x, estY,'r-');
%
% See also
%  s_figuresEI2021.mlx (isetcornellbox)

% Examples:
%{
% Here is a simple function
D1.x = -50:50;
func = @(x)(0.3*x.^2 + 12*x - 5);
D1.y = func(D1.x);

% Here is the same function but with x shifted and scaled
D2.x = D1.x;    % Sample the same points

% But the measurements were shifted and scaled
s1 = 1.2; s2 = 3;
ssX = s1*(D1.x - s2);

% The function with some noise.
D2.y = (func(ssX) + randn(size(ssX))*5);

plot(D1.x,D1.y,'k--',D2.x,D2.y,'r-');

% This function tries to find s1 and s2
% Some of the estimated values are NaN.
[p, estY] = ieLineAlign(D1,D2);

% If we shift and scale the x values of D2, we should have a plot that
% matches D1.
plot(D1.x,D1.y,'k--', p(1)*(D2.x - p(2)), D2.y,'r-');
set(gca,'xlim',[-40 40]);

% The same plot using the estimated Y values returned by ieLinAlign
plot(D1.x,D1.y,'k--', D1.x, estY,'r-');
set(gca,'xlim',[-40 40]);

%}

% This also can work with a third term to scale the y output.
% Maybe I should work harder at it. (BW).
p = [1, 0];

options = optimset(@fminsearch);

estP = fminsearch(@sseval, p, options, D1, D2);

if nargout == 2
    [~, estY] = sseval(estP, D1, D2);
end

end

%%
function [e, est] = sseval(p, D1, D2)
% Shift and scale the x-axis to match D1 to D2.
%
% Synopsis
%   e = sseval(p,D1,D2)
%
% Called by fminsearch in testShiftScale
%
% Input
%   p  - Up to three parameters (x-scale, x-shift, y-scale)
%   D1 - data set 1, D1.x, D1.y
%   D2 - data set 2, D2.x D2.y
%
% D2.x = p(1)*(D1.x - p(2))  % Shift/scale x-axis
%
% See also testShiftScale

% We assume that D2x = p(1)*(D1x - p(2))
%
% So to invert the scale and shift, we set the new values to
%
%      D2.x/p(1) + p(2)
%
% The estimate for the shifted and scaled values are
% est = interp1(D2.x, D2.y, D2.x/p(1) + p(2));

% If we shift and scale D2's x value and measure at D1's x value,
% we want the new est to match D1.x,D1.y
% est = interp1(D2.x/p(1) + p(2), D2.y, D1.x);
est = interp1(p(1)*(D2.x - p(2)), D2.y, D1.x);

%{
% If there is a 3rd parameter we scale the result.
if numel(p) == 3
    est = est/p(3);
end
%}

% Sometimes we are out of range and we get NaN values for some of the
% estimates.  So we don't count those.  We should check if there are a lot
% of them.
l = ~isnan(est);

% Sum of squared error.  Allow a shift up and down of the axis?  Or maybe a
% scale?
% A = mean(D1.y(l));
% B = mean(est(l));
e = sum((D1.y(l) - est(l)).^2);

end
