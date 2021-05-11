function ieString = ieReadString(prompt, defString)
% Query the user for a string.
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

ieString = [];

def = {defString};
dlgTitle = sprintf('IE Read String');
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def);
if ~isempty(answer), ieString = answer{1}; end

return;