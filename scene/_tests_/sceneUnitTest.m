function results = sceneUnitTest
% SCENEUNITTEST - Run all scene tests in the _tests_ directory using MATLAB's built-in framework.
%
% This function initializes a test suite from the current directory
% and runs all script-based or function-based tests found (e.g., test_scene.m).
%
% Usage:
%   results = sceneUnitTest;
%
% We recommend utilizing MATLAB's built in 'assert(..)' statements
% inside your test scripts for numerical validation.
%
% See also: matlab.unittest.TestSuite
%

% Get the directory where this function resides
[testDir, ~, ~] = fileparts(mfilename('fullpath'));

% Import required unittesting classes
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

% Note: If scripts use ieInit, it may call clearvars and delete the
% unittest runner's state in the main workspace. To avoid this, consider
% converting test scripts to function-based tests (e.g. by adding a 
% 'function test_myFunction(testCase)' header) or setting
% ieSessionSet('init clear', false) prior to testing.

% Create the test suite from files in this folder matching the default
% MATLAB test naming conventions (starting with 'test_')
suite = TestSuite.fromFolder(testDir);

% Create a runner with standard text output
runner = TestRunner.withTextOutput;

% Execute the test suite
results = runner.run(suite);

end
