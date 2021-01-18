function estP = ieLineAlign(D1,D2)
% Aligns the data in D1 and D2 by a shift and scale
%
% Synopsis
%  estP = ieLineAlign(D1,D2);
%
% Inputs
%   D1 - D1.x, D1.y  (y = f(x))
%   D1 - D1.x, D2.y
%
% Output
%  estP - Estimated parameters so that
%
% Description
%  The two sets of data are presumed to be related by a shift and scale of
%  the x-axis such that:
%
%     D2.x = estP(1)*(D1.x - estP(2))
%
%  We estimate the two parameters (estP). These are selected to convert the
%  D2 data into the D1 data by rescaling the x-axis as in
%
%     xScaledEst =  interp1(D2.x, D2.y, D2.x/p(1) + p(2));
%     D1.y ~ xScaledEst
%
% See also
%  s_figuresEI2021.mlx (isetcornellbox)

% Examples:
%{
% The shift and stretch of the x axis
D1.x = -50:50;
D1.y = D1.x.^2;

% The same function applied to each
s1 = 2.5; s2 = 15;
D2.x = s1*(D1.x - s2);
D2.y = D1.x.^2;
plot(D1.x,D1.y,'k--',D2.x,D2.y,'r:');

p = ieLineAlign(D1,D2)

%
xRescaled = (D2.x/p(1)) + p(2);
xScaledEst =  interp1(D2.x, D2.y, xRescaled);
l = ~isnan(xScaledEst);

% Compare
ieNewGraphWin;
plot(D1.x,D1.y,'k--',xRescaled(l),xScaledEst(l),'r:');

%}

p = [1,0];

options = optimset(@fminsearch);

estP = fminsearch(@sseval,p,options,D1,D2);

end

%%
function e = sseval(p,D1,D2)
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
est = interp1(D2.x, D2.y, D2.x/p(1) + p(2));

%{
% If there is a 3rd parameter we scale the result.
if numel(p) == 3
    est = est*p(3);
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
e = sum( (D1.y(l) - est(l)).^2);

end