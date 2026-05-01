function results = imgprocUnitTest
% IMGPROCUNITTEST - Run all image processing tests in the _tests_ directory
%
% Usage:
%   results = imgprocUnitTest;
%

[testDir, ~, ~] = fileparts(mfilename('fullpath'));
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromFolder(testDir);
runner = TestRunner.withTextOutput;
results = runner.run(suite);

end