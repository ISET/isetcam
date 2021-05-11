function mlRefresh(handles, ml)
%Refresh the microLensWindow
%
%    mlRefresh(handles,[ml])
%
% The microlens passed in, or the microlens attached to the current sensor
% object, is refreshed into the microLensWindow.
%
% Copyright ImagEval Consultants, LLC, 2006.

%%
if ieNotDefined('handles'), error('Must pass in microlens window handles'); end
if ieNotDefined('ml'), ml = sensorGet(vcGetObject('ISA'), 'ml'); end

%% Update the window with the microlens structure values.
figure(handles.microLensWindow);
mlFillWindowFromML(handles, ml);

% Update the radiance on every refresh.  It is pretty quick.
ml = mlRadiance(ml);

%%  Make the pixel irradiance image in the main window axis
newWindow = false;
mlIrradianceImage(ml, newWindow);

%% Fill Text box on upper right of window
txt = mlDescription(ml);
set(handles.txtDescription, 'String', txt);

end
