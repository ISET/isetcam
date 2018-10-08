function [gammaFit,gammaInputFit,fitComment,gammaParams] = ...
  FitDeviceGamma(gammaRaw,gammaInputRaw,fitType,nInputLevels)
% function [gammaFit,gammaInputFit,fitComment,gammaParams] = ...
%   FitDeviceGamma(gammaRaw,gammaInputRaw,[fitType],[nInputLevels])
%
% Fit the measured gamma function.  Appends 0 measurement,
% arranges data for fit, etc.
% 
% The returned gamma functions are normalized to a maximum of 1.
%
% If present, argument fitType is passed on to FitGamma.
%
% 11/14/06  dhb  Convert for [0-1] universe.  Add nInputLevels arg.
% 5/27/10   dhb  Allow gammaInputRaw to be either a single column or a matrix with same number of columns as devices.
%                Check that last input values are unity.
% 4/12/11   dhb  Return the parameter vector of whatever functional form was fit


%% Set up optional args
if (nargin < 3 || isempty(fitType))
    fitType = [];
end
if (nargin < 4 || isempty(nInputLevels))
    nInputLevels = 256;
end

%% Extract device characteristics
m = size(gammaRaw,2); %#ok<ASGLU>
nDevices = m;

%% Pad with [0 0 0] input/output if this wasn't already 0
gammaInputFit = linspace(0,1,nInputLevels)';
if (size(gammaInputRaw,2) == 1)
    if (gammaInputRaw(1) ~= 0)
      gammaInputRaw = [0 ; gammaInputRaw];
      gammaRaw = [zeros(1,nDevices) ; gammaRaw];
    end
else
    PAD = 0;
    for i = 1:nDevices
        if (gammaInputRaw(1,i) ~= 0)
            PAD = 1;
        end
    end
    if (PAD)
        gammaInputRaw = [zeros(1,nDevices) ; gammaInputRaw];
        gammaRaw = [zeros(1,nDevices) ; gammaRaw];
    end
end

%% Make sure input is monotonic
for i = 1:size(gammaInputRaw,2)
	gammaInputRaw(:,i) = MakeGammaMonotonic(gammaInputRaw(:,i));
end

%% Normalize measurements.  Check that last input was unity
if (size(gammaInputRaw,2) == 1)
    if (gammaInputRaw(end) ~= 1)
      error('Surprised that last input value was not unity for gamma measurements');
    end
else
    UNITY = 1;
    for i = 1:nDevices
        if (gammaInputRaw(end,i) ~= 1)
            UNITY = 0;
        end
    end
    if (~UNITY)
        error('Surprised that at least 1 of last input values was not unity for gamma measurements');
    end
end
gammaRawN = NormalizeGamma(gammaRaw);

%% Do the fit
[gammaFit,gammaParams,fitComment] = FitGamma(gammaInputRaw,gammaRawN,...
                             gammaInputFit,fitType); %#ok<ASGLU>


