function scene = sceneClearData(scene)
%  Clear the scene data entries.
%
%   scene = sceneClearData(scene)
%
% Copyright ImagEval Consultants, LLC, 2003.

% We do not use bit depth any more.  Data are singles.
% bitDepth = sceneGet(scene,'bit depth');

scene = sceneSet(scene, 'data', []);
% scene = sceneSet(scene,'bit depth',bitDepth);

%% What about the illuminant?  Should we leave it alone?
% scene = sceneSet(scene,'illuminant energy',[]);

return;