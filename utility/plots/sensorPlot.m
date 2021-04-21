function [uData, g] = sensorPlot(sensor, ptype, roilocs, varargin)
% Gateway routine for plotting sensor data
%
%   [uData, hdl] = sensorPlot(sensor, ptype, roilocs, varargin)
%
% These plots characterizing the data, sensor parts, or performance of
% the sensor.  There are many types of plots, and as part of the function
% they also return the rendered data.  
%
% Inputs:
%  sensor:   An ISETCam sensor
%  ptype:    The plot type (char)
%  roilocs:  When needed, specify the region of interest
%
% Optional key/val pairs
%   'no fig'  - Do not plot the figure, just return the uData (logical)
%   
%    Additional parameters may be required for different plot types. I will
%    try to figure that out and put them here.
%
% Outputs:
%  uData:  Structure of the plotted (user data)
%  hdl:    Figure handle
%
% The main routine, sensorPlot, is a gateway to many other characterization
% and plotting routines contained within this file.  Sensor plotting should
% be called from here, if at all possible, so we avoid duplication.
%
% The properties that can be plotted are:
%
% Sensor Data plots
%  'electrons hline' - sensorPlot(sensor,'electrons hline',[x y])
%  'electrons vline' - sensorPlot(sensor,'electrons vline',[x y])
%  'volts hline'     - sensorPlot(sensor,'volts hline',[x y])
%  'volts vline'     - sensorPlot(sensor,'volts vline',[x y])
%  'dv vline'        - ...
%  'dv hline'
%  'volts histogram'
%  'electrons histogram'
% ' shot noise'
% 
% Color filter properties
%  'cfa block'
%  'cfa full'
%  'color filters'
%  'ir filter'
%
% Sensor electrical properties
%  'pixel spectral qe' -   % Volts/Quantum response by wavelength
%  'pixel spectral sr' -   % Volts/Energy response by wavelength
%  'spectral qe'
%  'pixel snr'
%  'sensor snr'
%  'dsnu'
%  'prnu'
% 
% Optics related
%  'etendue'
% 
% Human
% 'conemosaic' % Not sure
%
% Color filter array and spectra
%
% ieExamplesPrint('sensorPlot');
%
% See also
%   scenePlot, oiPlot, ipPlot

% Examples:
%{
  scene = sceneCreate; camera = cameraCreate;
  camera = cameraCompute(camera,scene);
  sensor = cameraGet(camera,'sensor');
  % sensorWindow(sensor);
  sensorPlot(sensor,'electrons hline',[1 19]);
%}
%{
  scene = sceneCreate; scene = sceneSet(scene,'fov',2);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate; sensor = sensorCompute(sensor,oi);

  uData = sensorPlot(sensor,'electrons hline',[20 20]);
  isequal(uData,get(gcf,'UserData'))
%}
%{
  scene = sceneCreate; scene = sceneSet(scene,'fov',2);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate; sensor = sensorCompute(sensor,oi);
  sensorPlot(sensor,'volts vline',[20 20]);
  get(gcf,'UserData')
  uData = sensorPlot(sensor,'volts vline ',[53 1],'no fig',false);
%}
%{
  scene = sceneCreate; camera=cameraCreate;
  camera = cameraCompute(camera,scene);
  sensor = cameraGet(camera,'sensor');
  % sensorWindow(sensor);
  sensorPlot(sensor,'chromaticity',[30 30 10 10]);
%}

%% Parse arguments
if ieNotDefined('roilocs'),roilocs = []; end

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('sensor', @isstruct);
p.addRequired('ptype',@ischar);
p.addRequired('roilocs');
p.addParameter('capture',1,@isscalar);
p.addParameter('twolines',false,@isscalar);
p.addParameter('nofig',false,@islogical);

p.parse(sensor,ptype,roilocs,varargin{:});

pType    = ieParamFormat(p.Results.ptype);
roiLocs  = p.Results.roilocs;
capture  = p.Results.capture;
noFig    = p.Results.nofig;
twoLines = p.Results.twolines;

uData = [];

%% If the sensor has multiple exposures, deal with it here

ncaptures = sensorGet(sensor,'n captures');
if isempty(ncaptures) || isequal(ncaptures,1)
    % Do nothing
elseif capture <= ncaptures
    % Make the sensor like it has just one capture.  We put it back at the
    % end, if needed.
    store.volts = sensorGet(sensor,'volts'); 
    sensor = sensorSet(sensor,'volts',store.volts(:,:,capture)); 

    store.dv = sensorGet(sensor,'dv');
    if ~isempty(store.dv)
        sensor = sensorSet(sensor,'dv',store.dv(:,:,capture));
    end
    store.eTimes = sensorGet(sensor,'exp time');
    sensor = sensorSet(sensor,'exp time',store.eTimes(capture));
elseif capture > ncaptures
    error('Selected capture %d exceeds data size %d',capture,ncaptures);
end

%% The cases that need roiLocs, but none is passed
if isempty(roiLocs)
    switch lower(pType)
        case {'voltshline','electronshline','dvhline'}
            
            % Get a location
            roiLocs = iePointSelect(sensor);
            sz = sensorGet(sensor,'size');
            ieROIDraw(sensor,'shape','line','shape data',[1 sz(2) roiLocs(2) roiLocs(2)]);

        case {'electronsvline','voltsvline','dvvline'}
            % When the selection ends in a '2' we use this point and the
            % one below it.
            roiLocs = iePointSelect(sensor);
            sz = sensorGet(sensor,'size');
            ieROIDraw(sensor,'shape','line','shape data',[roiLocs(1) roiLocs(1) 1 sz(1)]);
            
        case {'electronshistogram','electronshist'...
                'voltshistogram','voltshist',...
                'chromaticity','dvhistogram'}
            
            % Region of interest plots
            [roiLocs, roiRect] = ieROISelect(sensor);

            % Store the rect for later plotting
            sensor = sensorSet(sensor,'roi',round(roiRect.Position));
            ieReplaceObject(sensor);
            
            % Why is this commented out?
            % ieROIDraw(sensor,'shape','rect','shape data',roiRect);
            
        otherwise
            % There are plots that are OK without an roiLocs value or ROI.
            % Such as 'snr', spectral qe, and so forth
    end
end

%% Plot 
switch pType
    
    % Sensor data related. roiLocs is (x,y) format
    % Sensor images
    case {'channels'}
        % sensorPlot(sensor,'channels');
        %
        % Plot | Sensor channel images
        %
        % Brings up a special window that shows the images of the different
        % channels in the super pixel pattern.
        %
        sensorChannelImage(sensor);
    case {'truesize'}
        % sensorPlot(sensor,'true size');
        %
        % Plot | SensorImage (True Size)
        sensor   = ieGetObject('sensor');
        gam  = sensorGet(sensor,'gamma');
        scaleMax = sensorGet(sensor,'scalemax');
        
        % Get voltages or digital values
        bits     = sensorGet(sensor,'bits');
        if isempty(bits)
            img      = sensorData2Image(sensor,'volts',gam,scaleMax);
        else
            img      = sensorData2Image(sensor,'dv',gam,scaleMax);
        end
        
        if ismatrix(img)
            % imtool needs monochrome images scaled between 0 and 1
            w = ieNewGraphWin; img = img/max(img(:));
            imshow(img); truesize(w);
            set(w,'Name',sensorGet(sensor,'name'));
        else
            ieViewer(img);
        end
        
    % Sensor data related
    case {'electronshline'}
        [g, uData] = sensorPlotLine(sensor, 'h', 'electrons', 'space', roiLocs);
        if twoLines
            delete(g); roiLocs(2) = roiLocs(2) + 1;
            [~, uData2] = sensorPlotLine(sensor, 'h', 'electrons', 'space', roiLocs);
            [g, uData] = sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Horizontal line %d',roiLocs(2)-1));
        end
    case {'electronsvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'electrons', 'space', roiLocs);        
        if twoLines
            delete(g); roiLocs(1) = roiLocs(1) + 1;
            [~, uData2]  = sensorPlotLine(sensor, 'v', 'electrons', 'space', roiLocs);
            [g, uData] = sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Vertical line %d',roiLocs(1)-1));
        end
    case {'voltshline'}
        [g, uData]  = sensorPlotLine(sensor, 'h', 'volts', 'space', roiLocs);
        if twoLines
            delete(g); roiLocs(2) = roiLocs(2) + 1;
            [~,uData2]  = sensorPlotLine(sensor, 'h', 'volts', 'space', roiLocs);
            [g, uData] = sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Horizontal line %d',roiLocs(2)-1));
        end        
    case {'voltsvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'volts', 'space', roiLocs);
        if twoLines
            delete(g); roiLocs(1) = roiLocs(1) + 1;
            [~,uData2]  = sensorPlotLine(sensor, 'v', 'volts', 'space', roiLocs);
            [g, uData]= sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Vertical line %d',roiLocs(1)-1));
        end  
    case {'dvvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'dv', 'space', roiLocs);
        if twoLines
            delete(g); roiLocs(1) = roiLocs(1) + 1;
            [~,uData2]  = sensorPlotLine(sensor, 'v', 'dv', 'space', roiLocs);
            [g, uData] = sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Vertical line %d',roiLocs(1)-1));
        end
    case {'dvhline'}
        [g, uData]  = sensorPlotLine(sensor, 'h', 'dv', 'space', roiLocs);
        if twoLines
            delete(g); roiLocs(2) = roiLocs(2) + 1;
            [~,uData2]  = sensorPlotLine(sensor, 'h', 'dv', 'space', roiLocs);
            [g, uData] = sensorPlotTwoLines(sensor,uData,uData2);
            title(sprintf('Horizontal line %d',roiLocs(2)-1));
        end
        
    case {'voltshistogram','voltshist'}
        [uData,g] = sensorPlotHist(sensor,'v',roiLocs);
    case {'electronshistogram','electronshist'}
        % sensorPlot(sensor,'electrons histogram',rect);
        [uData,g] = sensorPlotHist(sensor,'e',roiLocs);
    case {'dvhistogram'}
        [uData,g] = sensorPlotHist(sensor,'dv',roiLocs);
        
    case {'shotnoise'}
        % Poisson noise at each pixel
        [uData, g] = imageNoise('shot noise');
    case {'dsnu'}
        [uData, g] = imageNoise('dsnu');
        str = sprintf('dsnu sigma %.2f',sensorGet(sensor,'dsnu sigma'));
        title(sprintf('ISET: %s',str));
    case {'prnu'}
        [uData, g] = imageNoise('prnu');
        str = sprintf('prnu sigma %.2f',sensorGet(sensor,'prnu sigma'));
        title(sprintf('ISET: %s',str));
        
        % Wavelength and color properties
    case {'cfa','cfablock'}
        fullArray = 0;    % Not the full array
        [g, uData] = sensorShowCFA(sensor,fullArray);
    case {'cfafull'}
        fullArray = 1;    % Show the full array
        [g, uData] = sensorShowCFA(sensor,fullArray);
    case {'colorfilters'}
        [uData, g] = plotSpectra(sensor,'color filters');
    case {'irfilter'}
        [uData, g] = plotSpectra(sensor,'ir filter');
    case {'pixelspectralqe'}
        % Volts/Quantum response by wavelength
        [uData, g] = plotSpectra(sensor,'pixel spectral qe');
    case {'pixelspectralsr'}
        % Volts/Energy response by wavelength
        [uData, g] = plotSpectra(sensor,'pixel spectral sr');
    case {'spectralqe','sensorspectralqe'}
        % Sensor spectral quantum efficiency
        [uData, g] = plotSpectra(sensor,'sensor spectral qe');
    case {'sensorspectralsr'}
        % Sensor spectral spectral responsivity
        error('Not yet implemented: sensor spectral sr.  Check pixelSR');
        
        % Sensor and Pixel electronics related
    case {'pixelsnr'}
        [uData, g] = plotPixelSNR(sensor);
    case {'sensorsnr','snr'}
        [uData,g] = plotSensorSNR(sensor);


        % Optics related
    case {'etendue'}
        [uData, g] = plotSensorEtendue(sensor);
        
        % Human
    case {'conemosaic'} % Not sure
        % Eliminate.  Send users to ISETBio.
        [support, spread, delta] = sensorConePlot(sensor);
        uData.support = support;
        uData.spread = spread;
        uData.delta = delta;
        g = gcf;
        
    case {'chromaticity'}
        % sensorPlot(sensor,'chromaticity',[rect])
        %
        % rg-chromaticity of the sensor volt data
        % We should add an option for electrons
        if isempty(roiLocs), roiLocs = sensorGet(sensor,'roi');
        end
        if numel(roiLocs) == 4
        elseif size(roiLocs,2) == 2
            roiLocs = ieLocs2Rect(roiLocs); 
        else
            error('Bad roiLocs');
        end
        rg   = sensorGet(sensor,'chromaticity',roiLocs);
        ieNewGraphWin; 
        plot(rg(:,1),rg(:,2),'.');
        grid on; xlabel('r-chromaticity'); ylabel('g-chromaticity');
        uData.rg = rg; uData.rect = roiLocs; clear rg;
        
        % Add the spectrum locus.  It is not necessarily convex.
        sqe = sensorGet(sensor,'spectralqe'); s = sum(sqe,2);
        rg(:,1) = sqe(:,1)./s; rg(:,2) = sqe(:,2)./s;
        hold on; plot(rg(:,1),rg(:,2),'k-','LineWidth',1);
        thisLine = line([rg(end,1),rg(1,1)],[rg(end,2),rg(1,2)]);
        thisLine.Color = [0 0 0]; thisLine.LineWidth = 1;
        thisLine.LineStyle = '--';
        grid on; xlabel('r-chromaticity'); ylabel('g-chromaticity');
        uData.spectrumlocus = rg;
        title('rg sensor chromaticity');
    otherwise
        error('Unknown sensor plot type %s\n',pType);
end

% If the user doesn't want the figure .... lose it.  Otherwise, we should
% make it visible here, I think.  Which means we should initialize it as
% invisible in the functions below.
if noFig
    close(g);
else
    % They want the figure.  Attach the userdata to the figure.
    g.Visible = 'on';
    if exist('uData','var'), set(gcf,'UserData',uData); end
    if ~isequal(capture,1)
        % The capture number might not be different from 1.
        g.Name = sprintf('%s (exp %d)',g.Name,capture);
    end
end

% Put the original sensor back?
%{
sensor = sensorSet(sensor,'exp time',store.eTimes);
sensor = sensorSet(sensor,'volts',store.volts);
sensor = sensorSet(sensor,'dv',store.dv);
%}

end

%%
function [udata, fighdl] = plotSpectra(sensor,dataType)
%Plot various spectral functions in the sensor window
%
%  [udata, figNum] = plotSpectra(sensor,[dataType])
%
% The spectral functions include
%   pdspectralQE: photodetector spectral quantum efficiency (volts/quantum),
%   pdspectralsr: photodetector spectral responsivity ( in volts/watt),
%   colorfilters: color filter transmittance (colorfilters)
%   spectralQE: combined spectral QE of filters and photodetector (spectralQE)
%   spectralSR: combined spectral responsivity of filters and photodetector (spectralSR)
%   IR filter transmittance (irfilter).
%
% Examples:
%  [udata,figNum] = plotSpectra('pdSpectralQE')
%  plotSpectra('spectralsr',figNum);
%  plotSpectra('colorfilters',figNum);
%  plotSpectra('irfilter',figNum);
%  plotSpectra('pdspectralsr');
%  plotSpectra('spectralQE')
%
% (c) Imageval Consulting, LLC, 2003

if ieNotDefined('sensor'), error('Sensor required.'); end
if ieNotDefined('dataType'), dataType = 'pdspectralQE';          end

dataType = ieParamFormat(dataType);
switch lower(dataType)
    case {'spectralsr','sr','pixelspectralsr','pdspectralsr'}
        % volts/irradiance(energy units)
        pixel = sensorGet(sensor,'pixel');
        wave = pixelGet(pixel,'wave');
        data = pixelGet(pixel,'spectralsr');
        filterNames = {'k'};
        ystr = 'Responsivity:  Volts/Watt';
        
    case {'pdspectralqe','pixelspectralqe'}
        % volts/irradiance(photon units)
        pixel = sensorGet(sensor,'pixel');
        wave = pixelGet(pixel,'wave');
        data = pixelGet(pixel,'pdspectralqe');
        filterNames = {'k'};
        ystr = 'QE';
        
    case {'colorfilters'}
        % Percent transmitted, same for photons or energy
        wave = sensorGet(sensor,'wave');
        data = sensorGet(sensor,'colorfilters');
        filterNames = sensorGet(sensor,'filterColorLettersCell');
        ystr = 'Transmittance';
        
    case 'irfilter'
        % Percent transmitted, same for photons or energy
        wave = sensorGet(sensor,'wave');
        data = sensorGet(sensor,'irfilter');
        filterNames = {'o'};
        ystr = 'Transmittance';
               
    case {'spectralqe','sensorspectralqe'}
        % Volts/irradiance(photons)
        wave = sensorGet(sensor,'wave');
        data = sensorGet(sensor,'spectral qe');
        filterNames = sensorGet(sensor,'filter Color Letters Cell');
        ystr = 'Quantum efficiency';
    case {'sensorspectralsr'}
        error('NYI implemented.  see pixelSR for conversion from QE to SR');
        
    otherwise
        disp('Unknown data type')
end

% Create the invisible figure here; the plot() calls go into this figure.
fighdl = ieNewGraphWin([],[],sprintf('ISET: %s',dataType'),'Visible','off');

for ii=1:size(data,2)
    switch lower(dataType)
        case 'irfilter'
            % There can be multiple IR filters
            plot(wave,data(:,ii),'k-'); hold on;
        otherwise
            if ~ismember(filterNames{ii},'rgbcmyk')
                plot(wave,data(:,ii),['k','-']);
            else
                plot(wave,data(:,ii),[filterNames{ii},'-']);
            end
            hold on;
    end
end

% Label, attach data to the figure.  Remember it is not yet visible.  That
% happens in the calling routine.
udata.x = wave; udata.y = data;
set(fighdl,'Userdata',udata);
xlabel('Wavelength (nm)'); 
ylabel(ystr);
grid on;

end

%%
function [uData, figNum] = imageNoise(noiseType,sensor)
% Gateway routine for plotting various types of image noise
%
%    [uData, figNum] = imageNoise([noiseType],[sensor])
%
% The default noise type is shot-noise (electron variance).  Other types
% are dsnu and prnu.  The shot-noise is generated on-the-fly.  The
% dsnuImage and prnuImage are taken from the sensor array.
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('noiseType'), noiseType = 'shotnoise'; end
if ieNotDefined('sensor'),  sensor = vcGetObject('sensor'); end

pixel = sensorGet(sensor,'pixel');
voltageswing = pixelGet(pixel,'voltageswing');

noiseType = ieParamFormat(noiseType);
switch lower(noiseType)
    case 'shotnoise'
        [theSignal,theNoise] = noiseShot(sensor);
        nameString = 'ISET:  Shot noise';
        titleString = sprintf('Max/min: [%.2E,%.2E] on voltage swing %.2f',max(theNoise(:)),min(theNoise(:)),voltageswing);

    case 'dsnu'
        [noisyImage,theNoise] = noiseFPN(sensor);
        nameString = 'ISET:  DSNU';
        titleString = sprintf('Max/min: [%.2E,%.2E] on voltage swing %.2f',max(theNoise(:)),min(theNoise(:)),voltageswing);

    case 'prnu'
        [noisyImage,dsnuNoise,theNoise] = noiseFPN(sensor);
        nameString = 'ISET:  PRNU';
        titleString = sprintf('Max/min: [%.2E,%.2E] slope',max(theNoise(:)),min(theNoise(:)));
        
    otherwise
        error('Unknown noise type.')
end

% Store data, put up image, label
uData.theNoise = theNoise;

figNum = ieNewGraphWin([],[],['ISET: ',nameString]);
title(titleString); 
imagesc(theNoise); 
colormap(gray(256)); colorbar;
axis off

end
%%

function [g,uData] = sensorPlotTwoLines(sensor,uData,uData2)
% Take data from two line plots and combine
%
% 

pixColor = [cell2mat(uData.pixColor),cell2mat(uData2.pixColor)];
pixPos = [uData.pos,uData2.pos];
pixData = [uData.data,uData2.data];

% Commented out was used to make subplots()
% nColors = numel(unique(pixColor));
% g = ieNewGraphWin([],'tall',[],'Visible','on');

mn = 0; mx = 0;
fColors = sensorGet(sensor,'filter plot colors');

% All the curves on the same graph
g = ieNewGraphWin([],[],[],'Visible','on');
for ii=1:numel(pixColor)
    thisColor = pixColor(ii);
    % subplot(nColors,1,thisColor)
    plot(pixPos{ii},pixData{ii},[fColors(thisColor),'-'],'Linewidth',1);
    mn = min(mn,min(pixPos{ii}));
    mx = max(mx,max(pixPos{ii}));
    hold on;
end

xlabel('Position (um)'); ylabel('volts');
grid on; set(gca,'xlim',[mn mx]);

clear uData;
uData.pixPos   = pixPos;
uData.pixData  = pixData;
uData.pixColor = pixColor;
end
