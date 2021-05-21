% s_WindowAppearance
%
% It is possible to change some of the GUI appearance properties from the
% command line and also from within the window.  This script explains how to
% make windows invisible, change the font size, remember the window
% position and size for your display, and to get a figure handle or gui
% data for a window.
%
% See also:  t_guiISETPref
%
% Copyright ImagEval Consultants, LLC, 2010

%%
ieInit

%% Opening and closing windows from the command line

% Let's start by running ISET
ISET

% Close the main window using a command that sets the window parameter
% to off, as in
ieMainW('visible','off')

% Or bring it back up
ieMainW('visible','on')

%% You can do the same with other windows
scene = sceneCreate; vcAddAndSelectObject(scene);

sceneWindow('visible','on')
drawnow
pause(1)

sceneWindow('visible','off')
drawnow
pause(1)

%% Setting up the window positions and font sizes

% The wide variety display formats and resolutions mean that different
% users will want to customize the windows and fonts in very different
% ways.
%
% ISET allows you to adjust the font size used in the windows using
% Pulldown menu options.  For example, to set the font size from the scene
% Window, you can use the Edit | Change font size pulldown. Enter a number
% of, say, 2 to increase the font size and, say, -2, to decrease the font
% size. This will change the font in all of the display windows. And your
% selection will be stored in a Matlab pref structure.
%
% You can see the preference settings using the command
getpref('ISET')

% There is also a simple mechanism for positioning and setting the size of
% the windows.  Arrange the scene, oi, sensor and ip window positions and
% sizes in a way that you would like.  Then issue the command

ieWindowsGet(true);

% This will get the window sizes and positions, also saving them in the
% ISET pref variable that is stored across sessions on that computer. (They
% are in the pref variable
%
wPos = getpref('ISET','wPos')

% When you open the windows in the future, their default size and position
% will be the same as the arrangement.
%
% If the windows are moved, and you simply want to return them to the
% default position, you can use

ieWindowsSet;

% If you would like to update the wPos values manually, you can set the
% different entries (these are for the Main, Scene, OI, Sensor, and IP
% windows) and then call

ieWindowsSet(wPos);

%% Saving window positions

% I am starting to make video tutorials, and it is convenient to set up the
% window positions in a small region.  I have saved a wPos variable to keep
% the positions overlapped for the videos in videoPos.  Here is how I load
% and set up for making the tutorials

wPos = load('videoPos',wPos);
ieWindowsSet(wPos);

%% Programming with window handles

% It is also possible to make adjustments to the display by interacting
% with the Matlab handle graphics.  To get the handle to the scene figure,
% you can run
sceneF = ieSessionGet('scene figure');

% The variable sceneF is the handle to the figure
get(sceneF)

% The guidata are available here
guidata(sceneF)

% Or you can get the guidata handle directly using
sceneG = ieSessionGet('scene guidata')

% There are parallel sets/gets for interacting with the other windows (oi
% sensor, ip)

%% END
