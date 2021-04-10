function ieMainClose
% Close the all the ISET windows that have an app in the database.
%
%     ieMainClose
%
% The routine checks for various fields, closes the scene, oi, sensor, ip
% and metrics windows.  If there are multiple versions of the window, the
% additional unmanaged windows, they may not be closed.
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

if ~checkfields(vcSESSION,'GUI'); closereq; return; end

app = ieSessionGet('scene window');
if ~isempty(app), delete(app); ieSessionSet('scene window',[]); end

app = ieSessionGet('oi window');
if ~isempty(app), delete(app); ieSessionSet('oi window',[]); end

app = ieSessionGet('sensor window');
if ~isempty(app), delete(app); ieSessionSet('sensor window',[]); end

app = ieSessionGet('ip window');
if ~isempty(app), delete(app); ieSessionSet('ip window',[]); end

app = ieSessionGet('display window');
if ~isempty(app), delete(app); ieSessionSet('display window',[]); end

% disp('Metrics window NYI');
%{
    app = ieSessionGet('metrics window');
    if ~isempty(app), delete(app); ieSessionSet('metrics window',[]); end
%}

% Empty out the GUI slots.  Not sure why.
vcSESSION.GUI = [];

% I think this will close the main window if that is where the call came
% from
closereq;

% Check that the window apps have been deleted from the database.
assert(isempty(ieSessionGet('scene window')));
assert(isempty(ieSessionGet('oi window')));
assert(isempty(ieSessionGet('sensor window')));
assert(isempty(ieSessionGet('ip window')));

end
