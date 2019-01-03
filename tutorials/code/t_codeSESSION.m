%% Add and get objects from the vcSESSION data base
%
% This tutorial also tests whether the ieAddObject and ieGetObject
% routines are running properly, displaying the global vcSESSION
% database variable.
%
% Comments about vcSESSION here.
%

%%
ieInit
global vcSESSION

%%
scene = sceneCreate;

%% This is the database structure
vcSESSION.SCENE
ieAddObject(scene);
vcSESSION.SCENE{1}.data

%% Get the scene and show it
test = ieGetObject('scene');
sceneWindow;

%% You can also just put the scene in the argument to add another copy
sceneWindow(scene);
vcSESSION.SCENE

%% END
