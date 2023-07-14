function ieString = ieReadString(prompt,defString)
% Query the user for a string.
%
%    newFilterName = ieReadString(prompt,defString)
%
% If the user cancels, the returned string is empty.
%
% The prompt can include TeX commands, such as superscript and Greek
% symbols.  The input dialog window is set to be resizable.  The
% window can be ignored ('normal').
%
% Input
%   prompt - String for the prompt
%   defString - Default string
%
% Output
%   ieString - Returned string, empty if user Cancels
%
% Key/val
%   NYI (maybe we should add dims or alternative options settings.
%
%  See also
%   ieReadBoolean, ieReadMatrix, ieReadSpectra, ieRead*

%% 
%{
newName = ieReadString('Enter filter name: ','filter')
ieString = ieReadString('Test me','Hello World!')
ieString = ieReadString('Test superscript^2','Math');
%}

%%
if ieNotDefined('prompt'), prompt = 'Enter'; end
if ieNotDefined('defString'), defString = ''; end

ieString = [];

def={defString};
dlgTitle= sprintf('IE Read String');
lineNo=1;
opt.Resize = 'on';
opt.Windowstyle = 'normal';
opt.Interpreter = 'tex';
answer = inputdlg(prompt,dlgTitle,lineNo,def,opt);
if ~isempty(answer), ieString = answer{1}; end

end