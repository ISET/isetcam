function sensor = mlAnalyzeArrayEtendue(sensor,method,nAngles)
% Analyze the etendue across a sensor array
%
% sensor = mlAnalyzeArrayEtendue(sensor,[method = 'centered'],[nAngles = 5])
%
%   Calculate the etendue across the sensor surface given the current
%   microlens properties. The calculation can be performed using the
%   method argument
%   method =
%     optimal:       at the optimal position
%     centered:      at the pixel center
%     no microlens:  absent.
%
%   The case of no microlens is also called 'vignetting' as it refers to
%   only the loss of light due to the combination of the imaging (taking)
%   lens and the tunnel of the pixel.
%
%   We compute optical efficiency of the microlens by calculating the ratio
%   of the etendue with and without the microlens present (see below).
%
%   The nAngles specifies the number of chief ray angles that are used to
%   estimate the function across the array.  This number is typically small
%   (default = 5) because the etendue function is very smooth and can be
%   estimated from just a couple of values.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% Example:
%   oi = oiCreate; sensor = sensorCreate;
%   ieAddObject(oi); ieAddObject(sensor);
%   sensor = mlAnalyzeArrayEtendue(sensor,'optimal');
%   optimalE = sensorGet(sensor,'sensorEtendue');
%   vcNewGraphWin;  mesh(optimalE);
%
%   sensor = mlAnalyzeArrayEtendue(sensor,'no microlens');
%   nomlE = sensorGet(sensor,'sensorEtendue');
%   mesh(optimalE ./ nomlE);
%
%   tic, sensor = mlAnalyzeArrayEtendue(sensor,'centered',5); toc;
%   plotSensorEtendue(sensor)
%
%   sensor = mlAnalyzeArrayEtendue(sensor,'centered',5);
%   plotSensorEtendue(sensor);
%
% See also
%

% Programming Note:  Maybe the default method should be optimal.

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('method'), method = 'centered'; end
if ieNotDefined('nAngles'), nAngles = 5; end
showBar = ieSessionGet('waitbar');

% We should also be able to compute this assuming that there is a microlens
% offset.  At present, we don't.
ml = sensorGet(sensor,'ml');
if isempty(ml)
    fprintf('** Initializing sensor microlens\n');
    ml = mlensCreate(sensor);
end

sensorCRA = sensorGet(sensor,'cra degrees');

% We want to go out to the far corner, so we estimate the etendue beyond
% the width, all the way out.
cra = (0:nAngles)/nAngles*max(sensorCRA(:));

if showBar
    h = waitbar(0,sprintf('Calculating etendue at %.0f angles...',nAngles));
end

etendue   = zeros(size(cra));
for ii=1:length(cra)
    ml = mlensSet(ml,'chief ray angle',cra(ii));
    method = ieParamFormat(method);
    switch method
        case 'centered'
            % No offset, so centered
            ml = mlensSet(ml,'offset',0);
            ml = mlRadiance(ml,sensor,1);
        case {'optimized','optimal'}
            offset = mlensGet(ml,'optimal offset','microns');
            ml     = mlensSet(ml,'offset',offset);
            ml     = mlRadiance(ml,sensor,1);
        case {'nomicrolens'}
            % Only calculate vignetting, ignore the microlens
            ml = mlRadiance(ml,sensor,0);
        otherwise
            error('Unknown method.');
    end
    
    etendue(ii) = mlensGet(ml,'etendue');
    if showBar, waitbar(ii/length(cra),h); end
end
if showBar, close(h); end

% We interpolate the (many) missing values
sensorEtendue = interp1(cra,etendue,sensorCRA);

% We assign the result either to vignetting or etendue depending on whether
% a microlens was in place.
switch lower(method)
    case {'centered','optimal','optimized'}
        sensor = sensorSet(sensor,'etendue',sensorEtendue);
    case {'nomicrolens','bare'}
        sensor = sensorSet(sensor,'etendue',sensorEtendue);
    otherwise
        error('Unknown method.');
end

% Update the microlens structure
sensor = sensorSet(sensor,'ml',ml);

end
