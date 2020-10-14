function objType = vcEquivalentObjtype(objType)
%Translate aliases into the name used in vcSESSION variable
%
%   objType = vcEquivalentObjtype(objType);
%
% The official object names are SCENE, OPTICALIMAGE, ISA, VCIMAGE,
% DISPLAY.
%
% This call translates aliases for we sometimes use for key terms:
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

%% Get rid of case-dependence
objType = upper(objType);

%% These are aliases we use sometimes
if     strcmp(objType,'OI'), objType = 'OPTICALIMAGE';
elseif strcmp(objType,'SENSOR'), objType = 'ISA';
elseif strcmp(objType,'IMGPROC') || ...
       strcmp(objType,'VCI') || ...     % Virtual camera image
       strcmp(objType,'IP')             % Image processor
    objType = 'VCIMAGE'; 
elseif strcmp(objType,'CAMERA')
    objType = 'CAMERA';
end

end
