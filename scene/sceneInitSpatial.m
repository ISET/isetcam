function scene = sceneInitSpatial(scene)
%Initialize the scene field of view to 10 deg.
%
%     scene = sceneInitSpatial(scene)
%
%  This field of view is small as most cameras see a 40 deg.  But it is the right size for
%  a small sensor at 8 um and 100x100, as we use for many evaluations.
%
%  We are leaving this trivial routine here for potential future
%  development.
%
%  If the parameter is already set, then it is not modified by this
%  routine.
%
% Copyright ImagEval Consultants, LLC, 2003.


% Degrees
if ~checkfields(scene, 'wAngular'), scene = sceneSet(scene, 'fov', 10); end

return;
