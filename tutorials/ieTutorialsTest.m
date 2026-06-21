function run = ieTutorialsTest(selector)
% Run ISETCam tutorials through the shared tutorial/example test engine.
%
% Syntax:
%   run = ieTutorialsTest
%   run = ieTutorialsTest(selector)

if nargin < 1, selector = ''; end

config = struct();
config.repositoryName = 'ISETCam';
config.repositoryRoot = isetRootPath;
config.suiteKind = 'tutorials';
config.runnerName = mfilename;
config.selector = selector;
config.skipPathPatterns = { ...
    [filesep 'data' filesep], ...
    ['hyperspectral' filesep 'support']};
config.conditionalSkipFcn = @localConditionalSkip;

run = ieRunTutorialExampleTests(config);

end

function reason = localConditionalSkip(filePath)
%% Skip preference-sensitive GUI tutorials in restricted sessions.

reason = '';
[~,fileName] = fileparts(filePath);
if ~strcmp(fileName,'t_guiISETPref'), return; end
if ~usejava('desktop') || localCannotLoadPrefs()
    reason = 'preference-sensitive GUI tutorial in a restricted session';
end

end

function tf = localCannotLoadPrefs
%% Detect environments where MATLAB preferences cannot be read safely.

tf = false;
try
    getpref('ISET','waitbar',true);
catch
    tf = true;
end

end
