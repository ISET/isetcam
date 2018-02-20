function [sOBJECT,val] = vcGetObject(objType,val)
% Retrieve an object from the ISET global database
%
%   [sOBJECT,val] = vcGetObject(objType,[val])
%
% The currently selected objects have the following possible types:
%
%  SCENE, {OPTICALIMAGE,OI}, {IMGPROC,VCIMAGE,VCI}, GRAPHWIN, {ISA,SENSOR}
%
% This routine replaces: [val,sOBJECT] = vcGetSelectedObject('SCENE');
%
% The new call is shorter as in:
%
%  obj     = vcGetObject('SCENE');
%  pixel   = vcGetObject('PIXEL')
%  ip      = vcGetObject('VCIMAGE')
%  ip      = vcGetObject('IMGPROC')
%  oi      = vcGetObject('OI')
%  optics  = vcGetObject('optics');
%  display = vcGetObject('display');
%
%  If you need the val, you can still use
%
%    [obj,val] = vcGetObject('SCENE');
%
% See also:  ieGetObject() is preferred now.
%
% Copyright ImagEval Consultants, LLC, 2003.

%%  vcSESSION is used in the eval.
global vcSESSION 

% For speed, do not use ieNotDefined()
if ~exist('objType','var') || isempty(objType), error('objType must be defined'); end
if isempty(vcSESSION)
    errordlg('Please start ISET to initialize vcSESSION.');
    return;
end
if ~exist('val','var') || isempty(val), val = vcGetSelectedObject(objType); end


%%  Find the object
objType = vcEquivalentObjtype(objType);
if ~isempty(val)
    switch(lower(objType))
        case {'scene','isa','opticalimage','vcimage','display'}
            eval(['sOBJECT = vcSESSION.',objType,'{val};']);
        otherwise
            error('Unknown object type: %s.',objType);
    end
else
    % No val.  Return empty.
    sOBJECT = []; val = [];
end

end
