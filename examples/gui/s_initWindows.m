%% s_initWindows
%
%  Store the current ISET window size and positions.  They can be restored
%  later using ieWindowsSet;
%
% Copyright Imageval, LLC, 2013

%%  To preserve a favorite set of window positions do this:
%
%   Open the five windows (main, scene, oi, sensor, ip) Position them on
%   the screen where you like (size them, too) The argument 'true' means
%   the positions will be saved in your matlab preferences. When you next
%   run ieWindowsSet, the windows will be placed at these positions.
curPos = ieWindowsGet(true);

%   For example, move and resize one of the windows now.  Then, to bring
%   back the configuration type
ieWindowsSet;

%% End