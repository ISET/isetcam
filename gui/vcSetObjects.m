function vcSetObjects(objType,newObj);
% Set the cell array of a particular type of object.  
%
%  vcSetObjects(objType,newObj);
%
% Example:
%  scene = vcSESSION.SCENE;
%  n = length(scene);
%  scene = scene{1:n-1};
%  vcSetObject('SCENE',scene);
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION;

objType = vcEquivalentObjtype(objType);

eval(['vcSESSION.',objType,' = newObj;']);

return;
