function [valid, toolboxes] = checkToolbox(toolboxName)
% Checks whether a specific matlab toolbox has been installed
%
% Syntax:
%   [valid, toolboxes] = checkToolbox(toolboxName)
%
% Description:
%    Checks whether certain matlab toolbox has been installed
% 
%    Examples are included within the code.
%
% Inputs:
%    toolboxName - The name of the toolbox you are attempting to verify the
%                  existence of.
%
% Outputs:
%    valid        - The boolean value indicating the installation status of
%                   the desired toolbox.
%    toolboxes    - Array listing all of the toolboxes, as returned by the
%                   ver command.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Note: JNM - The function was marked incorrectly below as returning
%      all of the toolbox names. It is possible to do that if you change
%      ret above to [ret, vv], but as it stands, the function currently
%      returns a boolean indicating whether or not the specific toolbox is
%      installed on the local machine.]
%

% Examples:
%{
    checkToolbox('Statistics and Machine Learning Toolbox')
    [valid, tbxList] = checkToolbox('Parallel Computing Toolbox');
%}

% vv contains all of the toolbox names
toolboxes  = ver;
valid = any(strcmp({toolboxes.Name}, toolboxName));

end