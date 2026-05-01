function results = opticsUnitTest
% OPTICSUNITTEST - Run all optics tests in the _tests_ directory 
%
% Usage:
%   results = opticsUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end