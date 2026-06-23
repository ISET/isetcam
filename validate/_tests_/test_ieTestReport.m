function tests = test_ieTestReport()
tests = functiontests(localfunctions);
end

function testTutorialExampleCheckpointReport(~)
%% Checkpoint summaries report counts, interrupted state, and file lists.

runDir = tempname;
mkdir(runDir);
cleanupObj = onCleanup(@() rmdir(runDir,'s'));
checkpointFile = fullfile(runDir,'checkpoint.mat');
targetDir = fullfile(runDir,'examples');

logInfo = struct('runnerName','exampleRunner','targetDir',targetDir);
runState = struct();
runState.lastEventAt = '2026-06-21 10:00:00';
runState.currentFile = fullfile(targetDir,'active.m');
runState.currentIndex = 4;
runState.totalFiles = 5;
runState.completedResults = struct( ...
    'file',{fullfile(targetDir,'passed.m'), ...
            fullfile(targetDir,'failed.m'), ...
            fullfile(targetDir,'skipped.m')}, ...
    'status',{'Passed','Failed','Skipped'}, ...
    'error',{'','expected failure',''});
save(checkpointFile,'logInfo','runState');

reportText = evalc(['summary = ieTestReport(runDir,''List'',', ...
    '{''passed'',''failed'',''skipped''});']);

assert(summary.passed == 1);
assert(summary.failed == 1);
assert(summary.skipped == 1);
assert(summary.completed == 3);
assert(summary.planned == 5);
assert(summary.unfinished == 2);
assert(strcmp(summary.currentFile,runState.currentFile));
assert(contains(reportText,'Passed files (1):'));
assert(contains(reportText,'Failed files (1):'));
assert(contains(reportText,'Skipped files (1):'));
assert(contains(reportText,'expected failure'));
assert(contains(reportText,'Last active file: active.m'));

end

function testTutorialExampleReturnedResultsReport(~)
%% Direct runner results use the same status summary and listing path.

results = struct( ...
    'file',{'passed.m','failed.m','skipped.m'}, ...
    'status',{'Passed','Failed','Skipped'}, ...
    'error',{'','expected failure',''}); %#ok<NASGU>

reportText = evalc(['summary = ieTestReport(results,''exampleRunner'',', ...
    '''List'',''all'');']);

assert(summary.passed == 1);
assert(summary.failed == 1);
assert(summary.skipped == 1);
assert(summary.completed == 3);
assert(summary.planned == 3);
assert(summary.unfinished == 0);
assert(contains(reportText,'Passed files (1):'));
assert(contains(reportText,'Failed files (1):'));
assert(contains(reportText,'Skipped files (1):'));

end

function testInterruptedCanonicalCheckpointReport(~)
%% A crashed canonical run reports state, unfinished files, and active file.

runDir = tempname;
mkdir(runDir);
cleanupObj = onCleanup(@() rmdir(runDir,'s'));
checkpointFile = fullfile(runDir,'checkpoint.mat');
targetDir = fullfile(runDir,'tutorials');

run = struct();
run.schemaVersion = 1;
run.repositoryName = 'Synthetic';
run.repositoryRoot = runDir;
run.suiteKind = 'tutorials';
run.runnerName = 'syntheticTutorialsTest';
run.targetDir = targetDir;
run.selector = '';
run.state = 'Running';
run.startedAt = '2026-06-21 10:00:00';
run.lastEventAt = '2026-06-21 10:00:05';
run.finishedAt = '';
run.plannedFiles = {fullfile(targetDir,'passed.m'); ...
    fullfile(targetDir,'active.m'); fullfile(targetDir,'remaining.m')};
run.currentIndex = 2;
run.currentFile = fullfile(targetDir,'active.m');
run.results = struct('file',fullfile(targetDir,'passed.m'), ...
    'status','Passed','error','','startedAt',run.startedAt, ...
    'finishedAt','2026-06-21 10:00:02','durationSeconds',2);
run.runDir = runDir;
run.checkpointFile = checkpointFile;
run.progressFile = fullfile(runDir,'progress.log');
save(checkpointFile,'run');

reportText = evalc('summary = ieTestReport(checkpointFile);');
assert(strcmp(summary.state,'Running'));
assert(summary.passed == 1);
assert(summary.unfinished == 2);
assert(strcmp(summary.currentFile,run.currentFile));
assert(contains(reportText,'Run State:        Running'));
assert(contains(reportText,'Last active file: active.m'));

end
