function ieInWindowMessage(str,app,duration)
% Place a message in a text box within an ISET window
%
% Synopsis
%   ieInWindowMessage(str,app,duration)
%
% Input:
%    str:  Message to display
%    app:  The appdesigner object with .txtMessage slot for the string
%    duration:  In seconds for the display.  Empty means leave it in place
%
% Description:
%  The message placed in the window is kept visible for duration seconds.
%  If duration is not sent, the default is to leave the message in place.
%  To clear the box, set str = [];
%
%  This routine is called slightly differently by the modern appdesigner
%  methods and the older guide methods.  Retained the older methods for
%  backwards compatibility (with ISETBio, mainly).
%
% Copyright ImagEval Consultants, LLC, 2005.


%% Parse
if (~exist('str','var')||isempty(str)),str = ''; end
if (~exist('app','var')||isempty(app)),disp(str); return; end
if (~exist('duration','var')||isempty(duration)),duration = []; end

%% Place the string in the message area.
if isstruct(app)
    % Old style window, not appdesigner based.  Here for backwards
    % compatibility. 
    app.txtMessage.String = str;
else
    app.txtMessage.Text = str;
end

% If duration is set, replace the string with blank after duration seconds.
if ~isempty(duration)
    pause(duration);
    if isstruct(app), app.txtMessage.String = '';
    else,             app.txtMessage.Text = '';
    end
end

end
