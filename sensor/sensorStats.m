function [uData, sensor, theRect] = sensorStats(sensor,statType,unitType,quiet)
% Calculate sensor statistics within a region of interest selected by user
%
% Syntax
%    [stats, sensor, theRect] = sensorStats(sensor,[statType],[unitType],[quiet])
%
% Inputs
%    sensor:     A sensor it may contain an roi field of Nx2 matrix
%                locations or a rect 
%    statType:   'basic'
%    unitType:   'volts' or 'electrons'
%    quiet:       Do not draw rect if true
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
if ieNotDefined('sensor'),    error('Sensor must be provided.'); end
if ieNotDefined('quiet'),     quiet = false; end
if ieNotDefined('statType'),  statType = 'basic'; end
if ieNotDefined('unitType'),  unitType = 'volts'; end

assert(isstruct(sensor) && isfield(sensor,'type') ...
                        && isequal(sensor.type,'sensor'));

nSensors = sensorGet(sensor,'nsensors');

% We ignore the sensor.roi in this case.  The user always selects.  But
% maybe we should allow the user to set.
isaHdl = ieSessionGet('isahandle');
ieInWindowMessage('Select image region.',isaHdl,[]);
[~,rect] = vcROISelect(sensor);
sensor = sensorSet(sensor,'roi',rect);
ieInWindowMessage('',isaHdl);

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
            uData = mean(tmp);
        else
            uData = zeros(3,1);
            for ii=1:nSensors
                tmp = data(:,ii); l = ~isnan(tmp); tmp = tmp(l);
                uData(ii) = mean(tmp);
            end
        end
    case 'basic'
        % Mean, std, sem, and N
        if nSensors == 1
            tmp = data(:); l = ~isnan(tmp); tmp = tmp(l);
            uData.mean = mean(tmp);
            uData.std  = std(tmp);
            uData.sem = uData.std/sqrt(length(tmp) - 1);
            uData.N = length(tmp);
        else
            for ii=1:nSensors
                tmp = data(:,ii); l = ~isnan(tmp); tmp = tmp(l);
                uData.mean(ii) = mean(tmp);
                uData.std(ii)  = std(tmp);
                uData.sem(ii) = uData.std(ii)/sqrt(length(tmp) - 1);
                uData.N = length(tmp);
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
            % sensorStats(sensor,'basic', unitType)
            txt = sprintf('Mean: %.2e (%.2e)',uData.mean(1),uData.std(1));
            if nSensors == 1
                errorbar(1:nSensors,uData.mean,uData.std,'ko-');
            else
                for ii=2:nSensors
                    txt = addText(txt,sprintf('\nMean: %.2e (%.2e)',uData.mean(ii),uData.std(ii)));
                end
                % errorbar(1:nSensors,uData.mean,uData.std);
                hdl = bar(1:nSensors,uData.mean);
                hdl.FaceColor = 'flat';
                hdl.CData = eye(3);
                
            end
            plotTextString(txt,'ur');
            
            sensor = ieGetObject('sensor');
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
            title(sprintf('Mean %uData in ROI',unitType));
            
            grid on
        case 'mean'
            % sensorStats(sensor,'mean',unitType)
            
            % Simple bar plot
            h = bar(uData); grid on; 
            h.FaceColor = [0.3 0.3 0.6];
            h.EdgeColor = [0.5 0.5 0.5];
            
            filterType = sensorGet(sensor,'filter names cellarray');
            set(gca,'xticklabels',filterType)
            ylabel(sprintf('%uData',unitType));
            title(sprintf('Mean %uData in ROI',unitType));
        otherwise
            error('Unknown stat type');
    end
    set(figNum,'userdata',uData);
end


end