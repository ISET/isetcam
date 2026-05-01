function results = cameraUnitTest
% CAMERAUNITTEST - Run all camera tests in the _tests_ directory
%
% Usage:
%   results = cameraUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end