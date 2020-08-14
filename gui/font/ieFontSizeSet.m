function fSize = ieFontSizeSet(fig,fSize)
% Set the font size of all the text in the window objects
%
%  fSize = ieFontSizeSet(fig,fSize);
%
% Input
%  fig:   sceneWindow_App class of a window. Used to be a handle to the
%         figure of, say, the scene or oi window or the 
%         
%  fSize: The font size you want for this window
%        If fSize is 0, we are simply refreshing the window
%        if fSize is missing, we bring up a window and ask the user
%        Otherwise, we uset the actual fSize value
%
% Output
%  fSize: The font size that was set
%
% Description
%  The font size is set to all the text in the window.  The first textbox
%  in the window is the one that is assigned the fSize passed in here. When
%  the default size for the text is a little bigger or smaller in the
%  different boxes, the relative amount is preserved.
%
% Example:
%  s = sceneCreate; ieAddObject(s); sceneWindow;
%  fig = ieSessionGet('scene window');
%  ieFontSizeSet(fig, 14);
%
% (This is part of replacing ieFontChangeSize)
%
% Copyright Imageval Consulting, LLC, 2015
%
% See also
%  setFontSize (in here), ieReadNumber

% Examples:
%{
ieFontSizeSet(app,14)
%}
%% Set up parameters

if ieNotDefined('fig'), error('Figure required.'); end

% Pull out the current font size preference
isetP = getpref('ISET');
if checkfields(isetP,'fontSize'),   prefSize = isetP.fontSize;
else, prefSize = 12;  % Default preference
end

if ieNotDefined('fSize')
    % fSize is empty or missing, so ask the user
    fSize = ieReadNumber('Enter font size (7-25): ',prefSize,' %.0f');
    if isempty(fSize), return; end
elseif fSize == 0
    % Refresh condition. Use the ISET pref 
    fSize = prefSize;
end

% Clip to permissible range
minSize = 7; maxSize = 25;
fSize = ieClip(fSize,minSize,maxSize);

if isequal(class(fig),'sceneWindow_App')
    % Perhaps we should implement as below.  Use one object as the base
    % size and everything else as an offset from that.  Not hard to write.
    % Lets us have multiple font sizes and manage them all.
    
    % Find handles to all the objects that have a font size
    h = findobj(fig.figure1,'-property','FontSize');
    for ii=1:numel(h)
        h(ii).FontSize = fSize;
    end

else
    
    %% Apply the new change in the font size to the window.
    
    % If there is no window, we just update the preference
    % Get all the children of the figure.
    t = allchild(fig);
    
    % Change the text displays
    tHandles = findall(t,'Style','Text');
    setFontSize(tHandles,fSize);
    
    % Change the popupmenu font sizes.
    tHandles = findall(t,'Style','popupmenu');
    setFontSize(tHandles,fSize);
    
    % Change the popupmenu font sizes.
    tHandles = findall(t,'Style','edit');
    setFontSize(tHandles,fSize);
    
    % Change the radiobutton font sizes.
    tHandles = findall(t,'Style','radiobutton');
    setFontSize(tHandles,fSize);
    
    % Change the pushbutton font sizes.
    tHandles = findall(t,'Style','pushbutton');
    setFontSize(tHandles,fSize);
        
end

setpref('ISET','fontSize',fSize);

end

% Set the size of the font for all of this type of handle
function setFontSize(tHandles,fSize)
        
% Current font sizes
curSize = get(tHandles,'FontSize');

if isempty(curSize)
    % No fonts to change.
    return;
elseif length(curSize) == 1
        % Single font size case
        set(tHandles,'FontSize',fSize);
else
    % Set as if first size is the base size and everything else is offset
    for ii=1:length(curSize)
        if ii==1, offset = 0;
        else,     offset = curSize{ii} - curSize{1};
        end
        thisSize = fSize + offset;
        set(tHandles,'FontSize',thisSize);
    end
end

end
