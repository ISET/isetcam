function results = displayUnitTest(mode)
% DISPLAYUNITTEST - Run display tests in the _tests_ directory.
%
% Usage:
%   results = displayUnitTest;
%   results = displayUnitTest('full');
%

if ieNotDefined('mode'), mode = 'core'; end
mode = ieParamFormat(mode);

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));
cleanupPrefs = ieUnitTestSetup(); %#ok<NASGU>

suite = TestSuite.fromFolder(testDir);

coreTests = {'test_displayAccessors/', ...
    'test_displayLUT/', ...
    'test_displayTransforms/'};

switch mode
    case {'core','fast','quantitative','full','all'}
        suite = localSelectTests(suite,coreTests);
    otherwise
        error('Unknown displayUnitTest mode %s. Use ''core'' or ''full''.',mode);
end

runner = TestRunner.withTextOutput;
results = runner.run(suite);
ieTestReport(results,'displayUnitTest');

end

function suite = localSelectTests(suite,testNames)
%% Select suite entries whose TestSuite names start with listed test files.

names = {suite.Name};
keep = false(size(suite));
for ii = 1:numel(testNames)
    keep = keep | strncmp(names,testNames{ii},length(testNames{ii}));
end
suite = suite(keep);

end

function localCloseTestFigures(existingFigures)
%% Close figures opened by tests while preserving pre-existing figures.

allFigures = findall(groot,'Type','figure');
testFigures = setdiff(allFigures,existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end

end
