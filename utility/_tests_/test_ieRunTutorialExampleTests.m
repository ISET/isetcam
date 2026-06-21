function tests = test_ieRunTutorialExampleTests()
tests = functiontests(localfunctions);
end

function testCanonicalRunAndCheckpoint(~)
%% Synthetic scripts exercise pass, failure, skip, and atomic checkpointing.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
mkdir(tutorialDir);
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));

localWriteFile(fullfile(tutorialDir,'t_pass.m'),'value = 1;');
localWriteFile(fullfile(tutorialDir,'t_fail.m'), ...
    'error(''synthetic:expected'',''expected failure'');');
localWriteFile(fullfile(tutorialDir,'t_skip.m'), ...
    sprintf('%% SkipFile\nvalue = 2;'));
localWriteFile(fullfile(tutorialDir,'t_ignored.mlx'),'not a MATLAB script');

config = struct();
config.repositoryName = 'Synthetic';
config.repositoryRoot = repoRoot;
config.suiteKind = 'tutorials';
config.runnerName = 'syntheticTutorialsTest'; %#ok<STRNU>

reportText = evalc('runRecord = ieRunTutorialExampleTests(config);');

assert(runRecord.schemaVersion == 1);
assert(strcmp(runRecord.state,'Completed'));
assert(numel(runRecord.plannedFiles) == 3);
assert(numel(runRecord.results) == 3);
assert(sum(strcmp({runRecord.results.status},'Passed')) == 1);
assert(sum(strcmp({runRecord.results.status},'Failed')) == 1);
assert(sum(strcmp({runRecord.results.status},'Skipped')) == 1);
assert(all(isfield(runRecord.results, ...
    {'file','status','error','startedAt','finishedAt','durationSeconds'})));
assert(isfile(runRecord.checkpointFile));
assert(isfile(runRecord.progressFile));
assert(contains(reportText,'Total Failed:'));

checkpoint = load(runRecord.checkpointFile,'run');
assert(isequal(checkpoint.run,runRecord));
checkpointSummary = ieTestReport(runRecord.checkpointFile,'List','all');
assert(checkpointSummary.passed == 1);
assert(checkpointSummary.failed == 1);
assert(checkpointSummary.skipped == 1);
temporaryCheckpoints = dir(fullfile(runRecord.runDir,'*.mat'));
assert(isscalar(temporaryCheckpoints));

end

function testSelectorAndDuplicateDetection(~)
%% Selection is deterministic and duplicate stems fail before execution.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
mkdir(fullfile(tutorialDir,'one'));
mkdir(fullfile(tutorialDir,'two'));
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));
localWriteFile(fullfile(tutorialDir,'one','t_unique.m'),'value = 1;');

config = struct('repositoryName','Synthetic', ...
    'repositoryRoot',repoRoot,'suiteKind','tutorials', ...
    'runnerName','syntheticTutorialsTest','selector','t_unique');
runRecord = ieRunTutorialExampleTests(config);
assert(isscalar(runRecord.plannedFiles));

localWriteFile(fullfile(tutorialDir,'two','t_unique.m'),'value = 2;');
didError = false;
try
    ieRunTutorialExampleTests(config);
catch exception
    didError = strcmp(exception.identifier, ...
        'ieRunTutorialExampleTests:DuplicateStem');
end
assert(didError);

end

function localWriteFile(fileName,fileText)
%% Write one synthetic script.

fid = fopen(fileName,'w');
assert(fid >= 0);
cleanupObj = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',fileText);

end
