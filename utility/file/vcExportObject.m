function fullName = vcExportObject(obj,fullName,clearDataFlag)
% Save an object into the relevant object directory
%
%     fullName = vcExportObject(obj,[fullName],[clearDataFlag=0]);
%
% Save the parameters of a vcSESSION object in a .mat file.  The object
% parameters can be loaded at a later time.  In the future, we will
% support exporting to formats other than Matlab files, which is why this
% routine exists.  And we may allow exporting the data as well.
%
% If fullName is not specified, a GUI opens to choose the name.
%   
% Examples
%  fullName = vcExportObject(scene,'c:\myhome\ISET-Objects\SCENE\myCompany');
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'), error('You must define an object to save.'); end
if ieNotDefined('clearDataFlag'), clearDataFlag = 0;   end
if ieNotDefined('fullName'),    fullName = []; end

objType = obj.type;
objType = vcEquivalentObjtype(objType);

switch(lower(objType))     
    case {'scene','opticalimage','isa','vcimage'}
        if clearDataFlag, obj.data = []; end
        
    case 'optics'
        
    otherwise
        error('Unknown object type');
end

fullName = vcSaveObject(obj,fullName);


return;

