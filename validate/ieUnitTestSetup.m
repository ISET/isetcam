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
%   Temporary plotting figures default to invisible, and the caller's figure
%   visibility default is restored when cleanupObj is released.
%
% See also
%   ieInit, ieSessionGet, ieSessionSet, matlab.unittest.TestRunner

waitBarFlag = ieSessionGet('wait bar');
initClearFlag = ieSessionGet('init clear');
figureVisibility = get(groot,'DefaultFigureVisible');

cleanupObj = onCleanup(@() localRestorePreferences(waitBarFlag, initClearFlag, figureVisibility));

ieSessionSet('wait bar', false);
ieSessionSet('init clear', false);
% Data-return plotting tests should not briefly show their temporary figures.
% The dedicated app-window smoke test explicitly opens its four windows.
set(groot,'DefaultFigureVisible','off');

end

function localRestorePreferences(waitBarFlag, initClearFlag, figureVisibility)
%% Restore preferences changed for unit-test execution.

ieSessionSet('wait bar', waitBarFlag);
ieSessionSet('init clear', initClearFlag);
set(groot,'DefaultFigureVisible',figureVisibility);

end
