function objType = vcEquivalentObjtype(objType)
%Translate aliases into the name used in vcSESSION variable
%
%   objType = vcEquivalentObjtype(objType);
%
% This call translates aliases for the key terms:
%
%   OI -> OPTICAL IMAGE
%   SENSOR -> ISA
%   IMGPROC, IP, -> VCIMAGE
%   IPDISPLAY -> IP
%
% The official object names are SCENE, OPTICALIMAGE, ISA, VCIMAGE,
% DISPLAY.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Get rid of case-dependence
objType = upper(objType);

% These are the aliases we use sometimes
if     strcmp(objType,'OI'), objType = 'OPTICALIMAGE';
elseif strcmp(objType,'SENSOR'), objType = 'ISA';
elseif strcmp(objType,'IMGPROC') || ...
       strcmp(objType,'VCI') || ...     % Virtual camera image
       strcmp(objType,'IP'),            % Image processor
    objType = 'VCIMAGE';
elseif strcmp(objType,'CAMERA')
    objType = 'CAMERA';
    % Other translations belong here
end

end
