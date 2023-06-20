function parms = FOTParams
% Default parameters for the frequency orientation target
%
% See also
%   FOTarget, sceneCreate
%

% Old defaults
parms.angles    = linspace(0,pi/2,8);
parms.freqs     = 1:8;
parms.blockSize = 32;
parms.contrast  = 1;

end