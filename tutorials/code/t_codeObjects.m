%% t_codeObjects
%
%  Deprecated
%
% Copyright Imageval LLC, 2013

%% ISET objects
%
% ISET code is mainly based on several essential objects:
%   scenes
%   optical image (oi)
%   optics
%   sensors,
%   pixels
%   image processor (ip, also called virtual camera image, vci).
%
% ISET stores these objects in a global data structure, vcSESSION.
% These objects are accessed by the related windows.
%
% When you run ISET, the global variable vcSESSION is created in your base
% workspace. You shouldn't interact with this variable directly.  Some ISET
% functions add objects to this variable and set parameters.
%
% The main functions that manage the global properties are
%
% vcGetObject, ieAddObject, ieSessionSet, ieSessionGet
% %
%
% %% Example
%
% % Once you run ISET, the vcSESSION variable is created.
% ISET
%
% %
% vcSESSION
%
% % This example
% scene = sceneCreate;
%
% ieAddObject(scene);
% vcSESSION
%
% scene = vcGetObject('scene');
% oi    = vcGetObject('oi')
% optics= vcGetObject('optics');
%
% % Screwing around for now ...
%
% sceneWindow
% optics = vcGetObject('optics');
% disp(optics)
% optics = opticsSet(optics,'fnumber',16);
% ieReplaceObject(optics);
% oiWindow
