function ipEditsAndButtons(handles,ip)
%Update the Processor image window fields
%
%   ipEditsAndButtons(handles,ip)
%
% A variety of text boxes, display data, and compute methods are updated in
% the vcimage window.  
%
% The status of the window is updated to conform to the entries in the ip
% structure.  
%
% This routine is called in many places within ipWindow via the
% vcimageRefresh function.
%
% See also:  imageShowImage
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ~exist('ip','var') || isempty(ip)
    ip = vcGetObject('VCIMAGE');
end
figure(handles.figure1);

%% Set the select IP popup at the top.
nameList = vcGetObjectNames('VCIMAGE');
selectList = {'New'};
for ii=1:length(nameList); selectList{ii+1} = char(nameList{ii}); end
set(handles.popSelect,...
    'String',selectList,...
    'Value',vcGetSelectedObject('VCIMAGE')+1);

%% Manage the transformations at the right of the window

% Demosaic method
contents = get(handles.popDemosaic,'String');

% Afraid to change GUI directly.  So adding pocs here.  But add pocs to the
% GUI when you get the nerve.
contents{5} = 'pocs';
contents{6} = 'analog rccc';
set(handles.popDemosaic,'String',contents);

demosaicM = ieParamFormat(ipGet(ip,'demosaic method'));
for ii=1:length(contents)
    if strcmpi(demosaicM,ieParamFormat(contents{ii}))
        set(handles.popDemosaic,'Value',ii);
        break;
    end
end

% Transform method
tMethod = ipGet(ip,'Transform method');
contents = get(handles.popTransform,'String');
for ii=1:length(contents)
    if strcmpi(tMethod,contents{ii})
        set(handles.popTransform,'Value',ii); break;
    end
end

% Sensor conversion method
colorconversionM = ipGet(ip,'conversion method sensor');
contents = get(handles.popColorConversionM,'String');
for ii=1:length(contents)
    if strcmpi(colorconversionM,contents{ii})
        set(handles.popColorConversionM,'Value',ii); break;
    end
end

% Internal color space
internalCS = ipGet(ip,'internalcs');
contents = get(handles.popColorSpace,'String');
for ii=1:length(contents)
    if strcmpi(internalCS,contents{ii})
        set(handles.popColorSpace,'Value',ii); break;
    end
end

% Illuminant correction method
colorbalanceM = ipGet(ip,'illuminant correction method');
contents = get(handles.popBalance,'String');
for ii=1:length(contents)
    if strcmpi(colorbalanceM,contents{ii})
        set(handles.popBalance,'Value',ii); break;
    end
end

%% Adjust the screen panels depending on the type of Transform.
% In the L3 case we eliminate most of the popups
if strncmpi(ip.name,'l3',2)
    % L3 method case.  Turn off most of the popups because they don't apply
    % in this case.
    setPopupVisibility('l3',handles);
else
    setPopupVisibility(ipGet(ip,'transform method'),handles);
end

%% Update red box.  
% The consistency flag should be executed more thoughtfully in both this
% window and the other windows.  Currently the button indicates
% inconsistent even when the data are consistent.
if checkfields(ip,'consistency') && ip.consistency
    % Set square to background color
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    set(handles.txtConsistency,'BackgroundColor',defaultBackground)
    ip = ipSet(ip,'consistency',0); 
    vcReplaceObject(ip);
else
    % Set square red.
    set(handles.txtConsistency,'BackgroundColor',[1,0,0]);
end

%% Write the text into the upper right portion of the window.
ipDescription(ip,handles);

%% Set the button that determines whether to scale the display output
set(handles.btnScale,'Value',logical(ipGet(ip,'scaledisplay')))

%% Read how the user set the gamma value 
gam = ipGet(ip,'render gamma');
set(handles.editGamma,'String',num2str(gam));
% Not needed because it is in ip.
% set(handles.editGamma,'Value',gam);  

% Display the image
imageShowImage(ip,gam);

%% Refresh font size
fig = ieSessionGet('ip window');
ieFontSizeSet(fig,0);

return;


%-------------------------------------------------------
function setPopupVisibility(tMethod,handles)
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
        set(handles.txtDemosaic,'ForegroundColor',colorOn);
        set(handles.popDemosaic,'Visible','on');
        
        % Transform panel
        set(handles.txtTransform,'ForegroundColor',colorOn);
        set(handles.popTransform,'Visible','on');
        
        % Sensor panel
        set(handles.txtSensor,'ForegroundColor',colorOff)
        set(handles.txtMethod,'ForegroundColor',colorOff)
        set(handles.txtICS,'ForegroundColor',colorOff);
        set(handles.popColorSpace,'Visible','off');
        set(handles.popColorConversionM,'Visible','off');
        
        % Illuminant panel
        set(handles.popBalance,'Visible','off');
        set(handles.txtIlluminant,'ForegroundColor',colorOff);
        
    case {'current'}
        % Nice to gray stuff out rather than make it go away
        
        % Demosaic panel
        set(handles.txtDemosaic,'ForegroundColor',colorOn);
        set(handles.popDemosaic,'Visible','on');
        
        % Transform panel
        set(handles.txtTransform,'ForegroundColor',colorOn);
        set(handles.popTransform,'Visible','on');
        
        % Sensor panel
        % set(handles.panelSensor,'Visible','off')
        set(handles.txtSensor,'ForegroundColor',colorOff)
        set(handles.txtMethod,'ForegroundColor',colorOff)
        set(handles.txtICS,'ForegroundColor',colorOff);
        set(handles.popColorConversionM,'Visible','off');
        set(handles.popColorSpace,'Visible','off');
        %set(handles.popColorConversionM,'ForegroundColor',colorOff);
        %set(handles.popColorSpace,'ForegroundColor',colorOff);
        
        % Illuminant panel
        set(handles.popBalance,'Visible','off');
        set(handles.txtIlluminant,'ForegroundColor',colorOff);
        % set(handles.popBalance,'ForegroundColor',colorOff);
        
    case {'adaptive'}

       % Demosaic panel
        set(handles.txtDemosaic,'ForegroundColor',colorOn);
        set(handles.popDemosaic,'Visible','on');
        
        % Transform panel
        set(handles.txtTransform,'ForegroundColor',colorOn);
        set(handles.popTransform,'Visible','on');

        % Sensor panel
        % set(handles.panelSensor,'Visible','off')
        set(handles.txtSensor,'ForegroundColor',colorOn)
        set(handles.txtMethod,'ForegroundColor',colorOn)
        set(handles.txtICS,'ForegroundColor',colorOn);
        
        % set(handles.txtSensor,'Visible','off')
        % set(handles.txtMethod,'Visible','off')
        % set(handles.txtICS,'Visible','off');
        set(handles.popColorConversionM,'Visible','on');
        set(handles.popColorSpace,'Visible','on');
        set(handles.popColorConversionM,'ForegroundColor',colorOn);
        set(handles.popColorSpace,'ForegroundColor',colorOn);
        
        % Illuminant panel
        % set(handles.panelIlluminant,'Visible','off')
        % set(handles.txtIlluminant','Visible','on');
        set(handles.popBalance,'Visible','on');
        set(handles.txtIlluminant,'ForegroundColor',colorOn);
        set(handles.popBalance,'ForegroundColor',colorOn);
        
    case 'l3'
        % In this case, most of the routines are irrelevant so the whole
        % set of panels are grayed out.
        
        % Demosaic panel
        set(handles.txtDemosaic,'ForegroundColor',colorOff);
        set(handles.popDemosaic,'Visible','off');
        
        % Transform panel
        set(handles.txtTransform,'ForegroundColor',colorOff);
        set(handles.popTransform,'Visible','off');
        
        % Sensor panel
        set(handles.txtSensor,'ForegroundColor',colorOff)
        set(handles.txtMethod,'ForegroundColor',colorOff)
        set(handles.txtICS,'ForegroundColor',colorOff);
        set(handles.popColorSpace,'Visible','off');
        set(handles.popColorConversionM,'Visible','off');

        % Illuminant panel
        set(handles.popBalance,'Visible','off');
        set(handles.txtIlluminant,'ForegroundColor',colorOff);
        

    otherwise
        error('Unknown transform method %s\n',tMethod);
end


return