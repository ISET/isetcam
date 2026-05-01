function results = wavefrontUnitTest
% WAVEFRONTUNITTEST - Run all wavefront tests in the _tests_ directory
%
% Usage:
%   results = wavefrontUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end