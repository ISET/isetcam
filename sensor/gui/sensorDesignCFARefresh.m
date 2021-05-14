function sensorDesignCFARefresh(handles)
% Refresh the sensorDesignCFA window.
%
%   sensorDesignRefresh(handles)
%
% Used by the sensorDesignCFA window
%
% Copyright ImagEval Consultants, LLC, 2005

[val,sensor]  = vcGetSelectedObject('sensor');
filterSpectra =   sensorGet(sensor,'filterspectra');
% nFilters   = sensorGet(sensor,'nfilters');
wave       = sensorGet(sensor,'wave');
% colorOrder = sensorGet(sensor,'colororder');
% filterNames= sensorGet(sensor,'filterNames');

%  Update the screen
contents = get(handles.popBlockSize,'String');
blockSize = contents{get(handles.popBlockSize,'Value')};

switch blockSize
    case '1 (Monochrome)'
        setButtons(handles,'off');
    case '2x2'
        setButtons(handles,'on');
    otherwise
        error('Hunh?');
end

setColorNames(sensor,handles);

nFilters = sensorGet(sensor,'nfilters');
lgnd = [];

% If the color filter name is white or other, use black line.
filterNames = sensorGet(sensor,'filterNamesCellArray');
% allFilterLetters = sensorColorOrder('string');
for ii=1:nFilters
    
    % Hasn't been checked after change to color filter name management.
    
    plot(wave,filterSpectra(:,ii),[filterNames{ii},'-']); hold on;
    lgnd{ii} = sprintf('%s',filterNames{ii});
    set(gca,'ylim',[0, 1.05]);
end

hold off; grid on
xlabel('Wavelength (nm)'); ylabel('Transmissivity'); title('Current filters');
hndl = legend(lgnd,0); set(hndl,'FontSize',6); figure(handles.figure1);

return;

%----------------------------
function setButtons(handles,state)
%
switch state
    
    case 'on'
        set(handles.popName2,'Visible','on');
        set(handles.popName3,'Visible','on');
        set(handles.popName4,'Visible','on');
        
    case 'off'
        set(handles.popName2,'Visible','off');
        set(handles.popName3,'Visible','off');
        set(handles.popName4,'Visible','off');
        
    otherwise
        error('ugh.')
end

return;

%-------------------------------------------
function setColorNames(sensor,handles)
%
% Set the color names in the popName boxes.
% Each filter has a name drawn from a list in sensorColorOrder.
% This routine we use the filter name and, depending on the pattern, we
% assign the popup string.

filterNames = sensorGet(sensor,'filternames');
pattern = sensorGet(sensor,'pattern');

% Set the list of characters in the pop up name boxes.  By doing it this
% way, if we decide to add a new color label, we can just change the
% sensorColorOrder function.  I hope.
% cfaOrdering = sensorColorOrder;

set(handles.popName1,'String',filterNames);
set(handles.popName2,'String',filterNames);
set(handles.popName3,'String',filterNames);
set(handles.popName4,'String',filterNames);

% We should probably check the dimensionality here.
if length(pattern) == 1
    set(handles.popName1,'Value',pattern(1));
elseif length(pattern(:)) == 4
    set(handles.popName1,'Value',pattern(1,1));
    set(handles.popName2,'Value',pattern(2,1));
    set(handles.popName3,'Value',pattern(1,2));
    set(handles.popName4,'Value',pattern(2,2));
end

return;
