function results = sensorUnitTest
% SENSORUNITTEST - Run all sensor tests in the _tests_ directory
%
% Usage:
%   results = sensorUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end