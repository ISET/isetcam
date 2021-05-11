function scene = sceneInitGeometry(scene)
% Initialize scene distance parameter.
%
%   scene = sceneInitGeometry(scene);
%
%  We are leaving this trivial routine here for potential future
%  development.
%
%  If the parameter is already set, then it is not modified by this
%  routine.
%
% Copyright ImagEval Consultants, LLC, 2003.


% Set scene distance in meters
if ~isfield(scene, 'distance') scene = sceneSet(scene, 'distance', 1.2); end

return;