function fSize = ieFontSizeSet(fig,fSize)
% Set the font size of all the text in the window objects
%
%  fSize = ieFontSizeSet(fig,fSize);
%
% Input
%  fig:   An app window. Used to be a handle to the
%         figure of, say, the scene or oi window or the 
%         
%  fSize: The font size you want for this app window
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
%  s = sceneCreate; sceneWindow(s);
%  app = ieSessionGet('scene window');
%  ieFontSizeSet(app, 14);
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

if ~exist('fig','var')||isempty(fig), error('Figure required.'); end

% Pull out the current font size preference
isetP = getpref('ISET');
if checkfields(isetP,'fontSize'),   prefSize = isetP.fontSize;
else, prefSize = 12;  % Default preference
end

if ~exist('fSize','var')||isempty(fSize)
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

% Perhaps we should implement as below.  Use one object as the base
% size and everything else as an offset from that.  Not hard to write.
% Lets us have multiple font sizes and manage them all.

% Find handles to all the objects that have a font size
h = findobj(fig.figure1,'-property','FontSize');
for ii=1:numel(h)
    h(ii).FontSize = fSize;
end

setpref('ISET','fontSize',fSize);

end

