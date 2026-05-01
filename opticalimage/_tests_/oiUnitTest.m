function results = oiUnitTest
% OIUNITTEST - Run all optical image tests in the _tests_ directory
%
% Usage:
%   results = oiUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end