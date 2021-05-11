function val = ieReadNumber(str, defaultValue, fmt)
%Graphical query for a number
%
%  val = ieReadNumber([str],[defaultValue = 1],[fmt])
%
% Graphical wrapper to query the user for a number.  You can also enter a
% vector, say by typing in 1:10, and the return values will be (1:10);
%
% Examples
%  val = ieReadNumber('Enter column number')
%  val = ieReadNumber('Enter column number',1/17,' %.3f')
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('str'), str = 'Enter value'; end
if ieNotDefined('defaultValue'), defaultValue = 1; end
if ieNotDefined('fmt'), fmt = '  %.2e'; end

prompt = {str};
def = {num2str(defaultValue, fmt)};
dlgTitle = sprintf('ISET read number');
lineNo = 1;
answer = inputdlg(prompt, dlgTitle, lineNo, def, 'on');

if isempty(answer), val = [];
else, val = eval(answer{1});
end

end