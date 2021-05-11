function fullName = vcSaveObject(obj, fullName)
% Save an ISET object into a .mat file.
%
%   fullName = vcSaveObject(obj,[fullName]);
%
% Users should generally use vcExportObject.
%
% If you must use this routine:
%
% The object is saved with the proper type of name so that it can be loaded
% using vcLoadObject() at a later.  When called directly, the parameters
% and data are all saved.
%
% If you wish to save only the parameters, without the data, then use
% vcExportObject and set the clearDataFlag.
%
% The ISET objects that can be saved are:
%
%   SCENE,OPTICALIMAGE,OPTICS,ISA,PIXEL, or VCIMAGE.
%
% Examples:
%  fullName = vcSaveObject(scene);
%  fullName = vcSaveObject(oi,'c:\u\brian\Matlab\myFileName.mat')
%  fullName = vcSaveObject(optics,'c:\u\brian\Matlab\myOptics.mat')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'), error('Object required.'); end

objType = vcGetObjectType(obj);
objType = vcEquivalentObjtype(objType);

if ieNotDefined('fullName'), fullName = vcSelectDataFile(objType, 'w', 'mat'); end
if isempty(fullName), return; end

switch (lower(objType))
    case 'scene'
        scene = obj;
        save(fullName, 'scene');

    case 'optics'
        optics = obj;
        save(fullName, 'optics');

    case 'opticalimage'
        opticalimage = obj;
        save(fullName, 'opticalimage');

    case 'isa'
        isa = obj;
        save(fullName, 'isa');

    case 'pixel'
        pixel = obj;
        save(fullName, 'pixel');

    case 'vcimage'
        vcimage = obj;
        save(fullName, 'vcimage');

    case 'camera'
        camera = obj;
        save(fullName, 'camera');

    otherwise
        error('Unknown object type');
end

return;
