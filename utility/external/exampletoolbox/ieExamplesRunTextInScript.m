function ExecuteTextInScript(theScript)
% Open file, read it, execute the text via eval
%
% Syntax:
%     ExecuteTextInScript(theScript)
%
% Description
%    This is mostly to test that if we have a string
%    of Matlab code, we can execute it using eval.
%
% Inputs:
%    theScript - String.  Name of the script to execute (with the .m at the
%                end).
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None
%
% Examples are provided in the code.
%
% See also:
%     ExecuteExamplesInScript
%

% History
%   01/16/18 dhb Wasting time on a train.

% Examples:
%{
    ExecuteTextInScript('SimpleScript.m');
%}
%{
    % Another example.  This is here to help
    % test function ExecuteExamplesInScript.
    fprintf('Executing example ');

    % More comment
    fprintf('number two!\n');
%}

%{
    This is a real block comment, and should not be executed as an example.
    You can tell because it is not contiguous after the real examples above.
%}

% Open file
theFileH = fopen(theScript,'r');
theText = {char(fread(theFileH,'uint8=>char')')};
fclose(theFileH);

% Evaluate the text
eval(theText{1});


%{
    And here is another real real block comment, that also should not be executed as an example.
    You can tell because it is not contiguous after the real examples above.
%}
