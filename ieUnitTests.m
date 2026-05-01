function results = ieUnitTests()
% IEUNITTESTS - Master runner for all ISETCam unit tests
%
% This script automatically discovers all `_tests_` directories
% within the ISETCam workspace, agglomerates them into a master
% test suite, and runs them.
%
% Usage:
%   results = ieUnitTests;
%
% Returns:
%   results - A matlab.unittest.TestResult array containing the outcome.
%

% Get the root path of the project
rootPath = isetRootPath();

% Find all directories named '_tests_' recursively
fprintf('Searching for test directories...\n');
testDirs = dir(fullfile(rootPath, '**', '_tests_'));

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TestReportPlugin;

masterSuite = [];

for ii = 1:length(testDirs)
    if testDirs(ii).isdir
        folderPath = fullfile(testDirs(ii).folder, testDirs(ii).name);
        % Create test suite from each folder and append to master
        folderSuite = TestSuite.fromFolder(folderPath);
        masterSuite = [masterSuite, folderSuite];
    end
end

if isempty(masterSuite)
    fprintf('No tests found.\n');
    results = [];
    return;
end

fprintf('Found %d test files across %d directories.\n', length(masterSuite), length(testDirs));
fprintf('Starting master test runner...\n\n');

% Create runner with standard text output
runner = TestRunner.withTextOutput;

% Run the suite
results = runner.run(masterSuite);

% Display a nice summary table at the end
fprintf('\n--- ISETCam Test Summary ---\n');
disp(table(results));

% Print final pass/fail count
numPassed = sum([results.Passed]);
numFailed = sum([results.Failed]);
numIncomplete = sum([results.Incomplete]);

fprintf('Total Passed:     %d\n', numPassed);
fprintf('Total Failed:     %d\n', numFailed);
fprintf('Total Incomplete: %d\n', numIncomplete);

end