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
%  'electrons hline'
%  'electrons vline'
%  'volts hline'
%  'volts vline'
%  'dv vline'
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
% Electrical properties
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
% See also
%   scenePlot, oiPlot, ipPlot

%Examples:
%{
  scene = sceneCreate;
  scene = sceneSet(scene,'fov',2);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate; sensor = sensorCompute(sensor,oi);

  uData = sensorPlot(sensor,'electrons hline',[20 20]);
  isequal(uData,get(gcf,'UserData'))

  sensorPlot(sensor,'volts vline',[20 20]);
  get(gfc,'UserData')

  uData = sensorPlot(sensor,'volts vline ',[53 1],'no fig');
%}

%% Parse arguments
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('pType'),  pType = 'volts hline'; end

uData = [];
pType = ieParamFormat(pType);

% For cases that need roiLocs, when none is passed in
if ieNotDefined('roiLocs')
    switch lower(pType)
        case {'voltshline','electronshline',...
                'voltsvline', 'electronsvline', ...
                'dvvline', 'dvhline'}
            
            % Get a location
            roiLocs = vcPointSelect(sensor);
            
        case {'electronshistogram','electronshist'...
                'voltshistogram','voltshist'}
            % Region of interest plots
            [roiLocs, roiRect] = vcROISelect(sensor);
            % Store the rect for later plotting
            sensor = sensorSet(sensor,'roi',roiRect);
            
        otherwise
            % There are some cases that are OK without an roiLocs value or
            % ROI. Such as 'snr'
    end
end

% Deal with these:  sensorPlotLine, sensorPlotColor,
% sensorPlotMultipleLines, sensorPlot

%% Plot 
switch pType
    
    % Sensor data related
    case {'electronshline'}
        [uData, g] = sensorPlotLine(sensor, 'h', 'electrons', 'space', roiLocs);
    case {'electronsvline'}
        [uData, g] = sensorPlotLine(sensor, 'v', 'electrons', 'space', roiLocs);
    case {'voltshline'}
        [uData, g] = sensorPlotLine(sensor, 'h', 'volts', 'space', roiLocs);
    case {'voltsvline'}
        [uData, g] = sensorPlotLine(sensor, 'v', 'volts', 'space', roiLocs);
    case {'dvvline'}
        [uData, g] = sensorPlotLine(sensor, 'v', 'dv', 'space', roiLocs);    
    case {'dvhline'}
        [uData, g] = sensorPlotLine(sensor, 'h', 'dv', 'space', roiLocs);
    case {'voltshistogram','voltshist'}
        [uData,g] = plotSensorHist(sensor,'v',roiLocs);
        sensorPlot(sensor,'roi');
    case {'electronshistogram','electronshist'}
        % sensorPlot(sensor,'electrons histogram');
        [uData,g] = plotSensorHist(sensor,'e',roiLocs);
        sensorPlot(sensor,'roi');
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
        
    case {'roi'}
        % [uData,g] = sensorPlot(sensor,'roi');
        %
        % If the roi is a rect, use its values to plot a white rectangle on
        % the sensor image.  The returned graphics object is a rectangle
        % (g) and you can adjust the colors and linewidth using it.
        if ~isfield(sensor,'roi')
            [~,rect] = vcROISelect(sensor);
            sensor = sensorSet(sensor,'roi',rect);
        elseif numel(sensor.roi) ~= 4
            error('roi must be a rect');
        end
        
        % Make sure the sensor window is selected
        sensorImageWindow;
        g = rectangle('Position',sensor.roi,'EdgeColor','w','LineWidth',2);
    otherwise
        error('Unknown sensor plot type %s\n',pType);
end

% We always create a window.  But, if the user doesn't want a window then
% plotSensor(......,'no fig')  then we close the window, but still return
% the data.
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



%% Below are many auxiliary routines that carry out the plots
% There are many because there are so many special cases and types of
% plots.  We could move these routines out of here (which is where they
% started). But for now let's try keeping all the plotSensor stuff together
% in here.

%% Methods for plotting lines of data
%
% ** Deprecated - replaced by sensorPlotLine **
%
% These are implemented as an overall line plot and then special cases for
% color and monochrome sensors, and a further special case for integrating
% data across multiple lines.
%{
function [uData, figNum] = plotSensorLine(sensor, ori, dataType, sORt, xy)
% Plot a line of sensor data
%
%   [uData, figNum] = ...
%   plotSensorLine([sensor],[ori='h'],[dataType ='dv'],[spaceOrTransform = 'space'],[xy])
%
% Plot the values in the sensor array taken from a horizontal or vertical
% line.  The line passes through the  point xy.
%
% sensor:   ISET sensor structure.  Default:  vcGetObject('sensor')
% ori:      Orientation of line ('h' or 'v', default: 'h')
% dataType: {'electrons','photons'},'volts','dv'  (Default: 'electrons').
%            If a human sensor, 'electrons' plots label the y axis as
%            'absorptions'. Human is determined if there is a sensor field,
%            'human'.
% sORt:     Plot the space or transform domain.  Transform (frequency) is
%           weird and doesn't work properly for human.  Default: 'space'
% xy:       Point (col,row) for determining the horizontal or vertical line.
%
% Set the sORt flag to
%   {'spatial','space','spacedomain'} (default)
%   {'transform','fourier','fourierdomain','fft'}
%%

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('ori'), ori = 'h'; end
if ieNotDefined('dataType'), dataType =  'electrons'; end
if ieNotDefined('sORt'), sORt = 'space'; end
if ieNotDefined('xy'), xy = vcLineSelect(sensor); end

sSupport = sensorGet(sensor,'spatialSupport','microns');
switch ori
    case {'h','horizontal'}
        pos = sSupport.x;
    case {'v','vertical'}
        pos = sSupport.y;
    otherwise
end

data = sensorGet(sensor,dataType);
if isempty(data), warndlg(sprintf('Data type %s unavailable.',dataType)); return; end

%% Find the line in the sensor window.
nSensors = sensorGet(sensor,'nSensors');

%% Plot the data differently for monochrome and color (multiband)
if nSensors > 1
    data = plane2rgb(data,sensor,NaN);
    fColors = sensorGet(sensor,'filterPlotColors');
    if strcmp(dataType,'electrons') && isfield(sensor,'human')  || ...
            strcmp(dataType,'photons') || strcmp(dataType,'absorptions')
        % In the human case or if listed as photons, we plot absorptions,
        % not electrons
        dataType = 'absorptions';
    end    
    [uData, figNum] = plotSensorLineColor(xy,pos,data,ori,nSensors,dataType,sORt,fColors);
elseif nSensors == 1
    % figNum = vcNewGraphWin;
    switch lower(ori)
    case {'h','horizontal'}
        data = squeeze(data(xy(2),:));
    case {'v','vertical'}
        data = squeeze(data(:,xy(1))); 
    otherwise
        error('Unknown orientation')
    end
    [uData, figNum] = plotSensorLineMonochrome(xy,pos,data,ori,dataType,sORt);
end
end

%% Color sensor line
function [uData, figNum] = plotSensorLineColor(xy,pos,data,ori,nSensors,dataType,sORt,fColors)
%
% Deal with color sensor case, both CMY and RGB.
%

%% Get a line's worth of data from the full data set
% I started to create gets like
%   lData = sensorGet(sensor,'data hline electrons',xy);
%
lData = cell(nSensors,1);
switch lower(ori)
    case {'h','horizontal'}
        for ii=1:nSensors, lData{ii} = data(xy(2),:,ii); end
        titleString =sprintf('ISET:  Horizontal line %.0f',xy(2));
        xstr = 'Position (um)';
    case {'v','vertical'}
        for ii=1:nSensors, lData{ii} = data(:,xy(1),ii); end
        titleString =sprintf('ISET:  Vertical line %.0f',xy(1));
        xstr = 'Position (um)';
    otherwise
        error('Unknown line orientation');
end

%% Decide on window shape.
% If there is only one color filter with data, don't make the window
% tall. 
dataSet = 0;
for ii=1:nSensors
    if ~isempty(find(~isnan(lData{ii}), 1)), dataSet = dataSet + 1; end
end

% Shouldn't we check if we want a figure?
if dataSet > 1,  figNum = vcNewGraphWin([],'tall');
else figNum = vcNewGraphWin;
end

%% Pull out the relevant points for plotting
nColors = 0;
for ii = 1:nSensors
    d = lData{ii};  % These are the data from the ith sensor
    
    % Skip the black sensor
    l = find(~isnan(d));
    if isempty(l)
        % No data for this pixel type on this row
    else
        % Pixel data are cell arrays because for some sensors, like the
        % human cones, there are uneven numbers of samples on every row.
        nColors = nColors + 1;
        pixPlot{nColors} = [fColors(ii),'-']; %#ok<AGROW>
        pixPos{nColors}  = pos(l)'; %#ok<AGROW>
        tmp = d(l);
        pixData{nColors} = tmp(:); %#ok<AGROW>
    end
end

% Determine range
mx = 0; xMax = 0; xMin = 0;
for ii=1:nColors
    % Y-axis is from 0 to max.
    mx = max(mx,max(pixData{ii}));
    % X-axis plotting range is from negative to positive
    xMax = max(xMax,max(pixPos{ii}));
    xMin = min(xMin,min(pixPos{ii}));
end

%% Plot
% figNum = vcNewGraphWin([],'tall');
for ii=1:nColors
    % Build the subplot panels using the appropriate colors.
    subplot(nColors,1,ii);
    switch lower(sORt)
        case {'spatial','space','spacedomain'}
            % pixPlot{ii} = [pixPlot{ii},'o']; % To add circles
            % pixPlot{ii} = [pixPlot{ii},'-']; %
            % plot(pixPos(:,ii),pixData(:,ii),pixPlot{ii});
            p = plot(pixPos{ii},pixData{ii},pixPlot{ii});
            set(p,'linewidth',2);
            ystr = sprintf('%s',dataType); xlabel(xstr); ylabel(ystr);
            set(gca,'xtick',ieChooseTickMarks(pos)); grid on;
            set(gca,'ylim',[0 1.05*mx]);
            set(gca,'xlim',[xMin xMax]);
            
            % Attach data to figure and label.
            % uData.pos(:,ii) = pos(:); uData.data(:,ii) = pixData(:,ii);
            uData.pos{ii} = pixPos{ii}; uData.data{ii} = pixData{ii};
        case {'transform','fourier','fourierdomain','fft'}
            
            % We have a problem in this code.  The pixPos needs to be
            % interpolated to the same number and spacing of sample
            % positions for this to make sense.
            
            % Data are in microns.  Convert to mm for linepair/mm
            normalize = 1;
            [freq,pixAmp] = ieSpace2Amp(pixPos{ii}*1e-3,pixData{ii},normalize);
            
            plot(freq,pixAmp,pixPlot{ii});
            xlabel('Cycles/mm'); ylabel('Normalized amp');
            set(gca,'xtick',ieChooseTickMarks(freq)); grid on;
            set(gca,'ylim',[0 1]);
            
            % Should we try to put a vertical line at the Nyquist sampling
            % frequency, measured in lines/mm.  That is at one cycle per
            % two samples (delta).  So we want to know how many
            % delta/mm
            delta = pixPos{ii}(2) - pixPos{ii}(2);
            nyquist = (1/delta)*1000;
            line([nyquist,nyquist],[0,1],'color','k');
            text(nyquist*0.95,0.75,'half-sampling')
            
            % Attach data to figure and label.
            %             uData.pos(:,ii) = freq(:); uData.data(:,ii) = pixAmp;
            %             uData.freq(:,ii) = freq(:); uData.amp(:,ii) = pixAmp; uData.mean(:,ii) = pixAmp(1);
            %             uData.peakContrast(:,ii) = max(pixAmp(:))/pixAmp(1);
        otherwise
            error('Unknown sORt');
    end
end


%% Attach the data
set(figNum,'userdata',uData);
set(figNum,'Name',titleString);


end
%}

%% Monocrhome sensor line
function [uData, figNum] = plotSensorLineMonochrome(xy,pos,data,ori,dataType,sORt)
%
% Monochrome sensor line plot
%
figNum = vcNewGraphWin;
switch lower(ori)
    case {'h','horizontal'}
        titleString =sprintf('ISET:  Horizontal line %.0f',xy(2));
    case {'v','vertical'}
        titleString =sprintf('ISET:  Vertical line %.0f',xy(1));
    otherwise
        error('Unknown linear orientation')
end

switch lower(sORt)
    case {'spatial','space','spacedomain'}
        plot(pos,data,'b-');
        xlabel('X-Position (um)');
        ystr = sprintf('%s',dataType); ylabel(ystr);
        tickLocs = ieChooseTickMarks(pos);
        set(gca,'xtick',tickLocs);
        grid on; uData.pos = pos;uData.data = data;
        
    case {'transform','fourier','fourierdomain','fft'}
        % The data come in specified in microns.  We convert to millimeters
        % for the linepair/mm convention and compute the transformation
        normalize = 1;
        [freq,dataAmp] = ieSpace2Amp(pos*1e-3,data, normalize);
        plot(freq,dataAmp,'b-'); xlabel('Cycles/mm'); ylabel('Normalized amplitude');
        tickLocs = ieChooseTickMarks(pos);
        set(gca,'xtick',tickLocs);
        grid on;
        uData.freq = freq; uData.amp = dataAmp; uData.mean = dataAmp(1);
        uData.peakContrast = max(dataAmp(:))/dataAmp(1);
        
    otherwise
        error('Unknown sORt');
end

% Attach data to figure and label.
set(figNum,'userdata',uData);
set(figNum,'Name',titleString);

end

%% Multiple lines
function [uData, g] = plotSensorLineMultiple(sensor,nLines,ori,xy)
%
% Under development
%
%
% (c)

% sensor = sensorCompute(sensor,oi);
% sensor = sensorSet(sensor,'name','4 bars');
% sz = sensorGet(sensor,'size');
% sensorPlotLine(sensor,'h','photons','space',[1,sz(1)]);
% vcAddAndSelectObject(sensor); sensorWindow('scale',1);

%% Start of a script to plot a series of rows, pRows
% midRow = round(sz(1)/2);
% pRows = ((-3:3)+midRow);
% nRows = length(pRows);
% sz = sensorGet(sensor,'size');
% uData = cell(nRows,1);
% for ii=1:nRows
%     [tmp,uData{ii}] = sensorPlotLine(sensor,'h','photons','space',[1,pRows(ii)]);
% end
% % Need to turn off sensorPlotLine plotting
% close all
%
% l.pos = []; m.pos = []; s.pos = [];
% l.data = []; m.data = []; s.data = [];
% for ii=1:nRows
%     l.pos = [l.pos;uData{ii}.pos{1}]; l.data = [l.data; uData{ii}.data{1}];
%     m.pos = [m.pos;uData{ii}.pos{2}]; m.data = [m.data; uData{ii}.data{2}];
%     s.pos = [s.pos;uData{ii}.pos{3}]; s.data = [s.data; uData{ii}.data{3}];
% end
% vcNewGraphWin;
% plot(l.pos,l.data,'.'); grid on
% vcNewGraphWin;
% plot(m.pos,m.data,'.'); grid on
% vcNewGraphWin;
% plot(s.pos,s.data,'.'); grid on
%
end

%% Sensor cross-correlations - Not in here ...
% function plotSensorColorCorrelations(sa,type)
% % Plot sensor cross-correlations
% %
% %     sensorColorPlot(sa,[type=RB'])
% %
% % This routine analyzes the scene color properties, usually color
% % balancing. The routine produces a graph that includes the
% % cross-corrrelation and indicates the expected distribution assuming
% % various different color temperatures of the ambient illumination.
% %
% % Example:
% %   sensor = vcGetObject('ISA');
% %   sensorPlotColor(sensor,'rg')
% %
% % Copyright ImagEval Consultants, LLC, 2005.
% 
% % TODO:  This should be moved into plotSensor as a case statement.  After
% % we write plotSensor, sigh.
% 
% if ieNotDefined('sa'), sa=vcGetObject('isa'); end
% if ieNotDefined('type'), type = 'rg'; end
% labels = {'Red sensor','Green sensor','Blue sensor'};
% 
% % Demosiac the (R,B) values.
% wave = sensorGet(sa,'wave');
% spectralQE = sensorGet(sa,'spectralQE');
% 
% % We need a default, target display to do the demosaic'ing
% demosaicedImage = Demosaic(ipCreate,sa);
% 
% figNum =  vcNewGraphWin;
% 
% switch lower(type)
%     case 'rg'
%         dList = [1,2];
%     case 'rb'
%         dList = [1,3];
%     otherwise
%         error('Unknown plot type.');
% end
% 
% % Make the escatter plot after demosaicing the sensor data
% d1 = demosaicedImage(:,:,dList(1));
% d2 = demosaicedImage(:,:,dList(2));
% d = sqrt(d1.^2 + d2.^2);
% d = max(d(:));
% 
% % We should probably check to see that d1,d2 aren't too big.  If they are
% % randomly sample.
% plot(d1(:),d2(:),'.'); axis equal
% xlabel(labels{dList(1)}); ylabel(labels{dList(2)});
% 
% % Estimate the slope for white surfaces at these color temperatures
% cTemp = [2500,3000,3500,4000,4500,5500,6500,8000,10500];
% 
% for ii=1:length(cTemp)
%     spec = Energy2Quanta(wave,blackbody(wave, cTemp(ii) ));
%     rgb = spectralQE'*spec;
%     rgb = 0.9*d*(rgb/sqrt(sum(rgb(dList).^2)));
%     txt = sprintf('%.1fK',round(cTemp(ii)/100)/10);
%     hold on; plot(rgb(dList(1)),rgb(dList(2)),'k.');
%     text(rgb(dList(1))+0.02,rgb(dList(2)),txt)
% end
% hold off
% 
% set(gca,'xlim',[0 d], 'ylim', [0,d])
% title('Sensor Color Balance');
% grid on;
% 
% uData.name = 'sensorColorPlot';
% uData.d1 = d1;
% uData.d2 = d2;
% uData.rgb = rgb;
% set(figNum,'userdata',uData);
% 
% end

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
            if ~ismember(filterNames{ii},'rgbcmyk'),
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

figNum = vcNewGraphWin;
imagesc(theNoise); colormap(gray(256)); colorbar;
nameFig    = get(figNum,'Name'); 
nameString = [nameFig,nameString];
set(figNum,'Name',nameString);
title(titleString); 
axis off

end

