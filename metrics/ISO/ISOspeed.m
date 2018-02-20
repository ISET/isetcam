function speed = ISOspeed(speedType,ISA)
%Compute ISO saturation speed and in the future other speeds
%
%   speed = ISOspeed(speedType,[ISA])
%
% Estimate a sensor's ISO speed according to either the saturation or noise
% method.
%
% The saturation ISO speed summarizes "how much light" is needed to make 
% the "bright parts" in the image saturate. The higher the ISO speed the
% less light is needed to achieve just that. Saturation-based ISO speed
% measures  sensitivity: the higher the ISO speed the more "sensitive"  the
% system.
% 
% The saturation ISO speed is a property of the Sensor; it does not depend
% on other camera properies such as optics and processing.  (Well, actually
% depends on the type of light illuminating the scene, but more on that
% later)
%
% The properties that govern the Saturation ISO speed are: a) The well
% capacity: Nmax (units: electrons) b) The Responsivity functions of the
% Sensor (i.e. QE): R (units: electrons/photos)
%
% Now the formula. To get there we must clarify some things:  1) How are
% "bright parts" defined? The brightest parts are higlights. According to
% ISO highlights are sqrt(2), i.e. 41% brighter than a white (100%)
% reflector.
%
% 2) How is "amount of light" defined?, According to ISO there are two
% Saturation based ISO speeds defined, one for D65 and one for Tungsten,
% for the remainder let's stick with D65. a) The technical term for "amount
% of light" is the photometric quantity "Exposure" measured in lux*s and
% abreviated with the letter H. b) There is also a more specific definition
% of "Camera Exposure" which is the amount of light that reaches the sensor
% from a 0.14 gray reflector, if(!) the image is correctly exposed. 
%   
% Hence the question now becomes: 
% a) How much D65 light (measured in lux*s) is needed to make the sensor
% saturate.  
%
% Solve for scalefactor:      
%    Nmax = Max[R'*SceneLightSpectrum/H(SceneLightSpectrum)*scaleFactor]
% Calculate Highlight Exposure: 
%    H_highlight = H(SceneLightSpectrum)*scaleFactor  
%
% b) How high was the "Camera Exposure" for that case.
%     H_camera = (H_highlight/sqrt(2))*.14
% 
% Finally, ISO saturation speed
%   SaturationISOspeed = 10/H_camera
%
% See example in source code
%
% Copyright ImagEval Consultants, LLC, 2003.

% Example:
%{
  sensor = sensorCreate;
  speed = ISOspeed('saturation',sensor);
%}

if ieNotDefined('ISA'), ISA = ieGetObject('sensor'); end
if ieNotDefined('speedType'), speedType = 'saturation'; end

% Create an OI (uniform, D65).  Do not put the data in the vcSESSION
% structure though.  It is just temporary.
OI = oiCreate('uniformd65',[],[],0); 


% [valISA,ISA] = vcGetSelectedObject('ISA');

% Compute the sensor response to this uniform field
ISA = sensorCompute(ISA,OI);
PIXEL = sensorGet(ISA,'pixel');
% [val,PIXEL] = vcGetSelectedObject('PIXEL');

% wave = sensorGet(ISA,'wave');

switch lower(speedType)
    case 'saturation'
        wellcapacity = pixelGet(PIXEL,'well capacity');  %In electrons
        % sensorSpectralQE = sensorGet(ISA,'spectral QE');
        ISA = sensorCompute(ISA,OI);
        electrons = sensorGet(ISA,'electrons');
        nSensors = sensorGet(ISA,'nsensors');
        mn = zeros(1,nSensors);
        if nSensors > 1
            rgb = plane2rgb(electrons,ISA);
            for ii=1:nSensors
                s = getMiddleMatrix(rgb(:,:,ii),5);
                l = isfinite(s);
                mns(ii) = mean(s(l));
                mn = max(mns);
            end
        else
            e = getMiddleMatrix(electrons(:,:),5);
            mn = mean(e(:));
        end
        
        oiLuxSec = oiGet(OI,'meanilluminance')*sensorGet(ISA,'integrationtime');
        satLuxSec = oiLuxSec*(wellcapacity/mn);

        % From the ISO standard.  They say a correctly exposed image has
        % the white surface a sqrt(2) below the saturation.  The 10 and
        % 0.14 have to do with the mean of the scene.
        % Ask UB.
        speed = 10 / ((satLuxSec/sqrt(2))*.14);
        
    case 'noise'
        error('Not yet implemented.');
    otherwise
        error('Unknown speed type.');
end

return;
