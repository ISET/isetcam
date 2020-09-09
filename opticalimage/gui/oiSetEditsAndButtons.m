function oiSetEditsAndButtons(app)
% Refresh the buttons and edit fields in the optical image window
%
% Synopsis
%   oiSetEditsAndButtons(app)
%
% Description
%  Refresh the current optical image window. If there is no optical image,
%  then a default oi is created.
%
%  Perhaps we should have a flag to leave the inline message in place?
%
% Copyright ImagEval Consultants, LLC, 2003.
% 
% See also
%

%%
[oi, val] = ieGetObject('OPTICALIMAGE');
if isempty(oi)
    oi = oiCreate;
    ieAddObject(oi);
    val = 1;
end

%% Clear the inline message
optics = oiGet(oi,'optics');
ieInWindowMessage('',app,[]);

% Which optics model
opticsModel = opticsGet(optics,'model');

% Get a numbered list of names
oiNames = vcGetObjectNames('OPTICALIMAGE',true);

% Prepend the oi names to 'New'
Items = cellMerge({'New OI'}, oiNames);

app.pulldownSelectOI.Items = Items;
app.pulldownSelectOI.Value = Items{1 + val};
% Used to be SelectOptImg

%% Buttons
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
        switchControlVisibility(app,'on');
        
    case 'shiftinvariant'
        % The SI model may have a wvf attached, or not.
        app.popOpticsModel.Value = app.popOpticsModel.Items{2};
        switchControlVisibility(app,'off');
        
    case 'raytrace'
        app.popOpticsModel.Value = app.popOpticsModel.Items{3};
        switchControlVisibility(app,'off');
        
    case 'iset3d'
        set(handles.popOpticsModel,'Value',4);
        switchControlVisibility(app,'off');
        
    case 'skip'
        app.popOpticsModel.Value = app.popOpticsModel.Items{4};
        switchControlVisibility(app,'off');
        
    otherwise
        error('Unknown optics model')
end

%% Based on the anti-alias filter pulldown selection
dMethod = oiGet(oi,'diffuser method');

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
        app.popDiffuser.Value =  app.popDiffuser.Items{2};
        app.editDiffuserBlur.Visible = 'on';
        app.txtBlurSD.Text = 'FWHM (um)';
        app.txtBlurSD.Visible = 'on';
        app.txtBlurSD.Tooltip = 'Full-width half-max Gaussian spread';
        
        val = oiGet(oi,'diffuserBlur','um');
        if isempty(val)
            val = ieReadNumber('Enter blur sd (FWHM, um)',2,' %.2f');
            oi = oiSet(oi,'diffuserBlur',val*10^-6);
            vcReplaceObject(oi);
        end
        app.editDiffuserBlur.Value = num2str(val);
        
    case 'birefringent'
        app.popDiffuser.Value =  app.popDiffuser.Items{3};
        % set(handles.popDiffuser,'Position',[0.756 0.109 0.11 0.043])
        % set(handles.txtDiffuser,'Position',[0.756 .165 0.082 0.029])
        
        % For now off, but if we decide to allow the value to change, then
        % we can use the buttons like this.
        app.editDiffuserBlur.Visible = 'on';
        app.txtBlurSD.Visible,'on';
        app.txtBlurSD.Text = 'Displacement (um)';
        app.txtBlurSD.Tooltip ='Birefringent displacement (um)';
    otherwise
        error('Unknown diffuser method %s\n',dMethod);
end

% The relative illumination is controlled by the cos4th switch in the
% window.  We make sure they are consistent here.
switch lower(app.Cos4thSwitch.Value)
    case 'on'
        oi = oiSet(oi,'optics relative illumination','cos4th');
    case 'off'
        oi = oiSet(oi,'optics relative illumination','skip');
end

%% Information table

app.oiDisplayData(oi);

%% Display in axis

gam = str2double(app.editGamma.Value);

% Select the OI figure
figure(app.figure1);

% For NIR, SWIR and so forth we might use a different displayFlag value.
% See oiShowImage.  In the future, we will read the displayFlag from
% either a global or a setting in the oi GUI.
renderFlag = oiGet(oi,'render flag index'); 

oiShowImage(oi,renderFlag,gam,app);

% Force a font size refresh
ieFontSizeSet(app,0);

end

%------------------------------------------------------
function switchControlVisibility(app,state)
%Turn on/off the diffraction limited buttons and edit fields
%On turns on the diffraction.
%Off turns off the diffraction and puts up the custom popup menu
%

switch state
    case 'on'
        app.txtFocalLength.Visible  ='on';
        app.editFocalLength.Visible ='on';

        app.txtFnumber.Visible  = 'on';
        app.editFnumber.Visible = 'on';

        app.txtMessage.Visible='on';
        % set(handles.btnOffAxis.Visible,'on');
        % set(handles.txtDiffractionLimitedOptics.Visible,'on');
        app.editDiffuserBlur.Visible='on';
        app.txtBlurSD.Visible='on';
        
    case 'off'
        app.txtFocalLength.Visible  = 'off';
        app.editFocalLength.Visible = 'off';

        app.txtFnumber.Visible  = 'off';
        app.editFnumber.Visible = 'off';
        
        app.txtMessage.Visible = 'off';
        % set(handles.btnOffAxis.Visible,'off');
        % set(handles.txtDiffractionLimitedOptics.Visible,'off');
        
        app.editDiffuserBlur.Visible = 'off';
        app.txtBlurSD.Visible = 'off';
        
    otherwise
        error('Unknown state %s.\n',state);
        
end

end
