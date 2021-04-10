function objType = ieEquivalentObjtype(objType)
%Translate aliases into the name used in vcSESSION variable
%
%   objType = ieEquivalentObjtype(objType);
%
% This call translates equivalent variable names using this call, we can
% have aliases such as OI and SENSOR instead of OPTICALIMAGE and ISA.  Or
% IMGPROC instead of VCIMAGE. 
%
% The official structure names are SCENE, OPTICALIMAGE, ISA, and VCIMAGE
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
    % Other translations belong here
end

return
