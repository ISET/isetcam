function ml = mlensSet(ml,param,val,varargin)
%Microlens set interface routine.
%
%   ml = mlensSet(ml,param,val,varargin);
%
% Examples:
%
%    ml = mlensSet(ml,'mlflength',flength);
%
% If you have the focal length in microns, rather than meters, you can
% make the call this way:
%
%    ml = mlensSet(ml,'mlflength',flength,'microns');
%
% List of parameters
%
% General
%  name -
%  wavelength
%
% Microlens parameters
%  ml fnumber
%  ml focal length*
%  ml diameter - deprecate
%  ml offset
%  ml refractive index
%
% Source lens parameters
%  source fnumber
%  source focal length
%  source irradiance
%
% Pixel specifics
%  chief ray angle  - degrees
%  x coordinate     -
%  angle coordinate -
%
% Copyright Imageval LLC, 2005

% Programming notes:
% I am concerned that there are some possible inconsistencies here in the
% sets, with three parameters that might conflict (e.g., x,p,chiefrayangle)
%
% More comments on units needed.
% Offset is stored in microns, other things (e.g., mlFocalLength) are
% stored in meters.  Some day, unify all this.  note the code that lets you
% specify the units of what comes in.  Examples below and above.
%
% Also, we use fnumber for source optics, but focal length and diameter for
% microlens.  We should use fnumber and focal length for both, and get
% diameter
% Switched to fnumber and focal length in Feb. 2015.

if ieNotDefined('param'), error('Parameter field required.'); end

% Empty is an allowed value.  So we don't use ieNotDefined.
if ~exist('val','var'),   error('Value field required.'); end

param = ieParamFormat(param);
switch lower(param)
    
    case {'name','title'}
        ml.name = val;
        
    case {'wavelength','sourcewavelength'}
        % What units?   Not nanometers?  What's going on?
        ml.wavelength = val;
        
    case {'chiefrayangle','rayangle','chiefrayangledegrees'}
        % This angle is specified in degrees
        ml.rayAngle = val;
        
        % Source parameters
    case {'sourcefnumber','sfnumber'}
        % Meters
        ml.sourceFNumber = val;
        
    case {'sourcefocallength','sourceflength',}
        % mlLensSet(ml,'source focal length','microns')
        % Meters!!! Change over.  Check, check, check ...
        %
        if isempty(varargin), ml.sourceFocalLength= val;
        else ml.sourceFocalLength = val / ieUnitScaleFactor(varargin{1});
        end
        
    case {'sourceirradiance'}
        ml.sourceIrradiance = val;
        
        % Microlens parameters
    case {'mlfnumber','fnumber'}
        % mlensSet(ml,'f number',4)
        ml.fnumber = val;
        
    case {'mlfocallength','mlflength','microlensfocallength'}
        % Stored in Meters
        % ml = mlensSet(ml,'mlflength',val);
        % Specifying unit is an option, but not preferred.
        if isempty(varargin), ml.focalLength = val;
        else ml.focalLength = val / ieUnitScaleFactor(varargin{1});
        end
        
    case {'mloffset','microlensoffset','offset','microlensoffsetmicrons'}
        % Has always been in microns
        % Am switching to meters Feb. 2015
        if isempty(varargin), ml.offset = val;
        else ml.offset = val / ieUnitScaleFactor(varargin{1});
        end
        ml.offset = val;
        
    case {'mlrefractiveindex','microlensrefractiveindex','mlrefindx'}
        ml.refractiveIndex = val;
        
        % Stuff that we use when we compute.
        % I am worried that these can be inconsistent (BW).
    case {'xcoordinate','spacecoordinate'}
        % What units?  Microns?  Meters?
        ml.x = val;
        
    case {'anglecoordinate','pcoordinate'}
        % Degrees?  Radians?
        ml.p = val;
        
        % UNCLEAR WHETHER THESE SHOULD BE HERE
        % Phase-space coordinates
        % Not sure these should be set.  Perhaps it should be computed on
        % the fly (see mlensGet).
    case {'pixelirradiance','irradiance','pirradiance'}
        ml.pixelIrradiance = val;
        
    case {'etendue'}
        ml.E = val;
        
    otherwise
        error('Unknown parameter');
        
end

return;
