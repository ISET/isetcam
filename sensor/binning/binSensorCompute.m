function ISA = binSensorCompute(ISA,OPTICALIMAGE,bMethod,showWaitBar)
%Compute sensor response using ISA parameters and optical image data
%
%   ISA = binSensorCompute([ISA],[OPTICALIMAGE],[bMethod='kodak2008'],[showWaitBar = 1])
%
%  This is the top-level function that combines the parameters of an image
%  sensor array (ISA) and an optical image (OI) to produce the sensor
%  response.  The usual function is sensorCompute.  This version allows the
%  user to apply several different types of pixel binning.
%   
%  The computation checks a variety of parameters and flags in the ISA
%  structure to perform the calculation.  Most of these parameters and
%  flags can be set either through the graphical user interface
%  (sensorImageWindow) or by scripts.
%
%  The binning method (bMethod) can only be set from a script.  From the
%  GUI, it uses the default (kodak2008) method.
%
% COMPUTATIONAL OUTLINE:
%
%   This routine provides an overview of the algorithms.  The specific
%   algorithms are described in the routines themselves. 
%
%   If the Custom button is set, then a routine provided by the user is
%   called instead of this routine.
%   
%   Otherwise, 
%   1.  The autoExposure flag is checked and the autoExposure routine is
%   called (or not).
%
%   2.  The sensorComputeImageBin() routine is called.  This is the key
%   computational routine for the mean image data; it contains many parts. 
%
%   3.  Analog gain and offset are applied volts = (volts + offset)/gain.
%       With this formula, the offset set is relative to the voltage swing
%
%   4.  Correlated double sampling flag is checked and applied (or not).
%
%   5.  The Vignetting flag is checked and pixel vignetting is applied (or
%   not).  
%
%   6.  The quantization flag is checked and the data are appropriately
%   quantized.
%
%   The main computations of the sensor image are done in the
%   sensorComputeImageBin routine. 
%
%  The value of showWaitBar determines whether the waitbar is displayed to
%  indicate progress during the computation.
%
% Examples:
%  ISA = sensorComputeBin;   % Use selected ISA and OI
%  tmp = sensorComputeBin(vcGetObject('isa'),vcGetObject('oi'),'kodak2008',0);
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('ISA'), [val,ISA] = vcGetSelectedObject('ISA'); end
if ieNotDefined('OPTICALIMAGE'), [val,OPTICALIMAGE] = vcGetSelectedObject('OPTICALIMAGE'); end
if ieNotDefined('bMethod'), bMethod = 'kodak2008'; end
if ieNotDefined('showWaitBar'), showWaitBar = 1; end
wBar = []; 
% handles = ieSessionGet('sensorWindowHandles');

%% Initialize wait bar and clear the voltage image
if showWaitBar, wBar = waitbar(0,'Sensor image:  '); end

%% Integration time
integrationTime = sensorGet(ISA,'integrationTime');
if length(integrationTime) > 1, 
    error('Pixel binning only runs with a single integration time'); 
end

%% Make sure we clear the sensor data before proceeding
%  This prevents problems with differences in the dv and voltage array
%  sizes.
ISA = sensorClearData(ISA);

%% Binning calculations
% In the binning applications, the voltage data may have an unusual size.
% For example, if we are binning using the Kodak 2008 method (default) the
% voltages along the rows are added, but not along the columns.  We
% digitally average the column values later.  So at this point in the
% process size(volts) may be a little surprising ...
dsnu = sensorGet(ISA,'dsnuImage');
prnu = sensorGet(ISA,'prnuImage');
voltImage = sensorGet(ISA,'volts');

if (isempty(dsnu) || isempty(prnu)) || ...
        (numel(voltImage) ~= numel(dsnu)) || ...
        (numel(voltImage) ~= numel(prnu))
    % Compute voltage image and the dsnu and prnu images
    if showWaitBar, waitbar(0.3,wBar,'Sensor image: Voltage image (new dsnu/prnu)'); end
    [dv, volts, offset, gain] = binSensorComputeImage(OPTICALIMAGE,ISA,bMethod,wBar);
    % figure; imagesc(dv)
    ISA = sensorSet(ISA,'digitalValues',dv);
    ISA = sensorSet(ISA,'volts',volts);
    ISA = sensorSet(ISA,'dsnuImage',offset);
    ISA = sensorSet(ISA,'prnuImage',gain);
else
    % dsnu and prnu are image are already present, so we just compute the
    % voltage image
    if showWaitBar, waitbar(0.3,wBar,'Sensor image: Voltage image (existing dsnu/prnu)'); end
    dv  = binSensorComputeImage(OPTICALIMAGE,ISA,bMethod,wBar);
    ISA = sensorSet(ISA,'digitalValues',dv);
end

if isempty(sensorGet(ISA,'digitalValues')),
    % Something went wrong.  Clean up the mess and return control to the main
    % processes.
    disp('No digital values');
    delete(wBar); return;
end
    
%% Correlated double sampling
if  sensorGet(ISA,'cds')
    % Read a zero integration time image that we will subtract from the
    % simulated image.  This removes much of the effect of dsnu.
    integrationTime = sensorGet(ISA,'integrationtime');
    ISA = sensorSet(ISA,'integrationtime',0); 

    if showWaitBar, waitbar(0.6,wBar,'Sensor image: CDS'); end
    cdsDV = binSensorComputeImage(OPTICALIMAGE,ISA,bMethod);
    ISA   = sensorSet(ISA,'integrationtime',integrationTime);

    % Clip at zero, no maximum
    ISA = sensorSet(ISA,'digitalValues',ieClip(sensorGet(ISA,'dv') - cdsDV,0,[]));
end

if showWaitBar, waitbar(0.95,wBar,'Sensor image: A/D'); end

%% Quantization
% Compute the digital values (DV).   The results are written into
% ISA.data.dv.  If the quantization method is Analog, then the data.dv
% field is cleared and the data are stored only in data.volts.

% We check for an analog gain and offset.  For many years there was no
% analog gain parameter.  This was added in January, 2008 when simulating
% some real devices. The manufacturers were clamping at zero and using
% the analog gain like wild men, rather than exposure duration. We set it
% in script for now, and we will add the ability to set it in the GUI
% before long.  If these parameters are not set, we assume they are
% returned as 1 (gain) and 0 (offset).
ag     = sensorGet(ISA,'analogGain');
ao     = sensorGet(ISA,'analogOffset');
dv     = sensorGet(ISA,'digitalValues');
dv     = (dv + ao)/ag;
ISA    = sensorSet(ISA,'digitalValues',dv);

% We clip the voltage because we assume that everything must fall between 0 and voltage swing.
% We could broaden our horizons.
pixel  = sensorGet(ISA,'pixel');
vSwing = pixelGet(pixel,'voltageswing');
ISA    = sensorSet(ISA,'digitalValues',ieClip(sensorGet(ISA,'digitalValues'),0,vSwing));

switch lower(sensorGet(ISA,'quantizationmethod'))
    case {'analog'}
        % For binning we always need a quantization method.
        % So if it is analog, we set the method to linear at 8 bits
        ISA = sensorSet(ISA,'quantizationMethod','8 bit');
        warning('ISET:sensorComputeBin0','Setting quantization to 8 bits');
        ISA = sensorSet(ISA,'digitalvalues',binAnalog2digital(ISA,'linear'));
    case {'linear'}
        ISA = sensorSet(ISA,'digitalvalues',binAnalog2digital(ISA,'linear'));
    case 'sqrt'
        ISA = sensorSet(ISA,'digitalvalues',binAnalog2digital(ISA,'sqrt'));
    case 'lut'
        warning('ISET:LUTquantization','LUT quantization not yet implemented.')
    case 'gamma'
        warning('ISET:GammaQuantization','Gamma quantization not yet implemented.')
    otherwise
       ISA = sensorSet(ISA,'digitalvalues',binAnalog2digital(ISA,'linear'));
end

%% Check binning requirement after quantization
%
% Some binning methods require processing of the digital output value. We
% do it here.
ISA = binPixelPost(ISA,bMethod);

%% Possible overlay showing center of Macbeth chart
ISA = sensorSet(ISA,'mccRectHandles',[]);

if showWaitBar, close(wBar); end

return;
