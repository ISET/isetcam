function results = sceneUnitTest(mode)
% SCENEUNITTEST - Run scene tests in the _tests_ directory.
%
% By default, this runner executes the core quantitative regression tests.
% Pass 'full' to include the slower GUI/smoke tests.
%
% Usage:
%   results = sceneUnitTest;
%   results = sceneUnitTest('full');
%
% We recommend utilizing MATLAB's built in 'assert(..)' statements
% inside your test scripts for numerical validation.
%
% See also: matlab.unittest.TestSuite
%

if ieNotDefined('mode'), mode = 'core'; end
mode = ieParamFormat(mode);

% Get the directory where this function resides
[testDir, ~, ~] = fileparts(mfilename('fullpath'));

% Import required unittesting classes
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));

% Note: If scripts use ieInit, it may call clearvars and delete the
% unittest runner's state in the main workspace. To avoid this, consider
% converting test scripts to function-based tests (e.g. by adding a
% 'function test_myFunction(testCase)' header) or setting
% ieSessionSet('init clear', false) prior to testing.

% Create the test suite from files in this folder matching the default
% MATLAB test naming conventions (starting with 'test_')
suite = TestSuite.fromFolder(testDir);

switch mode
    case {'core','fast','quantitative'}
        smokeTests = {'test_scene/','test_scenePlot/','test_scenedemo/'};
        names = {suite.Name};
        keep = true(size(suite));
        for ii = 1:numel(smokeTests)
            keep = keep & ~strncmp(names,smokeTests{ii},length(smokeTests{ii}));
        end
        suite = suite(keep);
    case {'full','all'}
        % Keep the full suite, including GUI/smoke tests.
    otherwise
        error('Unknown sceneUnitTest mode %s. Use ''core'' or ''full''.',mode);
end

% Create a runner with standard text output
runner = TestRunner.withTextOutput;

% Execute the test suite
results = runner.run(suite);
ieTestReport(results,'sceneUnitTest');

end

function localCloseTestFigures(existingFigures)
%% Close figures opened by tests while preserving pre-existing figures.

allFigures = findall(groot,'Type','figure');
testFigures = setdiff(allFigures,existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end

end
