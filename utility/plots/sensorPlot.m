function [uData, g] = sensorPlot(sensor, pType, roiLocs, varargin)
% Gateway routine for plotting sensor data
%
%   [uData, hdl] = sensorPlot([sensor], pType, roiLocs, varargin)
%
% These plots characterizing the data, sensor parts, or performance of
% the sensor.  There are many types of plots, and as part of the function
% they also return the rendered data.  
%
% Inputs:
%  sensor: The image sensor
%  pType:  The plot type
%  roiLocs:  When needed, these specify the region of interest
%
% Additional arguments may be required for different plot types.
%
% Outputs:
%  uData:  Structure of the plotted (user data)
%  hdl:    Figure handle
%
% In general, you can prevent showing the figure by terminating the
% arguments with a string, 'no fig', as in
%
%   uData = sensorPlot(sensor,'volts vline ',[53 1],'no fig');
% 
% In this case, the data will be returned, but no figure will be produced.
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
  sensorWindow(sensor);
  sensorPlot(sensor,'electrons hline');
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
  uData = sensorPlot(sensor,'volts vline ',[53 1],'no fig');
%}
%{
  scene = sceneCreate; camera=cameraCreate;
  camera = cameraCompute(camera,scene);
  sensor = cameraGet(camera,'sensor');
  % sensorWindow(sensor);
  sensorPlot(sensor,'chromaticity',[30 30 10 10]);
%}

%% Parse arguments
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('pType'),  pType = 'volts hline'; end

uData = [];
pType = ieParamFormat(pType);

% For cases that need roiLocs, when none is passed in
if ieNotDefined('roiLocs')
    switch lower(pType)
        case {'voltshline','electronshline','dvhline'}
            
            % Get a location
            roiLocs = iePointSelect(sensor);
            sz = sensorGet(sensor,'size');
            ieROIDraw(sensor,'shape','line','shape data',[1 sz(2) roiLocs(2) roiLocs(2)]);

        case {'electronsvline','voltsvline','dvvline'}
            roiLocs = iePointSelect(sensor);
            sz = sensorGet(sensor,'size');
            ieROIDraw(sensor,'shape','line','shape data',[roiLocs(1) roiLocs(1) 1 sz(1)]);
            
        case {'electronshistogram','electronshist'...
                'voltshistogram','voltshist',...
                'chromaticity'}
            
            % Region of interest plots
            [roiLocs, roiRect] = ieROISelect(sensor);
            % ieROIDraw(sensor,'shape','rect','shape data',roiRect);

            % Store the rect for later plotting
            sensor = sensorSet(sensor,'roi',round(roiRect.Position));
            
        otherwise
            % There are some cases that are OK without an roiLocs value or
            % ROI. Such as 'snr'
    end
end

%% Plot 
switch pType
    
    % Sensor data related
    case {'electronshline'}
        [g, uData] = sensorPlotLine(sensor, 'h', 'electrons', 'space', roiLocs);
    case {'electronsvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'electrons', 'space', roiLocs);
    case {'voltshline'}
        sensorPlotLine(sensor, 'h', 'volts', 'space', roiLocs);
        % roiLocs(2) = roiLocs(2)+1;
        % [g, uData]  = sensorPlotLine(sensor, 'h', 'volts', 'space', roiLocs);
    case {'voltsvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'volts', 'space', roiLocs);
    case {'dvvline'}
        [g, uData]  = sensorPlotLine(sensor, 'v', 'dv', 'space', roiLocs);    
    case {'dvhline'}
        [g, uData]  = sensorPlotLine(sensor, 'h', 'dv', 'space', roiLocs);
    case {'voltshistogram','voltshist'}
        [uData,g] = plotSensorHist(sensor,'v',roiLocs);
    case {'electronshistogram','electronshist'}
        % sensorPlot(sensor,'electrons histogram',rect);
        [uData,g] = plotSensorHist(sensor,'e',roiLocs);
    case {'shotnoise'}
        [uData, g] = imageNoise('shot noise');
        
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
    case {'dsnu'}
        [uData, g] = imageNoise('dsnu');
    case {'prnu'}
        [uData, g] = imageNoise('prnu');

        % Optics related
    case {'etendue'}
        [uData, g] = plotSensorEtendue(sensor);
        
        % Human
    case {'conemosaic'} % Not sure
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

% We always create a window.  But, if the user doesn't want a window then
% plotSensor(......,'no fig'), we close the window but still return the
% data.
if ~isempty(varargin)
    figStatus = ieParamFormat(varargin{end});
    switch figStatus
        case {'nofig','nowindow'}
            close(g);
    end
end

% Attach the userdata to the figure.
if exist('uData','var'), set(gcf,'UserData',uData); end

end

%%
function [udata, figNum] = plotSpectra(sensor,dataType)
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

figNum = vcNewGraphWin;

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

% Label, attach data to the figure 
udata.x = wave; udata.y = data;
set(figNum,'Userdata',udata);
nameString = get(figNum,'Name');
set(figNum,'Name',sprintf('%s: %s',nameString,dataType'));
xlabel('Wavelength (nm)'); ylabel(ystr);
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
% Example:
%   imageNoise('shotNoise',vcGetObject('sensor'));
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

figNum = ieNewGraphWin;
imagesc(theNoise); colormap(gray(256)); colorbar;
nameFig    = get(figNum,'Name'); 
nameString = [nameFig,nameString];
set(figNum,'Name',nameString);
title(titleString); 
axis off

end
%%
