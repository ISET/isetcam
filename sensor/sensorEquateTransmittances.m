function filters = sensorEquateTransmittances(filters)
% Equate filter transmittance (total) of filters
%
%   filters = sensorEquateTransmittances(filters)
%
% Equate the area under the curves of a set of color filters (in the
% columns of filters).  After scaling individual, the routine resets the
% peak of all the filters so that the overall peak is 1.0.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Divide each by its own area to equate for area
filterArea = sum(filters);
filters = filters*diag(1./filterArea);

% Scale to an overall (not individual filter) peak of 1
filterPeak = max(filters(:));
filters = filters*(1/filterPeak);

return;