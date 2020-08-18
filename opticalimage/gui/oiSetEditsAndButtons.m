function oiSetEditsAndButtons(app)
% Refresh the buttons and edit fields in the optical image window
%
%   oiSetEditsAndButtons(handles)
%
% Refresh the current optical image window. If there is no optical image,
% then a default oi is created.
%
% Perhaps we should have a flag to leave the inline message in place?
%
% Copyright ImagEval Consultants, LLC, 2003.

[oi, val] = ieGetObject('OPTICALIMAGE');
if isempty(oi)
    oi = oiCreate;
    val = 1;
end

% Clear the inline message
optics = oiGet(oi,'optics');
ieInWindowMessage('',app,[]);

% Which optics model
opticsModel = opticsGet(optics,'model');

% Append the oi names to 'New'
oiNames = vcGetObjectNames('OPTICALIMAGE');
Items = cellMerge({'New OI'}, oiNames);

app.SelectOptImg.Items = Items;
app.SelectOptImg.Value = Items{1 + val};

% Buttons
% Check the custom compute
switch lower(opticsModel)
    
    case {'diffractionlimited','dlmtf'}
        app.popOpticsModel.Value = app.popOpticsModel.Items{1}; 
        
        % Set the diffraction limited optics parameters
        optics = oiGet(oi,'optics');
        str = sprintf('%2.2f',opticsGet(optics,'focalLength','mm'));
        app.editFocalLength.Value = str;
        
        str = sprintf('%1.2f',opticsGet(optics,'fnumber'));
        app.editFnumber.Value = str;
        
        %{
        val = opticsGet(optics,'off axis method');
        if strcmpi(val,'skip'), app.btnOffAxis, 'Value',0);
        else, set(handles.btnOffAxis, 'Value',1);
        end
        %}
        
    case 'shiftinvariant'
        % The SI model may have a wvf attached, or not.
        set(handles.popOpticsModel,'Value',2);
        switchControlVisibility(handles,'off');
        
    case 'raytrace'
        set(handles.popOpticsModel,'Value',3);
        switchControlVisibility(handles,'off');
        
    case 'iset3d'
        set(handles.popOpticsModel,'Value',4);
        switchControlVisibility(handles,'off');
        
    case 'skip'
        set(handles.popOpticsModel,'Value',4);
        switchControlVisibility(handles,'off');
        
    otherwise
        error('Unknown optics model')
end

% Adjust the anti-alias filter
dMethod = oiGet(oi,'diffuserMethod');

switch lower(dMethod)
    case 'skip'
        app.popDiffuser.Value =  app.popDiffuser.Items{1};
        app.editDiffuserBlur.Visible = 'off';
        app.txtBlurSD.Visible = 'off';
        %{
        set(handles.popDiffuser,'Position',[0.756 0.109 0.11 0.043])
        set(handles.txtDiffuser,'Position',[0.756 .165 0.082 0.029])
        %}
    case 'blur'
        set(handles.popDiffuser,'val',2)
        set(handles.editDiffuserBlur,'visible','on');
        set(handles.txtBlurSD,'string','FWHM (um)');
        set(handles.txtBlurSD,'visible','on');
        set(handles.txtBlurSD,'TooltipString','Full width half maximum of Gaussian spread');
        
        set(handles.txtBlurSD,'Position',[0.8693 .117 0.089 0.029])
        set(handles.editDiffuserBlur,'Position',[0.82 0.115 0.038 0.033])
        set(handles.popDiffuser,'Position',[0.693 0.109 0.11 0.043])
        set(handles.txtDiffuser,'Position',[0.693 .165 0.082 0.029])
        
        val = oiGet(oi,'diffuserBlur','um');
        if isempty(val)
            val = ieReadNumber('Enter blur sd (FWHM, um)',2,' %.2f');
            oi = oiSet(oi,'diffuserBlur',val*10^-6);
            vcReplaceObject(oi);
        end
        set(handles.editDiffuserBlur,'String',num2str(val));
    case 'birefringent'
        set(handles.popDiffuser,'val',3)
        set(handles.popDiffuser,'Position',[0.756 0.109 0.11 0.043])
        set(handles.txtDiffuser,'Position',[0.756 .165 0.082 0.029])
        
        % For now off, but if we decide to allow the value to change, then
        % we can use the buttons like this.
        set(handles.editDiffuserBlur,'visible','off');
        set(handles.txtBlurSD,'visible','off');
        set(handles.txtBlurSD,'string','Disp (um)');
        set(handles.txtBlurSD,'TooltipString','Birefringent displacement in microns');
    otherwise
        error('Unknown diffuser method %s\n',dMethod);
end

%{
% If the incoming call set consistency true, then we eliminate the red
% square on the window.  Otherwise, consistency is false.  We always set
% consistency to false on the way out.  This overdoes it so that sometimes
% we show inconsistent when it is really consistent.
if oiGet(oi,'consistency')
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    set(handles.txtConsistency,'BackgroundColor',defaultBackground)    
    oi = oiSet(oi,'consistency',0);
    vcReplaceObject(oi);
else
    set(handles.txtConsistency,'BackgroundColor',[1,0,0]);
end
%}

gam = str2double(app.editGamma.Value);

% Select the OI figure
figure(app.figure1);

% For NIR, SWIR and so forth we might use a different displayFlag value.
% See oiShowImage.  In the future, we will read the displayFlag from
% either a global or a setting in the oi GUI.
displayFlag = find(contains(app.popupDisplay.Items,app.popupDisplay.Value));

oiShowImage(oi,displayFlag,gam,app);

app.txtOpticalImage.Text = oiDescription(oi);

%% Force a font size refresh
ieFontSizeSet(app,0);

end

%{
%------------------------------------------------------
function switchControlVisibility(handles,state)
%Turn on/off the diffraction limited buttons and edit fields
%On turns on the diffraction.
%Off turns off the diffraction and puts up the custom popup menu
%

switch state
    case 'on'
        set(handles.txtFocalLength,'visible','on')
        set(handles.txtFnumber,'visible','on')
        set(handles.editFocalLength,'visible','on')
        set(handles.editFnumber,'visible','on')
        set(handles.txtM,'visible','on')
        % set(handles.btnOffAxis,'visible','on');
        % set(handles.txtDiffractionLimitedOptics,'visible','on');
        set(handles.editDiffuserBlur,'visible','on');
        set(handles.txtBlurSD,'visible','on');
        
    case 'off'
        set(handles.txtFocalLength,'visible','off')
        set(handles.txtFnumber,'visible','off')
        set(handles.editFocalLength,'visible','off')
        set(handles.editFnumber,'visible','off')
        set(handles.txtM,'visible','off')
        % set(handles.btnOffAxis,'visible','off');
        % set(handles.txtDiffractionLimitedOptics,'visible','off');
        set(handles.editDiffuserBlur,'visible','off');
        set(handles.txtBlurSD,'visible','off');
        
    otherwise
        error('Unknown state.');
        
end

end
%}