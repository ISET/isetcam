function output = SPDToLinSPD(input,B)
% output = SPDToLinSPD(input,B)
% 
% Find the best fitting spectrum within a linear model.
%
% output - spectrum within the linear model
%  (n-wavelengths by number-of-lights)
% input - source spectral power distribution
%  (n-wavelengths by number-of-lights)
% B - linear model for spectral power distributions
%  (number-of-wavelengths by n-dimension)
%
% History:
% 30/11/07  Change call to non-existent SPDToLinWgts.m into call to 
%           FindModelWeights.m, as suggested by Mickey Rowe.         (MK)

% Just expand the weights, which we find 
% in function FindModelWeights
output = B*FindModelWeights(input,B);
