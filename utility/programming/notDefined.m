function ndef = notDefined(varString)
% Test whether a variable (usually a function argument) is defined
%
%    ndef = notDefined( varString )
%
% This routine is used to determine if a variable is defined in the calling
% function's workspace.  A variable is defined if (a) it exists and (b) it
% is not empty. This routine is used throughout the ISET code to test
% whether arguments have been passed to the routine or a default should be
% assigned.
%
% notDefined: 1 (true)  if the variable is not defined in parent workspace
%             0 (false) if the variable is defined in parent workspace
%
%  Defined means the variable exists and is not empty in the function that
%  called this function.
%
%  This routine replaced many calls of the form
%    if ~exist('varname','var') || isempty(xxx), ... end
%
%    with
%
%    if notDefined('varname'), ... end
%
% bw summer 05 -- imported into mrVista 2.0
% ras 10/05    -- changed variable names to avoid a recursion error.
% ras 01/06    -- imported back into mrVista 1.0
% Nikhil 01/10 -- support for checking structure variables added

[rootVarString, fieldString] = strtok(varString, '.');
str = sprintf('''%s''',rootVarString);
cmd1 = ['~exist(' str ',''var'') == 1'];
cmd2 = ['isempty(',rootVarString ') == 1'];

% create cmd3 if this is a structure
if ~isempty(fieldString)
    fieldString = fieldString(2:end);
    fieldString = strrep(fieldString, '.', ''',''');
    cmd3 = ['~checkfields(', rootVarString, ',''', fieldString ''')'];
end
cmd = [cmd1, ' || ',cmd2];

% If either of these conditions holds, then not defined is true
ndef = evalin('caller', cmd); % Check if variables exist in caller space
if ~ndef && ~isempty(fieldString)
    ndef = evalin('caller', cmd3); % Check if field exists in structure
end

end