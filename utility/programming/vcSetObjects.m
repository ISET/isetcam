function vcSetObjects(objType,newObj)
% Set the cell array of a particular type of object.
%
% Synopsis
%  vcSetObjects(objType,newObj);
%
% Description
%  Updates the cell array of objects of a particular type
%
% Example:
%  scenes = vcSESSION.SCENE;
%  n = length(scene);
%  scenes = scene{1:n-1};
%  vcSetObject('SCENE',scenes);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ieSessionSet
%

global vcSESSION;

objType = vcEquivalentObjtype(objType);

% eval(['vcSESSION.',objType,' = newObj;']);
vcSESSION.(objType) = newObj;

end

