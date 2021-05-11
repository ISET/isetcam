function [newVal, fullName] = vcImportObject(objType, fullName, preserveDataFlag)
% Import an ISET structure from a file to the vcSESSION structure
%
%   [newVal,fullFileName] = vcImportObject(objType,[fullName],[preserveDataFlag])
%
% The parameters of an ISET object, saved in a file, are read and attached
% to the variable, vcSESSION.
%
% Imported objects do not have any image data attached to them.  If a pixel
% or optics are imported, the data in the current ISA or OI are cleared and
% must be recomputed.  This is done to assure consistency between the data
% and the structure parameters.
%
% This function also loads pixel and optics, attaching them to the current
% sensor or optical image. The default for optics and pixels is to PRESERVE
% the data.  The default for sensors and other objects is to CLEAR the
% data.
%
% Examples:
%   newVal = vcImportObject('SCENE');
%   newVal = vcImportObject('ISA')
%   fullName = fullfile(isetRootPath,'data','optics','rtZemaxExample.mat');
%   vcImportObject('OPTICS',fullName);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('objType'), objType = 'SCENE'; end
if ieNotDefined('fullName'), fullName = []; end
if ieNotDefined('preserveDataFlag')
    switch lower(objType)
        case {'scene', 'opticalimage', 'oi', 'isa', 'sensor', 'vcimage'}
            preserveDataFlag = 0;
        otherwise
            % optics and pixel case, but I don't think the pixel has data.
            preserveDataFlag = 1;
    end
end

% Note that there is vcLoad in this file and vcLoadObject is a different
% function.  Should be unified some day, sigh.
switch lower(objType)
    case {'scene', 'opticalimage', 'oi', 'isa', 'sensor', 'vcimage'}
        % Load the object into a new value assigned by vcLoadObject.
        [newVal, fullName] = vcLoadObject(objType, fullName);
        if isempty(newVal), return; end

    case {'pixel'}
        [newVal, isa] = vcGetSelectedObject('ISA');
        [pixel, fullName] = vcLoad(objType, fullName);
        if ~isempty(pixel)
            sensorSet(isa, 'pixel', pixel);
            if ~preserveDataFlag
                isa = sensorClearData(isa);
            end
            vcReplaceAndSelectObject(isa, newVal);
        end
    case {'optics'}
        [newVal, oi] = vcGetSelectedObject('OPTICALIMAGE');
        [optics, fullName] = vcLoad(objType, fullName);
        if ~isempty(optics)
            oi = oiSet(oi, 'optics', optics);
            if ~preserveDataFlag
                oi = oiClearData(oi);
            end
            vcReplaceAndSelectObject(oi, newVal);
        end
    otherwise
        error('Unknown object type.');
end


return;

%----------------------------------------------------------
    function [obj, fullName] = vcLoad(objType, fullName)
        %
        %   [obj,fullName] = vcLoad(objType,fullName)
        %
        % This routine handles loading pixels, optics, and in the future, displays.

        obj = [];

        if ieNotDefined('fullName')
            windowTitle = sprintf('Select %s file name', objType);
            fullName = vcSelectDataFile('session', 'r', 'mat', windowTitle);
            if isempty(fullName), return; end
        end

        switch (lower(objType))
            case 'pixel'
                data = load(fullName, 'pixel');
                obj = data.pixel;

            case 'optics'
                data = load(fullName, 'optics');
                obj = data.optics;

            otherwise
                error('Unknown object type');
        end

        return;
