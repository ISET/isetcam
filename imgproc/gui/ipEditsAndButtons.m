function ipEditsAndButtons(app,ip)
% Update the Processor image window fields
%
% Synopsis
%   ipEditsAndButtons(app,ip)
%
% Brief Description
%   Update the ip window
%
% Inputs:
%   app:   ipWindow_App object
%   ip:    Currently selected ip
%
% Output
%   N/A
%
% Description
%  A variety of text boxes, display data, and compute methods are updated in
%  the vcimage window.  
%
%  The status of the window is updated to conform to the entries in the ip
%  structure.  
%
%  This routine is called in many places within ipWindow via the
%  ipRefresh function.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also:  
%   imageShowImage
%

%%

% Get an existing ip or make one up.  Not sure we should make one up.
if ieNotDefined('ip'), ip = ieGetObject('ip'); end
if isempty(ip)
    ip = ipCreate;
    ieAddObject(ip);
end

% Clear the text message in the window
ieInWindowMessage('',app);

app.ipDisplayData(ip);

%% Set the select IP popup at the top.

nameList = vcGetObjectNames('ip');
selectList = {'New'};
for ii=1:length(nameList)
    selectList{ii+1} = sprintf('%d-%s',ii,nameList{ii}); 
end

% Sometimes we get an error here, but not all the time.  I don't know why.
app.popSelect.Items = selectList;
app.popSelect.Value = app.popSelect.Items{vcGetSelectedObject('ip')+1};

%% Manage the transformations at the right of the window

% Demosiac
app.popDemosaic.Value = lower(ipGet(ip,'demosaic method'));

% Sensor transform
% app.popTransform.Items
app.popTransform.Value = lower(ipGet(ip,'Transform method'));

% Sensor conversion method
app.popColorConversionM.Value = lower(ipGet(ip,'conversion method sensor'));

% Internal color space
app.popColorSpace.Value = lower(ipGet(ip,'internalcs'));

% Illuminant correction method
app.popBalance.Value = lower(ipGet(ip,'illuminant correction method'));

%% Adjust the screen panels depending on the type of Transform.
% In the L3 case we eliminate most of the popups
if strncmpi(ip.name,'l3',2)
    % L3 method case.  Turn off most of the popups because they don't apply
    % in this case.
    setPopupVisibility('l3',app);
else
    setPopupVisibility(ipGet(ip,'transform method'),app);
end

%% Set the button that determines whether to scale the display output
% app.btnScale.Value = logical(ipGet(ip,'scaledisplay'));

%% Read how the user set the gamma value 

% Display the image
gam = str2double(app.editGamma.Value);
imageShowImage(ip,gam);

%% Refresh font size
ieFontSizeSet(app,0);

end

%-------------------------------------------------------
function setPopupVisibility(tMethod,app)
% Adjust the visibility of the popups on the right hand panel depending on
% various conditions
%
% Demosaic panel
%         set(handles.panelDemosaic,'Visible','on')
%         set(handles.popDemosaic,'Visible','on')
%         set(handles.txtDemosaic,'Visible','on');

% Text colors when option is off or on
colorOff = [.6 .6 .6];
colorOn = [ 0 0 0];

switch lower(tMethod)
    
    case {'new'}

        % Demosaic panel
        app.txtDemosaic.FontColor = colorOn;
        app.popDemosaic.Visible = 'on';
        
        % Transform panel
        app.txtTransform.FontColor = colorOn;
        app.popTransform.Visible='on';
        
        % Sensor panel
        app.txtSensor.FontColor= colorOff;
        app.txtMethod.FontColor= colorOff;
        app.txtICS.FontColor= colorOff;
        app.popColorSpace.Visible= 'off';
        app.popColorConversionM.Visible= 'off';
        
        % Illuminant panel
        app.popBalance.Visible= 'off';
        app.txtIlluminant.FontColor= colorOff;
        
    case {'current'}
        % Nice to gray stuff out rather than make it go away
        
        % Demosaic panel
        app.txtDemosaic.FontColor= colorOn;
        app.popDemosaic.Visible= 'on';
        
        % Transform panel
        app.txtTransform.FontColor= colorOn;
        app.popTransform.Visible= 'on';
        
        % Sensor panel
        % set(handles.panelSensor.Visible= 'off')
        app.txtSensor.FontColor= colorOff;
        app.txtMethod.FontColor= colorOff;
        app.txtICS.FontColor= colorOff;
        app.popColorConversionM.Visible= 'off';
        app.popColorSpace.Visible= 'off';
        
        % Illuminant panel
        app.popBalance.Visible= 'off';
        app.txtIlluminant.FontColor= colorOff;
        
    case {'adaptive'}

       % Demosaic panel
        app.textDemosaic.FontColor = colorOn;
        app.popDemosaic.Visible = 'on';
        
        % Transform panel
        app.txtTransform.FontColor = colorOn;
        app.popTransform.Visible = 'on';

        % Sensor panel
        % set(handles.panelSensor.Visible= 'off')
        app.txtSensor.FontColor= colorOn;
        app.txtMethod.FontColor= colorOn;
        app.txtICS.FontColor= colorOn;
        
        app.popColorConversionM.Visible= 'on';
        app.popColorSpace.Visible= 'on';
        app.popColorConversionM.FontColor= colorOn;
        app.popColorSpace.FontColor= colorOn;
        
        % Illuminant panel
        app.popBalance.Visible= 'on';
        app.txtIlluminant.FontColor= colorOn;
        app.popBalance.FontColor= colorOn;
        
    case 'l3'
        % In this case, most of the routines are irrelevant so the whole
        % set of panels are grayed out.
        
        % Demosaic panel
        app.txtDemosaic.FontColor= colorOff;
        app.popDemosaic.Visible= 'off';
        
        % Transform panel
        app.txtTransform.FontColor= colorOff;
        app.popTransform.Visible= 'off';
        
        % Sensor panel
        app.txtSensor.FontColor= colorOff;
        app.txtMethod.FontColor= colorOff;
        app.txtICS.FontColor= colorOff;
        app.popColorSpace.Visible= 'off';
        app.popColorConversionM.Visible= 'off';

        % Illuminant panel
        app.popBalance.Visible= 'off';
        app.txtIlluminant.FontColor= colorOff;
        

    otherwise
        error('Unknown transform method %s\n',tMethod);
end

end
