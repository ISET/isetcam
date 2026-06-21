function testResults = ieTutorialsTest(scriptName)
% ieTutorialsTest - Runs all s_* and t_* scripts in the ISETCam tutorials directory safely
%
% Usage:
%   testResults = ieTutorialsTest;
%   testResults = ieTutorialsTest(scriptName);
%
% It uses an in-process runner modeled on ieValidate while limiting
% execution to t_* and s_* files and avoiding any UnitTestToolbox dependency.

if nargin < 1, scriptName = ''; end

% Define the target directory relative to isetcam root
targetDir = fullfile(isetRootPath, 'tutorials');
repoRoot = isetRootPath;

localEnsureRepoPath(repoRoot, 'ieSessionGet');

allFiles = localRunnableFiles(targetDir);
allFiles = ieSelectTutorialExampleFiles(allFiles, targetDir, scriptName);
if isempty(allFiles)
    if isempty(scriptName)
        fprintf('No s_* or t_* scripts found in %s.\n', targetDir);
    else
        error('No tutorial matched "%s" in %s.', scriptName, targetDir);
    end
    testResults = struct('file', {}, 'status', {}, 'error', {});
    return;
end

logInfo = ieInitTutorialExampleRunLog(repoRoot, 'ieTutorialsTest', targetDir, allFiles, scriptName);

wbarFlag = ieSessionGet('wait bar');
initClear = ieSessionGet('init clear');
existingFigures = findall(groot, 'Type', 'figure');
cleanupObj = onCleanup(@() localRestoreSessionState(wbarFlag, initClear, existingFigures)); %#ok<NASGU>

fprintf('\n=========================================\n');
fprintf('Running %d scripts in %s\n', numel(allFiles), targetDir);
fprintf('Run log: %s\n', logInfo.runDir);
fprintf('=========================================\n');

ieSessionSet('wait bar', 0);
ieSessionSet('init clear', true);

testResults = localRunAllFiles(allFiles, targetDir, 'ieTutorialsTest', existingFigures, logInfo);
localPrintSummary('ieTutorialsTest', testResults);
localLogSummary(logInfo, testResults);

end

function localEnsureRepoPath(repoRoot, requiredSymbol)
%% Add the repo tree when a required symbol is not yet on the MATLAB path.

if isempty(which(requiredSymbol))
    addpath(genpath(repoRoot));
end

end

function localRestoreSessionState(wbarFlag, initClear, existingFigures)
%% Restore global session preferences changed for the run.

ieSessionSet('wait bar', wbarFlag);
ieSessionSet('init clear', initClear);
localCloseTestFigures(existingFigures);

end

function files = localRunnableFiles(targetDir)
%% Return the t_* and s_* scripts under the target directory.

files = [dir(fullfile(targetDir, '**', 't_*.m')); ...
    dir(fullfile(targetDir, '**', 's_*.m')); ...
    dir(fullfile(targetDir, '**', 't_*.mlx')); ...
    dir(fullfile(targetDir, '**', 's_*.mlx'))];

end

function skipPatterns = localSkipPatterns(runnerName)
%% Patterns for scripts or paths that should be skipped.

skipPatterns = { ...
    'Contents', ...
    'data', ...
    'deprecated', ...
    'development', ...
    'Development', ...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll', ...
    'xNotOnPath', ...
    'library', ...
    ['hyperspectral' filesep 'support'], ...
    runnerName ...
    };

end

function skipNames = localConditionalSkipNames()
%% Preference-sensitive GUI scripts to skip in restricted environments.

skipNames = {'t_guiISETPref'};

end

function testResults = localRunAllFiles(allFiles, targetDir, runnerName, existingFigures, logInfo)
%% Run all collected files and record pass/fail/skip status.

testResults = struct('file', {}, 'status', {}, 'error', {});
skipPatterns = localSkipPatterns(runnerName);
runState = localInitialRunState(allFiles);

for fileIndex = 1:numel(allFiles)
    filePath = fullfile(allFiles(fileIndex).folder, allFiles(fileIndex).name);
    [~, name, ~] = fileparts(filePath);
    fprintf('Run [%d/%d]: %s... ', fileIndex, numel(allFiles), name);
    runState.currentFile = filePath;
    runState.currentIndex = fileIndex;
    ieUpdateTutorialExampleRunLog(logInfo, 'ScriptStarted', runState, localEventDetail(fileIndex, numel(allFiles), filePath, ''));

    if localShouldSkip(filePath, skipPatterns) || ...
            localShouldSkipRestrictedBatch(filePath) || ...
            localFileHasSkipTag(filePath)
        fprintf('SKIPPED\n');
        testResults(end+1) = localMakeResult(filePath, 'Skipped', ''); %#ok<AGROW>
        runState.completedResults = testResults;
        ieUpdateTutorialExampleRunLog(logInfo, 'ScriptSkipped', runState, localEventDetail(fileIndex, numel(allFiles), filePath, ''));
        continue;
    end

    [passed, errMsg] = localRunOneFile(filePath, targetDir, existingFigures);
    if passed
        fprintf('OK\n');
        testResults(end+1) = localMakeResult(filePath, 'Passed', ''); %#ok<AGROW>
        runState.completedResults = testResults;
        ieUpdateTutorialExampleRunLog(logInfo, 'ScriptPassed', runState, localEventDetail(fileIndex, numel(allFiles), filePath, ''));
    else
        fprintf('FAILED\n');
        warning('Script failed: %s', errMsg);
        testResults(end+1) = localMakeResult(filePath, 'Failed', errMsg); %#ok<AGROW>
        runState.completedResults = testResults;
        ieUpdateTutorialExampleRunLog(logInfo, 'ScriptFailed', runState, localEventDetail(fileIndex, numel(allFiles), filePath, errMsg));
    end
end

    function shouldSkip = localShouldSkip(filePath, skipPatterns)
        %% Decide whether a path should be skipped based on configured patterns.

        shouldSkip = false;
        for patternIndex = 1:numel(skipPatterns)
            if contains(filePath, skipPatterns{patternIndex})
                shouldSkip = true;
                return;
            end
        end

    end

end

function runState = localInitialRunState(allFiles)
%% Build the mutable run state persisted by the progress logger.

plannedFiles = cell(numel(allFiles), 1);
for fileIndex = 1:numel(allFiles)
    plannedFiles{fileIndex} = fullfile(allFiles(fileIndex).folder, allFiles(fileIndex).name);
end

runState = struct();
runState.startedAt = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
runState.lastEventAt = runState.startedAt;
runState.currentFile = '';
runState.currentIndex = 0;
runState.totalFiles = numel(allFiles);
runState.plannedFiles = {plannedFiles};
runState.completedResults = struct('file', {}, 'status', {}, 'error', {});

end

function detail = localEventDetail(fileIndex, totalFiles, filePath, errMsg)
%% Format one log line detail message.

detail = sprintf('[%d/%d] %s', fileIndex, totalFiles, filePath);
if ~isempty(errMsg)
    detail = sprintf('%s | %s', detail, errMsg);
end

end

function localLogSummary(logInfo, testResults)
%% Persist the final run summary.

summary = sprintf('Passed=%d Failed=%d Skipped=%d', ...
    sum(strcmp({testResults.status}, 'Passed')), ...
    sum(strcmp({testResults.status}, 'Failed')), ...
    sum(strcmp({testResults.status}, 'Skipped')));
runState = struct();
runState.startedAt = '';
runState.lastEventAt = '';
runState.currentFile = '';
runState.currentIndex = numel(testResults);
runState.totalFiles = numel(testResults);
runState.plannedFiles = {{}};
runState.completedResults = testResults;
ieUpdateTutorialExampleRunLog(logInfo, 'RunCompleted', runState, summary);

end

function shouldSkip = localShouldSkipRestrictedBatch(filePath)
%% Skip preference-sensitive GUI scripts in headless or restricted batch sessions.

shouldSkip = false;
if ~(localIsHeadlessSession() || localCannotLoadPrefs())
    return;
end

[~, fileName, ~] = fileparts(filePath);
shouldSkip = any(strcmp(fileName, localConditionalSkipNames()));

end

function tf = localIsHeadlessSession()
%% Detect sessions without desktop support.

tf = ~usejava('desktop');

end

function tf = localCannotLoadPrefs()
%% Detect environments where MATLAB preferences cannot be read safely.

tf = false;
try
    getpref('ISET', 'waitbar', true);
catch
    tf = true;
end

end

function shouldSkip = localFileHasSkipTag(filePath)
%% Skip files that opt out via a supported source tag.

shouldSkip = false;
fid = fopen(filePath, 'r');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fileText = char(fread(fid, 'uint8=>char')');
shouldSkip = contains(fileText, '% SkipFile') || ...
    contains(fileText, '% UTTBSkip');

end

function [passed, errMsg] = localRunOneFile(filePath, targetDir, existingFigures)
%% Run a single script from its own directory inside a helper workspace.

curdir = pwd;
cleanupDir = onCleanup(@() cd(curdir)); %#ok<NASGU>
cd(fileparts(filePath));

try
    fprintf('Running %s\n', filePath);
    localExecuteScript(filePath, targetDir);
    passed = true;
    errMsg = '';
catch ME
    passed = false;
    errMsg = localCompactError(getReport(ME, 'extended', 'hyperlinks', 'off'));
end

drawnow;
localCloseTestFigures(existingFigures);
drawnow;

end

function localExecuteScript(filePath, targetDir)
%% Execute the script in a local function workspace.

if ~contains(filePath, targetDir)
    error('Script path %s is outside target directory %s.', filePath, targetDir);
end
run(filePath);

end

function localCloseTestFigures(existingFigures)
%% Close figures opened by test scripts while preserving pre-existing figures.

allFigures = findall(groot, 'Type', 'figure');
testFigures = setdiff(allFigures, existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end

end

function result = localMakeResult(filePath, status, errMsg)
%% Create one result struct entry.

result = struct('file', filePath, 'status', status, 'error', errMsg);

end

function localPrintSummary(runnerName, testResults)
%% Print a compact summary at the end of the run.

fprintf('\n--- %s Summary ---\n', runnerName);
fprintf('Total scripts run: %d\n', numel(testResults));
fprintf('Total Passed:     %d\n', sum(strcmp({testResults.status}, 'Passed')));
fprintf('Total Failed:     %d\n', sum(strcmp({testResults.status}, 'Failed')));
fprintf('Total Skipped:    %d\n', sum(strcmp({testResults.status}, 'Skipped')));

if any(strcmp({testResults.status}, 'Failed'))
    fprintf('\nFailed scripts:\n');
    for ii = 1:numel(testResults)
        if strcmp(testResults(ii).status, 'Failed')
            [~, fileName, ext] = fileparts(testResults(ii).file);
            fprintf('  %-25s : %s\n', [fileName ext], testResults(ii).error);
        end
    end
end

end

function errMsg = localCompactError(errMsg)
%% Collapse multiline MATLAB errors into a compact summary.

errMsg = strtrim(errMsg);
errMsg = regexprep(errMsg, '\s*\n\s*', ' | ');

end
