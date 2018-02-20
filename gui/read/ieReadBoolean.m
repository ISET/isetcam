function b = ieReadBoolean(question)
%Get a yes or no answer.  If only the world were this simple.
%  
%   b = ieReadBoolean(question)
%
%Example:
%  
%  b = ieReadBoolean('Will you marry me?')
%

if ieNotDefined('question'), question = 'Yes or No?'; end
b = [];

ButtonName=questdlg(question, ...
    'Options', ...
    'Yes','No','Cancel','Yes');
if isempty(ButtonName), return; end;

switch ButtonName,
    case 'Yes',
        b=1;
    case 'No',
        b=0;
    case 'Cancel',
        b = [];
        return;
end

return;