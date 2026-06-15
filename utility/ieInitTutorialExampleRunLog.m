function logInfo = ieInitTutorialExampleRunLog(repoRoot, runnerName, targetDir, allFiles, scriptName)
% ieInitTutorialExampleRunLog - Create a timestamped log directory for script runners
%
% Syntax:
%   logInfo = ieInitTutorialExampleRunLog(repoRoot, runnerName, targetDir, allFiles, scriptName)

if nargin < 5, scriptName = ''; end

timeStamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
localDir = fullfile(repoRoot, 'local');
if ~exist(localDir, 'dir')
    mkdir(localDir);
end

runDir = fullfile(localDir, sprintf('%s_%s', timeStamp, runnerName));
mkdir(runDir);

logInfo = struct();
logInfo.runnerName = runnerName;
logInfo.repoRoot = repoRoot;
logInfo.targetDir = targetDir;
logInfo.runDir = runDir;
logInfo.progressFile = fullfile(runDir, 'progress.log');
logInfo.checkpointFile = fullfile(runDir, 'checkpoint.mat');
logInfo.selection = scriptName;

plannedFiles = cell(numel(allFiles), 1);
for fileIndex = 1:numel(allFiles)
    plannedFiles{fileIndex} = fullfile(allFiles(fileIndex).folder, allFiles(fileIndex).name);
end

fid = fopen(fullfile(runDir, 'planned-files.txt'), 'w');
if fid >= 0
    cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
    for fileIndex = 1:numel(plannedFiles)
        fprintf(fid, '%s\n', plannedFiles{fileIndex});
    end
end

runState = struct();
runState.startedAt = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
runState.lastEventAt = runState.startedAt;
runState.currentFile = '';
runState.currentIndex = 0;
runState.totalFiles = numel(plannedFiles);
runState.plannedFiles = {plannedFiles};
runState.completedResults = struct('file', {}, 'status', {}, 'error', {});
save(logInfo.checkpointFile, 'logInfo', 'runState');

ieUpdateTutorialExampleRunLog(logInfo, 'RunStarted', runState, '');

end