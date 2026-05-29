function results = cameraUnitTest
% CAMERAUNITTEST - Run all camera tests in the _tests_ directory
%
% Usage:
%   results = cameraUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end

function localCloseTestFigures(existingFigures)
%% Close figures opened by tests while preserving pre-existing figures.

allFigures = findall(groot,'Type','figure');
testFigures = setdiff(allFigures,existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end

end
