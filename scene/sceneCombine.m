function scene = sceneCombine(scene1,scene2,keyval)
% Combine a pair of scenes
%
% Synopsis
%
% Input
%   scene1 - The two scenes should have the same wavelength samples
%   scene2 -
%
% Optional Key/val pairs
%   direction - horizontal, vertical, or both.
%
%      Depending on the direction, the number of rows ('horizontal') or
%      cols ('vertical') must be equal.  If 'both', then we first combine
%      'horizontal' so the rows must be equal. If 'centered' we make a 3x3
%      version
%                s2 s2 s2
%                s2 s1 s2
%                s2 s2 s2
%
% Return
%   scene - The combined scene
%
% ieExamplesPrint('sceneCombine');
%
% See also
%

% Examples:
%{
scene = sceneCombine(sceneCreate,sceneCreate,'direction','horizontal');
sceneWindow(scene);
%}
%{
scene = sceneCombine(sceneCreate('rings rays'),sceneCreate('rings rays'),'direction','vertical');
sceneWindow(scene);
%}
%{
scene = sceneCombine(sceneCreate,sceneCreate,'direction','both');
sceneWindow(scene);
%}
%{
scene = sceneCombine(sceneCreate,sceneCreate,'direction','centered');
sceneWindow(scene);
%}

arguments
    scene1 struct
    scene2 struct
    keyval.direction {mustBeMember(keyval.direction, {'vertical','horizontal','both','centered'})} = 'horizontal'
end
%%  Determine direction and merge

assert(isequal(sceneGet(scene1,'wave'),sceneGet(scene2,'wave')));

if isequal(keyval.direction,'horizontal')
    
    assert(isequal(sceneGet(scene1,'rows'),sceneGet(scene2,'rows')));
    
    photons = [sceneGet(scene1,'photons'), sceneGet(scene2,'photons')];
    
    scene = scene1;
    scene = sceneSet(scene,'photons',photons);
    scene = sceneSet(scene,'h fov',sceneGet(scene1,'fov') + sceneGet(scene2,'fov'));
    
elseif isequal(keyval.direction,'vertical')
    assert(isequal(sceneGet(scene1,'cols'),sceneGet(scene2,'cols')));
    
    photons = [sceneGet(scene1,'photons'); sceneGet(scene2,'photons')];
    scene = scene1;
    scene = sceneSet(scene,'photons',photons);
    % No change in horizontal field of view
    
elseif isequal(keyval.direction,'both')
    scene = sceneCombine(scene1,scene2,'direction','horizontal');
    scene = sceneCombine(scene,scene,'direction','vertical');
    
elseif isequal(keyval.direction,'centered')
    % 3x3 version (scene2 scene1 scene2) in the middle and
    % (scene2, scene2, scene2) across the upper and lower rows
    % Often in this case scene1 = scene2;
    sceneMid = sceneCombine(scene1,scene2,'direction','horizontal');
    sceneMid = sceneCombine(scene2,sceneMid,'direction','horizontal');
    sceneEdge = sceneCombine(scene2,scene2,'direction','horizontal');
    sceneEdge = sceneCombine(sceneEdge,scene2,'direction','horizontal');
    scene = sceneCombine(sceneEdge,sceneMid,'direction','vertical');
    scene = sceneCombine(scene,sceneEdge,'direction','vertical');
    
else
    error('Unknown direction %s\n',NameValueArgs.direction);
end

end
