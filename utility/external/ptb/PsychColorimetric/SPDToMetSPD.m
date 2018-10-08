function output = SPDToMetSPD(input,T,B)
% output = SPDToMetSPD(input,T,B)
% 
% Convert spectral power distribution
% to another metameric spectral power distribution.
%
% output - metameric spectral power distribution
%  (number-of-wavelengths by number-of-lights)
% input - source spectral power distribution
%  (number-of-wavelengths by number-of-lights)
% T - source color matching functions
%  (n-chromacy by number-of-wavelengths)
% B - linear model for spectral power distributions
%  (number-of-wavelengths by at least n-chromacy)

% Extract the first nchromacy basis functions
% from the passed model.
[nchromacy,nwavelengths] = size(T);
B = B(:,1:nchromacy);

% Get the tristimulus coordinates
tristim = T*input;

% Get the linear model weights from the trisimtulus coordinates
% This is exactly what the routine CMToPri does
weights = CMToPri(tristim,T,B);

% Expand the weights back to spectral power distributions
output = B*weights;
