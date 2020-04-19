function [uData,figNum] = plotSensorHist(sensor,unitType,roiLocs)
%
% Syntax
%  [uData, figNum] = plotSensorHist(sensor,unitType,roiLocs)
%
% sensor:    ISET sensor structure (color or monochrome)
% unitType:  electrons or volts
% roiLocs:   from a vcSelectROI call
%
%  Create a multiple panel plot showing the pixel voltages or electrons in
%  a region selected by the user.
%
%  The data returns the region of interest with electrons or volts.  In
%  each channel the non-sampled measurements are NaNs.  To get these out,
%  you can use l = ~isnan(data(:,1)), for example.
%
% Called by plotSensor.  Don't call directly yet.
%
% (c) Imageval Consulting, LLC, 2012

%% Parameters
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('unitType'), unitType = 'electrons'; end

if ieNotDefined('roiLocs')
    % Select the data from the current sensor window
    handles = ieSessionGet('sensor image handle');
    ieInWindowMessage('Select image region of interest.',handles,[]);
    roiLocs = vcROISelect(sensor);
    ieInWindowMessage('',handles,[]);
end
sensor = sensorSet(sensor,'roi',roiLocs);

figNum = vcNewGraphWin([],'tall');

%% Get the data 
switch lower(unitType)
    case {'v','volts'}
        data   = sensorGet(sensor,'roivolts',roiLocs);
    case {'e','electrons'}
        data   = sensorGet(sensor,'roielectrons',roiLocs);
    otherwise
        error('Unknown unit type.');
end

%% Call proper plotting routine
nSensors = sensorGet(sensor,'nsensors');

if nSensors == 1
    plotMonochromeSensorHist(data,unitType)
else
    colorOrder = sensorGet(sensor,'filterColorLetters');
    plotColorSensorHist(data,nSensors,unitType,colorOrder);
end

uData.data = data;
uData.roiLocs = roiLocs;

return;

end
%%
function plotColorSensorHist(data,nSensors,unitType,colorOrder)
% Histogram of volts or electrons
%
% Perhaps we should plot the saturation level on the graph?
%

mxData = max(data(:))*1.1;
nBins = round(max(20,size(data,1)/25));
for ii=1:nSensors
    subplot(nSensors,1,ii)
    
    l = ~isnan(data(:,ii)); tmp = data(l,ii);
    
    hdl = histogram(tmp(:),nBins);
    if strcmp(colorOrder(ii) ,'o'), colorOrder(ii) = 'k'; end
    hdl.EdgeColor= colorOrder(ii); hdl.FaceColor= colorOrder(ii);

    % We might want to show the SNR in db some day.
    %     mn = mean(tmp);
    %     sd= std(tmp);
    %     txt = sprintf('Mean: %.02e\nSD:   %.03e\nSNR (db)=%.03f',mn,sd,20*log10(mn/sd));
    %     plotTextString(txt,'ul');  % And I think that 'ul' may not be
    %     working right.
    
    set(gca,'xlim',[0 mxData*1.1]); grid on
    switch lower(unitType)
        case 'v'
            xlabel('Volts')
        case 'e'
            xlabel('Electrons')
    end
    ylabel('Count');
end

return;
end

%%
function plotMonochromeSensorHist(data,unitType)
% Only one sensor, show the histogram as gray
% 
hdl = histogram(data(:,1));
hdl.FaceColor = [.5 .5 .5]; hdl.EdgeColor = [.5 .5 .5];
grid on

mxData = max(data(:))*1.1; set(gca,'xlim',[0 mxData*1.1]);

switch lower(unitType)
    case 'v'
        xlabel('Volts')
    case 'e'
        xlabel('Electrons')
end
ylabel('Count');

return;
end


