function val = mlensGet(ml,param,varargin)
% Get microlens properties
%
%   val = mlensGet(ml,param,varargin);
%
% Microlens structure interface routine. This is like all of the
%
% Microlens fields
%     'name' 
%     'type' - always microlens
%     'chief ray angle'   - Chief ray angle in degrees
%     'chief ray angle radians'
%
%  ML optics (the microlens on the sensor)
%     'ml fnumber'        - 
%     'ml focal length'*  
%     'ml diameter'*       
%     'ml refractive index'
%
%  Source (imaging lens, usually)
%     'source flength'*
%     'source fnumber'
%     'source diameter'*
%     'source irradiance'       
%     'source wavelength'*          
%
%  ML Position and geometry
%     'ml offset'    
%     'optimal offsets'       
%     'optimal offset'         
%     'pixel irradiance'        
%     'space coordinate'    
%     'angle coordinate'
%     'pixel distance'*
%     'pixel position'   - pixel (0,h) and (d,d) coordinates
%
%  Efficiency
%     'etendue'
%
% Examples:
%    val = mlensGet(ml,'focallength',f);
%
%    pixel = vcGetObject('pixel'); 
%    mlensGet(ml,'optimalOffset',pixel,'microns')
%    
% Copyright ImagEval Consultants, LLC, 2003.

% Programming
% See comments throughout.  Little problems everywhere.
% Mainly, we should be calculating certain things, not storing them.
% Like etendue.  Or ...
%

%%
if ieNotDefined('ml'),    error('Micro lens structure required.'); end
if ieNotDefined('param'), error('Parameter field required.'); end

val = [];

%%
param = ieParamFormat(param);
switch lower(param)
    
    case {'name','title'}
        val = ml.name;
        
    case {'type'}
        val = ml.type;
        
        % General
    case {'wavelength'}
        % mlensGet(ml,'wavelength',unit)
        % Wavelength is stored in nanometers, as always in ISET
        val = ml.wavelength;
        
        % Sometimes, we need wavelength in um, so this is here
        if isempty(varargin),  return;
        else
            % Put wavelength into meters, and then scale
            val = (val*1e-9)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'chiefrayangle','rayangle','chiefray','chiefrayangledegrees'}
        % We always store this in degrees (not radians)
        val = ml.rayAngle;
   
    case {'chiefrayangleradians'}
        % Stored in degrees
        val = deg2rad(ml.rayAngle);
        
        % Microlens parameters
    case {'mlfocallength','microlensfocallength','mlflength','focallength'}
        % fl = mlensGet(ml,'mlflength',unitName);
        %
        % This focal length is accurate when the microlens is backed by
        % air.  The focal length depends on the index of refraction of the
        % material in the stack.  To account for that use:
        %   flStack = mlensGet(ml,'mlfLengthStack',pixel,unitName)
        %
        if isempty(varargin),   val = ml.focalLength;
        else val = ml.focalLength*ieUnitScaleFactor(varargin{1}); end
    
    case {'mlfnumber','fnumber','microlensfnumber'}
        % mlensGet(ml,'f number')
        val = ml.fnumber;
        
    case {'mldiameter','diameter'}
        % mlensGet(ml,'diameter',units)
        diameter = ml.focalLength/ml.fnumber;
        
        if isempty(varargin),   val = diameter;
        else val = diameter*ieUnitScaleFactor(varargin{1}); end
        
                        
    case {'microlensrefractiveindex','mlrefindx','mlrefractiveindex'}
        % Should always be there, created in mlensCreate
        if checkfields(ml,'refractiveIndex'),  val = ml.refractiveIndex;
        else                                   val = 1.5;  
        end
        
    case {'microlensoffset','mloffset','offset'}
        % Current offset of the microlens
        % Units are microns
        val = ml.offset;
        
        % Source parameters
    case {'sourcefocallength','sourceflength'}
        % Stored in units of meters
        if isempty(varargin),   val = ml.sourceFocalLength;
        else val = ml.sourceFocalLength*ieUnitScaleFactor(varargin{1}); end
    
    case {'sourcefnumber','sfnumber'}
        % Focal length divided by diameter
        val = ml.sourceFNumber;
        
    case {'sourcediameter'}
        % mlensGet(ml,'source diameter',[units='meters'])
        diameter = ml.sourceFocalLength/ml.sourceFNumber;
        
        if isempty(varargin),   val = diameter;
        else val = diameter*ieUnitScaleFactor(varargin{1}); end
        
    case {'sourceirradiance'}
        % Computed by mlRadiance.
        if checkfields(ml,'sourceIrradiance'),val = ml.sourceIrradiance; end
        

        % Computed quantities
    case {'optimaloffsets','microoptimaloffsetarray','microoptimaloffsets'}
        % optimalOffsets = mlensGet(ml,'optimal offsets');
        %
        % Return the offsets for the sensor.  This is always calculated for
        % the current ISET sensor.  If none exists, the default is used.
        sensor = vcGetObject('sensor');
        if isempty(sensor)
            fprintf('** Creating default ISET sensor %s\n',sensorGet(sensor,'name'));
            sensor = sensorCreate;
            ieAddObject(sensor);
        end
        val = mlOptimalOffsets(ml,sensor);
       
    case {'optimaloffset','microoptimaloffsetpixel','microoptimaloffset'}
        % mlensGet(ml,'optimalOffset',[unit])
        % 
        % Optimal offset for the current microlens position (microns)
        % As of Feb. 2015 positive means towards the origin
        
        s = vcGetObject('sensor');
        if isempty(s), s = sensorCreate; ieAddObject(s); end;
        
        if isempty(varargin),   unitName = 'microns';
        else                    unitName = varargin{1};
        end

        cra    = mlensGet(ml,'chief ray angle radians'); 
        zStack = sensorGet(s,'pixel layer thicknesses',unitName);
        nStack = sensorGet(s,'pixel refractive indices');
        nStack = nStack(2:(end-1));
        % n is probably a list of indices of refraction, and we should
        % loop or something.
        val = 0;
        for ii=1:length(zStack)
            val = zStack(ii)*tan(asin(sin(cra)/nStack(ii))) + val;
        end 
        % val = -val;  % Changed sign as of Feb. 2015

    case {'pixelirradiance','irradiance','pirradiance'}
        % mlensGet(ml,'pixel irradiance')
        % Should we always compute the pixel irradiance first.
        % Then return it?
        % ml  = mlRadiance(ml);
        val = ml.pixelIrradiance;
        
        % Phase-space coordinates
    case {'xcoordinate','spacecoordinate'}
        if checkfields(ml,'x'), val = ml.x; end
        
    case {'anglecoordinate','pcoordinate'}
        % Should this and x be recomputed on the fly?  It would be
        % lambda = mlensGet(ml,'wavelength');
        % widthPS = mlGet(ml,'phaseSpaceWidth');
        % nAir = mlGet(ml,'indexofrefractionfsomething');
        % [X,P] = mlCoordinates(-widthPS,widthPS,nAir,lambda,'angle');
        % x = X(1,:); p = P(:,1);
        if checkfields(ml,'p'), val = ml.p; end
        
    case {'etendue'}
        % Should be calculated, not stored, right ???
        if checkfields(ml,'E'),val = ml.E; end
        
    case {'pixeldistance'}
        % mlensGet(ml,'pixel distance',unit)
        % The distance from the center of the array for a pixel with this
        % chief ray angle
        %
        % The tangent of the chief ray angle is opposite over adjacent
        %  (X/sfl) = tan(cra)
        %
        % The number of pixels away is opposite divided by pixel size
        cra = mlensGet(ml,'chief ray angle radians');
        sfl = mlensGet(ml,'source focal length');
        val = sfl*tan(cra); 
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end

    case {'pixelposition','pixelrowcol'}
        % mlensGet(ml,'pixel position')
        %
        % The returns are the horizontal pixel position (0,h) and the
        % diagonal pixel position (p,p)
        %
        % The currently selected sensor is assumed to define the pixel
        % size.
        d = mlensGet(ml,'pixel distance','um');
        pixSize = sensorGet(vcGetObject('sensor'),'pixel width','um');
        val.hPix = round(d/pixSize);
        val.dPix = round(d/(pixSize*sqrt(2)));

    otherwise
        error('Unknown parameter:  %s\n',param);
        
end

end

%%
function optimalOffsets = mlOptimalOffsets(ml,sensor)
% The optimal microlens offsets across the sensor. 
%
%   optimalOffsets = mlOptimalOffsets(ml,sensor)
%
% The offset units are in microns
%
% Copyright Imageval Consulting, LLC 2005

n2       = mlensGet(ml,'microLens RefractiveIndex');       %
mlFL     = mlensGet(ml,'ml focal length','microns');
sourceFL = mlensGet(ml,'source Focal Length','microns'); 
pixWidth = mlensGet(ml,'diameter','meters');      

% Adjust the size of the sensor pixel to match the microlens aperture
sensor = sensorSet(sensor,'pixel width', pixWidth);
sensor = sensorSet(sensor,'pixel height',pixWidth);

support = sensorGet(sensor,'spatialSupport','um');
[X,Y] = meshgrid(support.y,support.x);

% Chief ray angle of every pixel in radians
cra = atan(sqrt(X.^2 + Y.^2)/sourceFL); 

% Return offset in microns, negative means towards the center 
optimalOffsets = mlFL*tan(asin(sin(cra)/n2));

end