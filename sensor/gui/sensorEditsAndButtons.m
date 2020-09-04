function sensorEditsAndButtons(app)
%Update the sensor image window interface
%
%   sensorEditsAndButtons(app,[sensor])
%
% Update the sensor image window contents with data using data in the
% currently selected sensor (image sensor array) or another one that is passed
% in. Called regularly by sensorImageWindow.
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Set up window

% Get an existing sensor or make one up.  Not sure we should make one up.
sensor = ieGetObject('sensor');
if isempty(sensor)
    sensor = sensorCreate;
    ieAddObject(sensor);
end

ieInWindowMessage('',app,[]);

%% Sensor (sensor) properties
app.editISARows.Value = num2str(sensorGet(sensor,'rows'));
app.editISAcols.Value = num2str(sensorGet(sensor,'cols'));

% Sets the units. This should become a function
t = sensorGet(sensor,'geometric Mean Exposure Time');  % In seconds
u = log10(t);
if u >= 0
    str = sprintf('%.2f',sensorGet(sensor,'geometricMeanExposureTime')); 
    app.txtExposureUnits.Text = '(sec)';
elseif u >= -3
    str = sprintf('%.2f',sensorGet(sensor,'geometricMeanExposureTime')*10^3); 
    app.txtExposureUnits.Text = '(ms)';
else 
    str = sprintf('%.2f',sensorGet(sensor,'geometricMeanExposureTime')*10^6); 
    app.txtExposureUnits.Text = '(us)';
end
app.editExpTime.Value = str;

% Set the slider in the case of bracketed exposures.
nExposures = sensorGet(sensor,'nExposures');
if nExposures > 1
    app.sliderSelectBracketedExposure.Limits = [1-eps,nExposures];
    app.sliderSelectBracketedExposure.Value = sensorGet(sensor,'Exposure Plane');
    
    % ss = 1/(nExposures-1);  % Was slider steps
    app.sliderSelectBracketedExposure.MajorTicks = [1:nExposures];
    app.editNExposures.Value = num2str(nExposures);
    
    eTimes = sensorGet(sensor,'exposure time');
    app.editExpFactor.Value = num2str(eTimes(2)/eTimes(1));
end

str = sprintf('%3.1f',sensorGet(sensor,'gain'));    
app.editGainFPN.Value = str;

% The offset is stored in volts.  It is displayed in millivolts.
str = sprintf('%3.1f',sensorGet(sensor,'offset')*1000);  
app.editOffsetFPN.Value= str;

%% Pixel properties
thisPixel = sensorGet(sensor,'pixel');

%  Dark Voltage displayed in millivolts
str = sprintf('%2.1f',pixelGet(thisPixel,'darkvolt')*10^3);   %
app.editDarkCurrent.Value = str;

str = sprintf('%.01f',pixelGet(thisPixel,'conversiongain')*(10^6)); 
app.editConvGain.Value = str;
str = sprintf('%4.1f',pixelGet(thisPixel,'readnoisemillivolts'));   % Read noise displayed in mV
app.editReadNoise.Value = str;
str = sprintf('%2.2f',pixelGet(thisPixel,'voltage swing')); 
app.editVoltageSwing.Value = str;

%% Header strings
app.sensorDisplayData(sensor);
app.pixelDisplayData(sensorGet(sensor,'pixel'));

% Auto exposure switch
if sensorGet(sensor,'autoexposure'), app.AutoESwitch.Value = 'On';
else,                                app.AutoESwitch.Value = 'Off';
end

%% mp, Nov., 2009
% Exposure mode settings. Placing these lines here is somewhat redundant.
% We want to do these things only when we draw the sensor window for the
% first time. Any changes made to exposure mode later (from the drop down
% menu) will be accounted for by the drop down menu's callback
% (popupExpMode_Callback)

exposureMethod = sensorGet(sensor,'exposureMethod');
switch exposureMethod(1:3)
    case 'sin'  % singleExposure
        app.popupExpMode.Value = app.popupExpMode.Items{1};
        app.AutoESwitch.Visible = true;
        app.editExpTime.Visible = true;
        app.editNExposures.Visible = false;
        app.editExpFactor.Visible = false;
        app.sliderSelectBracketedExposure.Visible = false;
        app.txtBracketExposure.Visible = false;
        app.btnShowCFAExpDurations.Visible = false;

    case 'bra'  % bracketedExposure
        app.popupExpMode.Value = app.popupExpMode.Items{2};
        app.AutoESwitch.Visible = 'off';
        app.editExpTime.Visible = 'on';
        app.editNExposures.Visible = 'on';
        app.editExpFactor.Visible = 'on';
        app.sliderSelectBracketedExposure.Visible = 'on';
        app.txtBracketExposure.Visible = 'on';
        app.btnShowCFAExpDurations.Visible = 'off';

    case 'cfa'  % cfaExposure
        app.popupExpMode.Value = app.popupExpMode.Items{3};
        app.AutoESwitch.Visible = true;
        app.editExpTime.Visible = 'off';
        app.editNExposures.Visible = 'off';
        app.editExpFactor.Visible = 'off';
        app.sliderSelectBracketedExposure.Visible = 'off';
        app.txtBracketExposure.Visible = 'off';
        app.btnShowCFAExpDurations.Visible = 'on';

    otherwise
        error('Unknown exposure method %s\n',exposureMethod);
end

%% Select popup contents

nameList = vcGetObjectNames('sensor');
selectList = {'New'};
for ii=1:length(nameList)
    selectList{ii+1} = sprintf('%d-%s',ii,nameList{ii}); 
end
app.popupSelect.Items = selectList;
app.popupSelect.Value = app.popupSelect.Items{vcGetSelectedObject('sensor')+1};

%% Start of eliminating code below.  Just show the CFA
sensorShowCFA(sensor,false,app);

% Make the pop up selection match the sensor type
switch ieParamFormat(sensorGet(sensor,'cfa name'))
    case 'bayerrgb'
        app.popISA.Value = app.popISA.Items{1};
    case 'bayercmy'
        app.popISA.Value = app.popISA.Items{2};
    case 'rgbw'
        app.popISA.Value = app.popISA.Items{3};
    case 'monochrome'
        app.popISA.Value = app.popISA.Items{4};
    otherwise
        % Other
        app.popISA.Value = app.popISA.Items{5};
end

% Display the quantization method
switch lower(sensorGet(sensor,'quantization method'))
    case 'analog'
        app.popQuantization.Value = app.popQuantization.Items{1};
    case 'linear'
        switch sensorGet(sensor,'nbits')
            case 4
                app.popQuantization.Value = app.popQuantization.Items{2};
            case 8
                app.popQuantization.Value = app.popQuantization.Items{3};
            case 10
                app.popQuantization.Value = app.popQuantization.Items{4};
            case 12
                app.popQuantization.Value = app.popQuantization.Items{5};
            otherwise
                warning('Unknown quantization'); %#ok<WNTAG>
                app.popQuantization.Value =  app.popQuantization.Items{1};
        end
    otherwise
        app.popQuantization.Value = app.popQuantization.Items{1};
end

%% Display the image.
gam = str2double(app.GammaEditField.Value);
switch lower(app.MaxbrightSwitch.Value)
    case 'on'
        scaleMax = 1;
    case 'off'
        scaleMax = 0;
end

% Show the image
sensorShowImage(sensor,gam,scaleMax,app);

%% Refresh the font size
ieFontSizeSet(app,0);

end


