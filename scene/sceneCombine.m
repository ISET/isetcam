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
%   direction - horizontal or vertical.  Depending on the choice the number
%       of rows (horizontal) or cols (vertical) must be equal
%
% Return
%   scene - The combined scene
%
% See also
%

%{
scene = sceneCombine(sceneCreate,sceneCreate,'direction','horizontal');
sceneWindow(scene);
%}
%{
scene = sceneCombine(sceneCreate('rings rays'),sceneCreate('rings rays'),'direction','vertical');
sceneWindow(scene);
%}
%{
scene = sceneCombine(sceneCreate,sceneCreate,'direction','horizontal');
scene = sceneCombine(scene,scene,'direction','vertical');
sceneWindow(scene);
%}

arguments
    scene1 struct
    scene2 struct
    keyval.direction {mustBeMember(keyval.direction, {'vertical','horizontal'})}
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
    assert(isequal(sceneGet(scene1,'rows'),sceneGet(scene2,'rows')));
    
    photons = [sceneGet(scene1,'photons'); sceneGet(scene2,'photons')];
    scene = scene1;
    scene = sceneSet(scene,'photons',photons);
    % No change in horizontal field of view
    
else
    error('Unknown direction %s\n',NameValueArgs.direction);
end

end
