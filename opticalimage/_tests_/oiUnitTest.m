function results = oiUnitTest(mode)
% OIUNITTEST - Run optical image tests in the _tests_ directory.
%
% Usage:
%   results = oiUnitTest;
%   results = oiUnitTest('full');
%

if ieNotDefined('mode'), mode = 'core'; end
mode = ieParamFormat(mode);

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));

suite = TestSuite.fromFolder(testDir);

switch mode
    case {'core','fast','quantitative'}
        smokeTests = {'test_oiPlot/','test_oiSmoke/'};
        names = {suite.Name};
        keep = true(size(suite));
        for ii = 1:numel(smokeTests)
            keep = keep & ~strncmp(names,smokeTests{ii},length(smokeTests{ii}));
        end
        suite = suite(keep);
    case {'full','all'}
        % Keep the full suite, including plot and smoke tests.
    otherwise
        error('Unknown oiUnitTest mode %s. Use ''core'' or ''full''.',mode);
end

runner = TestRunner.withTextOutput;
results = runner.run(suite);
ieTestReport(results,'oiUnitTest');

end

function localCloseTestFigures(existingFigures)
%% Close figures opened by tests while preserving pre-existing figures.

allFigures = findall(groot,'Type','figure');
testFigures = setdiff(allFigures,existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end

end
