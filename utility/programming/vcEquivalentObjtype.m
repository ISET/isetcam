function objType = vcEquivalentObjtype(thisObj)
% Translate strings into the name used in vcSESSION variable
%
% Brief description
%   In some cases we used alternative strings for the basic ISETCam
%   classes.  We translate those here into the vcSESSION strings.
%
%   In other cases when this is called, we happen to send in a
%   different type of object, not a string.  In that case, we return
%   the class(objType).
%
% Synopsis
%   objType = vcEquivalentObjtype(objType);
%
% The vcSESSION object names are SCENE, OPTICALIMAGE, ISA, VCIMAGE, DISPLAY
%
% These are aliases we sometimes use for key terms:
%
%   OI           -> OPTICAL IMAGE
%   SENSOR       -> ISA
%   IMGPROC, IP, -> VCIMAGE
%   IPDISPLAY    -> IP
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   ieGetObject, ieAddObject

if ischar(thisObj)

    % Change the string to upper case
    objType = upper(thisObj);

    %% These are aliases we use sometimes
    if     strcmp(objType,'OI'), objType = 'OPTICALIMAGE';
    elseif strcmp(objType,'SENSOR'), objType = 'ISA';
    elseif strcmp(objType,'IMGPROC') || ...
            strcmp(objType,'VCI') || ...     % Virtual camera image
            strcmp(objType,'IP')             % Image processor
        objType = 'VCIMAGE';
    elseif strcmp(thisObj,'CAMERA')
        objType = 'CAMERA';
    end

else
    % It is not a string.  Return the class of the object.
    objType = class(thisObj);
end

end
