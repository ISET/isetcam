function results = pixelUnitTest
% PIXELUNITTEST - Run all pixel tests in the _tests_ directory
%
% Usage:
%   results = pixelUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end