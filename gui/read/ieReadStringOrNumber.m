function ieInput = ieReadStringOrNumber(prompt,defString) 
% Query the user for a string or a number.
%
%    newFilterName = ieReadString(prompt,defString)     
%
% If the user cancels,  the returned string is empty.
%
% Example:
%  newName = ieReadString('Enter filter name: ','filter')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('prompt'), prompt = 'Enter'; end
if ieNotDefined('defString'), defString = ''; end

ieInput = [];

def={defString};
dlgTitle= sprintf('IE Read String');
lineNo=1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if ~isempty(answer)
    ieInput = answer{1};
    % if number - convert
    if ~isempty(str2num(ieInput))
        ieInput = str2num(ieInput);
    end
end
  

return;