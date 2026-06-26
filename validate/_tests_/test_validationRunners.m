function tests = test_validationRunners()
tests = functiontests(localfunctions);
end

function testPublicRunnerLocations(testCase)
%% Public validation entry points live together in validate.

validateDir = fileparts(fileparts(mfilename('fullpath')));
runnerNames = {'ieUnitTest','ieTutorialTest','ieExampleTest', ...
    'ieRunTutorialExampleTests','ieTestReport'};
for runnerIndex = 1:numel(runnerNames)
    runnerPath = which(runnerNames{runnerIndex});
    verifyEqual(testCase,fileparts(runnerPath),validateDir);
end

end

function testTutorialOptionNames(testCase)
%% Removed option aliases fail before a tutorial run begins.

verifyError(testCase,@() ieTutorialTest('select','t_missing'), ...
    'ieTutorialTest:InvalidOption');
verifyError(testCase,@() ieTutorialTest('t_missing'), ...
    'ieTutorialTest:InvalidInput');

end

function testExampleOptionNames(testCase)
%% Removed option aliases fail before an example run begins.

verifyError(testCase,@() ieExampleTest('select','s_missing'), ...
    'ieExampleTest:InvalidOption');
verifyError(testCase,@() ieExampleTest('s_missing'), ...
    'ieExampleTest:InvalidInput');

end
