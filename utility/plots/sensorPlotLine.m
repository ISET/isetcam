function [figNum, uData] = sensorPlotLine(sensor, ori, dataType, sORt, xy)
% Plot a line of sensor data
%
% Synopsis:
%   [uData, figNum] = ...
%   sensorPlotLine([sensor],[ori='h'],[dataType ='dv'],[spaceOrTransform = 'space'],[xy])
%
% Description:
%   Plot the values in the sensor array taken from a horizontal or vertical
%   line.  The line passes through the  point xy.
%
% Inputs
%  sensor:   ISET sensor structure.  Default:  vcGetObject('sensor')
%  ori:      Orientation of line ('h' or 'v', default: 'h')
%  dataType: {'electrons','photons'},'volts','dv'  (Default: 'electrons').
%             If a human sensor, 'electrons' plots label the y axis as
%            'absorptions'. Human is determined if there is a sensor field,
%            'human'.
%  sORt:     Plot the space or transform domain.  Transform (frequency) is
%           weird and doesn't work properly for human.  Default: 'space'
%  xy:       Point (col,row) for determining the horizontal or vertical line.
%
% Set the sORt flag to
%   {'spatial','space','spacedomain'} (default)
%   {'transform','fourier','fourierdomain','fft'}
%
%  If no xy position is specified, the user is prompted to select using a
%  crosshair on the sensor image window.  Otherwise,
%   If the orientation is 'h' (horizontal) a row containing xy is plotted
%   If orientation is 'v' (vertical) a column containing xy is plotted.
%
% Returns:
%   figNum
%   uData: The data plotted in the figure are returned in this structure.
%
% Example:
%  row = sensorGet(ieGetObject('sensor'),'rows'); row = round(row/2);
%  sData = sensorPlotLine([],'h','volts','space',[1,row])
%
% Internal functions:
%   plotColorISALines
%   plotMonochromeISALines
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   sensorPlot


%%
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('ori'), ori = 'h'; end
if ieNotDefined('dataType'), dataType =  'electrons'; end
if ieNotDefined('sORt'), sORt = 'space'; end
if ieNotDefined('xy'), xy = vcLineSelect(sensor); end

sSupport = sensorGet(sensor,'spatialSupport','microns');

data = sensorGet(sensor,dataType);
if isempty(data), warndlg(sprintf('Data type %s unavailable.',dataType)); return; end

%% Find the line in the sensor window.
nSensors = sensorGet(sensor,'nSensors');

switch lower(ori)
    case {'h','horizontal'}
        pos = sSupport.x;
        if nSensors == 1, data = squeeze(data(xy(2),:)); end
    case {'v','vertical'}
        pos = sSupport.y;
        if nSensors == 1, data = squeeze(data(:,xy(1))); end
    otherwise
        error('Unknown orientation')
end

%% Plot it

if nSensors > 1
    figNum = ieNewGraphWin([],'tall');  % Easier to see
    data = plane2rgb(data,sensor,NaN);
    fColors = sensorGet(sensor,'filterPlotColors');
    if strcmp(dataType,'electrons') && isfield(sensor,'human')  || ...
            strcmp(dataType,'photons') || strcmp(dataType,'absorptions')
        % In the human case or if listed as photons, we plot absorptions,
        % not electrons
        dataType = 'absorptions';
    end
    uData = plotColorISALines(xy,pos,data,ori,nSensors,dataType,sORt,fColors,figNum);
elseif nSensors == 1
    figNum = vcNewGraphWin;
    uData = plotMonochromeISALines(xy,pos,data,ori,dataType,sORt,figNum);
end

% Should set(gca,'xlim',[XX YY]) the same for all of these, sigh.

end

%----------------------------------------
function uData = plotColorISALines(xy,pos,data,ori,nSensors,dataType,sORt,fColors,figNum)
%
% Internal routine:  Deal with color sensor case, both CMY and RGB.
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

nColors = 0;
for ii = 1:nSensors
    d = lData{ii};  % These are the data from the ith sensor
    
    % Skip the black sensor
    l = find(~isnan(d));
    if isempty(l)
        % No data for this pixel type on this row
    else
        % These are cell arrays because for some sensors, like the human
        % cones, there are uneven numbers of samples on every row.
        nColors = nColors + 1;
        pixPlot{nColors} = [fColors(ii),'-']; %#ok<AGROW>
        pixPos{nColors}  = pos(l)'; %#ok<AGROW>
        tmp = d(l);
        pixData{nColors} = tmp(:); %#ok<AGROW>
    end
end

% Should we have pos1 = pos(1:2:end) and pos2 = pos(2:2:end)?
% pixPlot = cell(1,nColors);  % Colors and symbol
mx = 0; xMax = 0; xMin = 0;
for ii=1:nColors
    % Y-axis is from 0 to max.
    mx = max(mx,max(pixData{ii}));
    % X-axis plotting range is from negative to positive
    xMax = max(xMax,max(pixPos{ii}));
    xMin = min(xMin,min(pixPos{ii}));
end

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

set(figNum,'userdata',uData);
set(figNum,'Name',titleString);

end

%----------------------------------------
function uData = plotMonochromeISALines(xy,pos,data,ori,dataType,sORt,figNum)
%
% Internal routine:  Deal with monochrome sensor case.
%

switch lower(ori)
    case {'h','horizontal'}
        titleString =sprintf('ISET:  Horizontal line %.0f',xy(2));
        xstr = 'Col number';
    case {'v','vertical'}
        titleString =sprintf('ISET:  Vertical line %.0f',xy(1));
        xstr = 'Row number';
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
        
        % Attach data to figure and label.
        set(figNum,'userdata',uData);
        set(figNum,'Name',titleString);
    otherwise
        error('Unknown sORt');
end

% Attach data to figure and label.
set(figNum,'userdata',uData);
set(figNum,'Name',titleString);

end

