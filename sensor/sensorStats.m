function s = sensorStats(roi,statType,unitType)
% Calculate sensor statistics within a region of interest
%
%    s = sensorStats(roi,[statType],[unitType])
%
% Purpose:
%   At present, the summary statistics are only mean, standard deviation
%   and standard error of the mean.  These can be computed either with
%   respect to sensor volts or sensor electrons.
%
%   If the routine is called without a return argument, the data are shown
%   in a graph window.
%
% Examples:
%   s = sensorStats;
%   sensorStats;
%
% Copyright ImagEval Consultants, LLC, 2005.

if ~exist('statType','var'), statType = 'basic'; end
if ~exist('unitType','var'), unitType = 'volts'; end

[val,isa] = vcGetSelectedObject('ISA');
nSensors = sensorGet(isa,'nsensors');

if ~exist('roi','var') | isempty(roi)
    isaHdl = ieSessionGet('isahandle');
    ieInWindowMessage('Select image region.',isaHdl,[]);

    % This is not returned, so the assignment is useless.  Fix.
    isa.roi = vcROISelect(isa);
    
    ieInWindowMessage('',isaHdl);

else
    isa.roi = roi;
end

switch lower(unitType)
    case {'volts','v'}
        data = sensorGet(isa,'roivolts');
        unitType = 'v';
    case {'electrons','e'}
        data = sensorGet(isa,'roielectrons');
        unitType = 'e';
    otherwise
        error('Unknown unit type')
end

switch lower(statType)
    case 'basic'
        if nSensors == 1
            tmp = data(:);
            l = ~isnan(tmp); tmp = tmp(l);
            s.mean = mean(tmp);
            s.std  = std(tmp);
            s.sem = s.std/sqrt(length(tmp) - 1);
            s.N = length(tmp);
        else
            for ii=1:nSensors
                tmp = data(:,ii);
                l = ~isnan(tmp);
                tmp = tmp(l);
                s.mean(ii) = mean(tmp);
                s.std(ii)  = std(tmp);
                s.sem(ii) = s.std(ii)/sqrt(length(tmp) - 1);
                s.N = length(tmp);
            end
        end
    otherwise
        error('Unknown statistic type.');
end

if nargout == 0
    switch lower(statType)
        case 'basic'
            figNum = vcNewGraphWin;
            set(figNum,'userdata',s);
            
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
            
            [val,isa] = vcGetSelectedObject('ISA');
            filterType = sensorGet(isa,'filternamescellarray');
            set(gca,'xtick',1:nSensors,'xticklabel',filterType);
            xlabel('Sensor color type');
            switch lower(unitType)
                case 'v'
                    ylabel('Volts');
                    set(gca,'ylim',[0,pixelGet(sensorGet(isa,'pixel'),'voltageswing')]);
                case 'e'
                    ylabel('Electrons');
                    set(gca,'ylim',[0,pixelGet(sensorGet(isa,'pixel'),'wellcapacity')]);
            end
            set(gca,'xtick',[1:nSensors],'xticklabel',filterType);
            title('Mean in ROI');
            
            grid on
        otherwise
            error('Unknown stat type');
    end
end

return;