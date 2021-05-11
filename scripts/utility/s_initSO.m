%% Initialize a Scene and OI
%
%  s_initSO
%
% This should become a function that returns a scene and oi and can define
% some of the parameters
%
% function [scene, oi] = initSO('param',val,'param',val);
%

disp('Adding default scene and oi to vcSESSION.');
scene = sceneCreate;
ieAddObject(scene);

oi = oiCreate;
oi = oiCompute(oi, scene);
ieAddObject(oi);

%% END