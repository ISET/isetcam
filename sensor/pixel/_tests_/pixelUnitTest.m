function results = pixelUnitTest(mode)
% PIXELUNITTEST - Run pixel tests in the _tests_ directory.
%
% Usage:
%   results = pixelUnitTest;
%   results = pixelUnitTest('full');
%

if ieNotDefined('mode'), mode = 'core'; end
mode = ieParamFormat(mode);

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);

coreTests = {'test_pixelAccessors/', ...
    'test_pixelComputations/', ...
    'test_pixelSNR/'};

fullOnlyTests = {'test_pixelMTF/'};

switch mode
    case {'core','fast','quantitative'}
        suite = localSelectTests(suite,coreTests);
    case {'full','all'}
        suite = localSelectTests(suite,[coreTests fullOnlyTests]);
    otherwise
        error('Unknown pixelUnitTest mode %s. Use ''core'' or ''full''.',mode);
end

runner = TestRunner.withTextOutput;
results = runner.run(suite);

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
