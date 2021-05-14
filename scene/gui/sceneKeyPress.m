function sceneKeyPress
%Determine scene window key press callbacks.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Read the current key press from the buffer.  A control key is empty on first entry. But a
% ctrl-Value gets read properly on second entry.
key = double(get(gcf,'CurrentCharacter'));

if isempty(key), return; end

handles = guihandles;
eventData = [];
hObject = handles.figure1;

switch key
    case {8 127} % Backspace and Delete
    case 3  % ctrl-C
    case 4  % ctrl-D
        sceneWindow('menuEditDelete_Callback',hObject,eventData,handles);
    case 5  % ctrl-E
    case 6  % ctrl-F
    case 7  % ctrl-G
    case 8  % ctrl-H
    case 9  % ctrl-I
    case 10  % ctrl-J
    case 11  % ctrl-K
    case 12  % ctrl-L
    case 13  % ctrl-M
    case 14 % ctrl-N
        sceneWindow('menuEditSceneName_Callback',hObject,eventData,handles);
    case 15 % ctrl-O
    case 16 % ctrl-P
    case 17 % ctrl-Q
    case 18 % ctrl-R
        sceneWindow('sceneRefresh',hObject,eventData,handles);
    case 19 % ctrl-S
    case 20 % ctrl-T
    case 21 % ctrl-U
    case 22 % ctrl-V
    case 23 % ctrl-W
    case 24 % ctrl-X
    case 25 % ctrl-Y
    case 26 % ctrl-Z
    case 97 % alt-A
        
    otherwise
        return;
end

return;
