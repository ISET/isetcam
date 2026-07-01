function cleanupObj = ieUnitTestSetup()
% IEUNITTESTSETUP Preserve ISET preferences while MATLAB unit tests run.
%
% Syntax:
%   cleanupObj = ieUnitTestSetup();
%
% Description:
%   MATLAB function-based tests pass testCase and fixture state through
%   local function workspaces. ISETCam ieInit is a script and can run
%   clearvars when the user preference init clear is enabled, which deletes
%   that unit-test state. Unit-test runners should disable init clear for
%   the duration of the runner and restore the user preference afterward.
%
% See also
%   ieInit, ieSessionGet, ieSessionSet, matlab.unittest.TestRunner

waitBarFlag = ieSessionGet('wait bar');
initClearFlag = ieSessionGet('init clear');

cleanupObj = onCleanup(@() localRestorePreferences(waitBarFlag, initClearFlag));

ieSessionSet('wait bar', false);
ieSessionSet('init clear', false);

end

function localRestorePreferences(waitBarFlag, initClearFlag)
%% Restore preferences changed for unit-test execution.

ieSessionSet('wait bar', waitBarFlag);
ieSessionSet('init clear', initClearFlag);

end
