function [s, sensor, theRect] = sensorStats(sensor,statType,unitType,quiet)
% Calculate sensor statistics within a region of interest
%
% Syntax
%    [stats, sensor, theRect] = sensorStats(sensor,[statType],[unitType],[quiet])
%
% Inputs
%    sensor:     Either a sensor or an ROI.  If a sensor it may contain an
%                roi field of Nx2 matrix locations (TODO: should allow for
%                rect)  
%    statType:   'basic'
%    unitType:   'volts' or 'electrons'
%    quiet:       Do not show rect if true
%
% Returns:
%    stats:   Struct with the statistics
%    sensor:  The sensor is returned with the ROI added to it
%    theRect: Graphics object of the rect on the sensor window
%
% Description
%   Return some summary statistics from the sensor.  Only basic statistics,
%   mean, standard deviation and standard error of the mean are returned.
%   These can be computed either with respect to sensor volts or sensor
%   electrons.
%
%   If the routine is called without a return argument, the data are
%   plotted. 
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%  

% Examples:
%{
  [stats, sensor, theRect] = sensorStats;
  theRect.LineStyle = ':';
  delete(theRect);
%}
%{
  % Suppress showing the rect
  quiet = true;
  stats = sensorStats(sensor,'','',quiet);
%}
%{
  % Refresh the sensor window to delete the rect
  stats = sensorStats(sensor.roi);
%}
%{
  sensorStats(sensor,'mean');
%}

%% Parse inputs
if ieNotDefined('sensor')
    [~,sensor] = vcGetSelectedObject('ISA'); 
    roi = []; 
end
if ieNotDefined('quiet'),    quiet = false; end
if ieNotDefined('statType'), statType = 'basic'; end
if ieNotDefined('unitType'),  unitType = 'volts'; end

if isstruct(sensor) && ...
        isfield(sensor,'type') && ...
        isequal(sensor.type,'sensor')
else
    % The user did not send in a sensor, but just an ROI
    % So we assume user wants to use the currently selected sensor
    roi = sensor;
    %     if numel(roi) == 4
    %         roi = ieRect2Locs(roi);
    %     end
    [~,sensor] = vcGetSelectedObject('ISA');
    sensor = sensorSet(sensor,'roi',roi);
end

nSensors = sensorGet(sensor,'nsensors');

if exist('roi','var'), sensor.roi = roi; 
else,                  roi = [];
end

if isfield(sensor,'roi') && ~isempty(sensor.roi)
    % Use the sensor.roi
elseif isempty(roi) 
    % No information.  Help the user choose the ROI
    isaHdl = ieSessionGet('isahandle');
    ieInWindowMessage('Select image region.',isaHdl,[]);
    [~,rect] = vcROISelect(sensor);
    sensor = sensorSet(sensor,'roi',rect);
    ieInWindowMessage('',isaHdl);
else
    % The user sent an ROI and isa.roi does not exist.
    % Store this ROI
    sensor.roi = sensorSet(sensor,'roi',roi);
end

%% Get proper data type.  NaNs are still in there

switch lower(unitType)
    case {'volts'}
        data = sensorGet(sensor,'roi volts');
    case {'electrons'}
        data = sensorGet(sensor,'roi electrons');
    otherwise
        error('Unknown unit type')
end

%% Calculate statistics, dealing with all the NaNs

switch lower(statType)
    case 'mean'
        % Just the mean.
        % There is a sensorGet(sensor,'roi electrons mean') and for
        % volts, too.  Not used here because, well, ....
        if nSensors == 1
            tmp = data(:); l = ~isnan(tmp); tmp = tmp(l);
            s = mean(tmp);
        else
            s = zeros(3,1);
            for ii=1:nSensors
                tmp = data(:,ii); l = ~isnan(tmp); tmp = tmp(l);
                s(ii) = mean(tmp);
            end
        end
    case 'basic'
        % Mean, std, sem, and N
        if nSensors == 1
            tmp = data(:); l = ~isnan(tmp); tmp = tmp(l);
            s.mean = mean(tmp);
            s.std  = std(tmp);
            s.sem = s.std/sqrt(length(tmp) - 1);
            s.N = length(tmp);
        else
            for ii=1:nSensors
                tmp = data(:,ii); l = ~isnan(tmp); tmp = tmp(l);
                s.mean(ii) = mean(tmp);
                s.std(ii)  = std(tmp);
                s.sem(ii) = s.std(ii)/sqrt(length(tmp) - 1);
                s.N = length(tmp);
            end
        end
    otherwise
        error('Unknown statistic type.');
end

if ~quiet, [~,theRect] = sensorPlot(sensor,'roi'); end

%% No arguments returned, so the user just wanted the plots

if nargout == 0
    % Open up a clean new figure
    figNum = ieNewGraphWin;

    switch lower(statType)
        case 'basic'
            txt = sprintf('Mean: %.2f',s.mean(1));
            if nSensors == 1
                errorbar([1:nSensors],s.mean,s.std,'ko-');
            else
                for ii=2:nSensors
                    txt = addText(txt,sprintf('\nMean: %.2f',s.mean(ii)));
                end
                errorbar([1:nSensors],s.mean,s.std);
            end
            plotTextString(txt,'ur');
            
            [~,sensor] = vcGetSelectedObject('ISA');
            filterType = sensorGet(sensor,'filter names cellarray');
            set(gca,'xtick',1:nSensors,'xticklabel',filterType);
            xlabel('Sensor color type');
            switch lower(unitType)
                case 'volts'
                    ylabel('Volts');
                    set(gca,'ylim',[0,pixelGet(sensorGet(sensor,'pixel'),'voltageswing')]);
                case 'electrons'
                    ylabel('Electrons');
                    set(gca,'ylim',[0,pixelGet(sensorGet(sensor,'pixel'),'wellcapacity')]);
            end
            set(gca,'xtick',(1:nSensors),'xticklabel',filterType);
            title(sprintf('Mean %s in ROI',unitType));
            
            grid on
        case 'mean'
            % sensorStats(sensor,'mean',unitType)
            
            % Simple bar plot
            h = bar(s); grid on; 
            h.FaceColor = [0.3 0.3 0.6];
            h.EdgeColor = [0.5 0.5 0.5];
            
            filterType = sensorGet(sensor,'filter names cellarray');
            set(gca,'xticklabels',filterType)
            ylabel(sprintf('%s',unitType));
            title(sprintf('Mean %s in ROI',unitType));
        otherwise
            error('Unknown stat type');
    end
    set(figNum,'userdata',s);
end


end