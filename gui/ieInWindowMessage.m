function ieInWindowMessage(str,handles,duration)            
%Place a message in a text box within an ISET window
%
%   ieInWindowMessage(str,handles,duration)
%
% The message placed in the window is kept visible for duration seconds.
% If duration is not sent, the default is to leave the message in place.
% To clear the box, set str = []; 
%
% Examples:
%  handles = ieSessionGet('opticalimagehandle');
%  ieInWindowMessage('Hello World',handles,[]);
%  ieInWindowMessage('',handles);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('duration'), duration = []; end
if ieNotDefined('str'), str = []; end
if ieNotDefined('handles'), disp(str); return; end

% Place the string in the message area.
set(handles.txtMessage,'String',str);

% If duration is set, replace the string with blank after duration seconds.
if ~isempty(duration)
    pause(duration);
    set(handles.txtMessage,'String','');
end

return;
