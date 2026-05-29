function results = sensorUnitTest(mode)
% SENSORUNITTEST - Run sensor tests in the _tests_ directory.
%
% Usage:
%   results = sensorUnitTest;
%   results = sensorUnitTest('full');
%

if ieNotDefined('mode'), mode = 'core'; end
mode = ieParamFormat(mode);

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));

suite = TestSuite.fromFolder(testDir);

coreTests = {'test_sensorAccessors/', ...
    'test_sensorExposure/', ...
    'test_sensorExposureCFA/', ...
    'test_sensorGainOffset/', ...
    'test_sensorIMX363/', ...
    'test_sensorIMX490/', ...
    'test_sensorSplitpixel/'};

fullOnlyTests = {'test_sensorAnalyzeDarkVoltage/', ...
    'test_sensorChromaticity/', ...
    'test_sensorCountingPhotons/', ...
    'test_sensorExposureBracket/', ...
    'test_sensorMonochrome/', ...
    'test_sensorNoise/', ...
    'test_sensorPlot/', ...
    'test_sensorPoisson/', ...
    'test_sensorResize/', ...
    'test_sensorSize/', ...
    'test_sensorSNR/', ...
    'test_sensorSpectralEstimation/'};

switch mode
    case {'core','fast','quantitative'}
        suite = localSelectTests(suite,coreTests);
    case {'full','all'}
        suite = localSelectTests(suite,[coreTests fullOnlyTests]);
    otherwise
        error('Unknown sensorUnitTest mode %s. Use ''core'' or ''full''.',mode);
end

runner = TestRunner.withTextOutput;
results = runner.run(suite);
ieTestReport(results,'sensorUnitTest');

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
