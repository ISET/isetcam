function [data,figNum, theRect] = plotSensorHistogram(unitType)
% Select data and plot a histogram from each color channel
%
%    *** Deprecated ***
%
% Syntax
%   [data,figNum, theRect] = plotSensorHistogram([unitType])
%
% Inputs
%
% Description
%  Create a multiple panel plot showing the pixel voltages or electrons in
%  a region selected by the user. 
%
%  The data returns the region of interest with electrons or volts.  In
%  each channel the non-sampled measurements are NaNs.  To get these out,
%  you can use l = ~isnan(data(:,1)), for example.
%
% See also
%

% Examples:
%{
  [data,figNum] = plotSensorHistogram('v');
  [data,figNum] = plotSensorHistogram('e')
%}

%% Always use the currently selected sensor
sensor = vcGetObject('sensor');

%% Select the data from the current sensor window
handles = ieSessionGet('sensorimagehandle');
ieInWindowMessage('Select image region of interest.',handles,[]);
[~,sensor.roi] = vcROISelect(sensor);
ieInWindowMessage('',handles,[]);

% Make sure the graph window is set
figNum = vcNewGraphWin;

% Get the data and plot them
switch lower(unitType)
    case {'v','volts'}
        data   = sensorGet(sensor,'roivolts');
    case {'e','electrons'}
        data   = sensorGet(sensor,'roielectrons');
    otherwise
        error('Unknown unit type.');
end

nSensors = sensorGet(sensor,'nsensors');

if nSensors == 1
    plotMonochromeSensorHist(data,unitType)
else
    colorOrder = sensorGet(sensor,'filterColorLetters');
    plotColorSensorHist(data,nSensors,unitType,colorOrder);
end

% Do we attach the sensor with the ROI to vcSESSION?  Or just forget it?
% Attach data to the figure
set(figNum,'Userdata',data);
[~,theRect] = sensorPlot(sensor,'roi');

end

%---------------
function plotColorSensorHist(data,nSensors,unitType,colorOrder)
% Perhaps we should plot the saturation level on the graph?
%

mxData = max(data(:))*1.2;
nBins = round(max(20,size(data,1)/25));
for ii=1:nSensors
    subplot(1,nSensors,ii)
    
    l = ~isnan(data(:,ii)); tmp = data(l,ii);
    histogram(tmp,nBins);
    c = get(gca,'Children');
    if strcmp(colorOrder(ii) ,'o'), colorOrder(ii) = 'k'; end
    set(c,'EdgeColor',colorOrder(ii))
    
    % We might want to show the SNR in db some day.
    %     mn = mean(tmp);
    %     sd= std(tmp);
    %     txt = sprintf('Mean: %.02e\nSD:   %.03e\nSNR (db)=%.03f',mn,sd,20*log10(mn/sd));
    %     plotTextString(txt,'ul');  % And I think that 'ul' may not be
    %     working right.
    
    set(gca,'xlim',[0 mxData*1.1]);
    grid on
    switch lower(unitType)
        case 'v'
            xlabel('Volts')
        case 'e'
            xlabel('Electrons')
    end
   ylabel('Count');
end

end

%---------------
function plotMonochromeSensorHist(data,unitType)

histogram(data(:,1));
mxData = max(data(:))*1.2;

set(gca,'xlim',[0 mxData*1.1]);
grid on
switch lower(unitType)
    case 'v'
        xlabel('Volts')
    case 'e'
        xlabel('Electrons')
end
ylabel('Count');

end


