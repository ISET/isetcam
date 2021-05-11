function notDefined = ieNotDefined(varString)
%Test whether a variable (usually a function argument) is defined
%
%   notDefined = ieNotDefined( varString )
%
% Determines if a variable is defined in the calling function's workspace.
% A variable is defined if (a) it exists and (b) it is not empty.
%
% This routine is used throughout the ISET code to test whether arguments
% have been passed to the routine or a default should be assigned.
%
% notDefined: 1 (true) if the variable is not defined in the calling workspace
%             0 (false) if the variable is defined in the calling workspace
%
% Defined means the variable exists and is not empty in the function that
% called this function.
%
%  This routine replaced many calls of the form
%    if ~exist('varname','var') || isempty(xxx), ... end
%
%    with
%
%    if ieNotDefined('varname'), ... end
%
% Copyright ImagEval Consultants, LLC, 2003.

if (~ischar(varString)), error('Variable name must be a string'); end

str = sprintf('''%s''', varString);
cmd1 = ['~exist(', str, ',''var'') == 1'];
cmd2 = ['isempty(', varString, ') == 1'];

% Check that the variable exists in the caller space
notDefined = evalin('caller', cmd1);
% If the variable is not defined, return
if notDefined, return;
else
    % The variable is defined.  But is it empty?
    notDefined = evalin('caller', cmd2);
    if notDefined, return;
    end
end

% If we made it to here, the variable exists and is not empty
notDefined = 0;

return;
