function [sOBJECT,val] = ieGetObject(objType,val)
%Retrieve an object from vcSESSION structure
%
%   [sOBJECT,val] = ieGetObject(objType,[val])
%
% Find the currently selected object of the various possible types:
%
%  SCENE, PIXEL,{OPTICALIMAGE,OI}, {IMGPROC,VCIMAGE,VCI},DISPLAY
%  OPTICS, IPDISPLAY, GRAPHWIN, {ISA,SENSOR},  
%
% This routine replaces: [val,sOBJECT] = vcGetSelectedObject('SCENE');
% This call is shorter as in:
%
%  obj    = ieGetObject('SCENE');
%  pixel  = ieGetObject('PIXEL')
%  vci    = ieGetObject('VCIMAGE')
%  vci    = ieGetObject('IMGPROC')
%  oi     = ieGetObject('OI')
%  dsply  = ieGetObject('DISPLAY')
%  dsply  = ieGetObject('IPDISPLAY');
%  optics = ieGetObject('optics');
%
%  If you need the val, you can still use
%
%    [obj,val] = ieGetObject('SCENE');
%
% Comment:  We still have a lot of vcGetObject() calls in the code.  But
% this one is now preferred.
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
global vcSESSION

% For speed
if ~exist('objType','var') || isempty(objType), error('objType must be defined'); end
if isempty(vcSESSION)
    errordlg('Please start ISET to initialize vcSESSION.');
    return;
end
if ~exist('val','var') || isempty(val), val = vcGetSelectedObject(objType); end

objType = vcEquivalentObjtype(objType);

%%
if ~isempty(val)
    switch(lower(objType))
        case {'scene','isa','opticalimage','vcimage','display'}
            eval(['sOBJECT = vcSESSION.',objType,'{val};']);
        case {'pixel'}
            sOBJECT = sensorGet(vcSESSION.ISA{val},'pixel');
        case {'optics'}
            sOBJECT = oiGet(vcSESSION.OPTICALIMAGE{val},'optics');
        case {'ipdisplay'}
            sOBJECT = ipGet(vcSESSION.VCIMAGE{val},'display');
        otherwise
            error('Unknown object type.');
    end
else
    % No val.  Return empty.
    sOBJECT = [];
    % warning('No object found');
end

return
