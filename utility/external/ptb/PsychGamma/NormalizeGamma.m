function [gammaOut] = NormalizeGamma(gamma)
% [gammaOut] = NormalizeGamma(gamma)
%
% Normalizes a gamma curve so that the end value is 1.0
%
% 9/22/93   jms   Added comment
% 3/15/94	dhb, jms Normalize to last value, not max value.
% 5/27/10   dhb   Cosmetic

[m,nil] = size(gamma); %#ok<NASGU>
normVals = gamma(m,:);
gammaOut = gamma ./ (ones(m,1)*normVals);
