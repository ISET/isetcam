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
localWriteFile(fullfile(tutorialDir,'t_skip_compact.m'), ...
    sprintf('%%SkipFile\nvalue = 3;'));
localWriteFile(fullfile(tutorialDir,'t_skip_spaced.m'), ...
    sprintf('  %%  SkipFile  reason\nvalue = 4;'));
localWriteFile(fullfile(tutorialDir,'t_skip_legacy.m'), ...
    sprintf('%%  UTTBSkip\nvalue = 5;'));
localWriteFile(fullfile(tutorialDir,'t_not_skip.m'), ...
    sprintf('%% SkipFilename is not a marker\nvalue = 6;'));
localWriteFile(fullfile(tutorialDir,'t_ignored.mlx'),'not a MATLAB script');

config = struct();
config.repositoryName = 'Synthetic';
config.repositoryRoot = repoRoot;
config.suiteKind = 'tutorials';
config.runnerName = 'syntheticTutorialsTest'; %#ok<STRNU>

reportText = evalc('runRecord = ieRunTutorialExampleTests(config);');

assert(runRecord.schemaVersion == 1);
assert(strcmp(runRecord.state,'Completed'));
assert(numel(runRecord.plannedFiles) == 7);
assert(numel(runRecord.results) == 7);
assert(sum(strcmp({runRecord.results.status},'Passed')) == 2);
assert(sum(strcmp({runRecord.results.status},'Failed')) == 1);
assert(sum(strcmp({runRecord.results.status},'Skipped')) == 4);
assert(all(isfield(runRecord.results, ...
    {'file','status','error','startedAt','finishedAt','durationSeconds'})));
assert(isfile(runRecord.checkpointFile));
assert(isfile(runRecord.progressFile));
assert(contains(reportText,'Total Failed:'));

checkpoint = load(runRecord.checkpointFile,'run');
assert(isequal(checkpoint.run,runRecord));
checkpointSummary = ieTestReport(runRecord.checkpointFile,'List','all');
assert(checkpointSummary.passed == 2);
assert(checkpointSummary.failed == 1);
assert(checkpointSummary.skipped == 4);
temporaryCheckpoints = dir(fullfile(runRecord.runDir,'*.mat'));
assert(isscalar(temporaryCheckpoints));

end

function testUnderDevelopmentFilesAreNotPlanned(~)
%% Files below underDevelopment are excluded from the run plan entirely.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
developmentDir = fullfile(tutorialDir,'underDevelopment');
mkdir(developmentDir);
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));
localWriteFile(fullfile(tutorialDir,'t_visible.m'),'value = 1;');
localWriteFile(fullfile(developmentDir,'t_hidden.m'), ...
    'error(''synthetic:hidden'',''should not run'');');
localWriteFile(fullfile(developmentDir,'s_hidden.m'), ...
    'error(''synthetic:hidden'',''should not run'');');
localWriteFile(fullfile(developmentDir,'t_visible.m'), ...
    'error(''synthetic:duplicate'',''should not be considered'');');

config = struct('repositoryName','Synthetic', ...
    'repositoryRoot',repoRoot,'suiteKind','tutorials', ...
    'runnerName','syntheticTutorialsTest');
runRecord = ieRunTutorialExampleTests(config);
assert(isscalar(runRecord.plannedFiles));
assert(endsWith(runRecord.plannedFiles{1},'t_visible.m'));
assert(strcmp(runRecord.results.status,'Passed'));

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

function testStart(~)
%% start resumes a deterministic plan at the requested file.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
mkdir(tutorialDir);
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));
localWriteFile(fullfile(tutorialDir,'t_alpha.m'),'value = 1;');
localWriteFile(fullfile(tutorialDir,'t_beta.m'),'value = 2;');
localWriteFile(fullfile(tutorialDir,'t_gamma.m'),'value = 3;');

config = struct('repositoryName','Synthetic', ...
    'repositoryRoot',repoRoot,'suiteKind','tutorials', ...
    'runnerName','syntheticTutorialsTest','start','t_beta');
runRecord = ieRunTutorialExampleTests(config);
assert(numel(runRecord.plannedFiles) == 2);
assert(endsWith(runRecord.plannedFiles{1},'t_beta.m'));
assert(endsWith(runRecord.plannedFiles{2},'t_gamma.m'));
assert(strcmp(runRecord.start,'t_beta'));

config.start = 't_missing';
didError = false;
try
    ieRunTutorialExampleTests(config);
catch exception
    didError = strcmp(exception.identifier, ...
        'ieRunTutorialExampleTests:NoStartMatch');
end
assert(didError);

end

function testLegacyRNGDoesNotLeak(~)
%% Legacy random-number state from a script is cleared by the runner.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
mkdir(tutorialDir);
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));
localWriteFile(fullfile(tutorialDir,'t_legacy_rng.m'), ...
    'randn(''seed'',0);');

config = struct('repositoryName','Synthetic', ...
    'repositoryRoot',repoRoot,'suiteKind','tutorials', ...
    'runnerName','syntheticTutorialsTest');
runRecord = ieRunTutorialExampleTests(config);
assert(strcmp(runRecord.results.status,'Passed'));

rng('shuffle','twister');
rng('default');

end

function testLegacyRNGDoesNotBreakConditionalSkip(~)
%% Conditional skip hooks run after the runner restores modern RNG state.

repoRoot = tempname;
tutorialDir = fullfile(repoRoot,'tutorials');
mkdir(tutorialDir);
cleanupObj = onCleanup(@() rmdir(repoRoot,'s'));
localWriteFile(fullfile(tutorialDir,'t_pass.m'),'value = 1;');

localSetLegacyRandomState(repoRoot);
config = struct('repositoryName','Synthetic', ...
    'repositoryRoot',repoRoot,'suiteKind','tutorials', ...
    'runnerName','syntheticTutorialsTest', ...
    'conditionalSkipFcn',@localRNGSensitiveSkipReason);
runRecord = ieRunTutorialExampleTests(config);
assert(strcmp(runRecord.results.status,'Passed'));

end

function reason = localRNGSensitiveSkipReason(~)
%% Exercise a skip hook that uses modern RNG while MATLAB may be in legacy mode.

rng('shuffle','twister');
reason = '';

end

function localSetLegacyRandomState(parentDir)
%% Enter MATLAB's legacy random-number mode for runner isolation testing.

legacySetupFile = fullfile(parentDir,'legacy_rng_setup.m');
localWriteFile(legacySetupFile,'randn(''seed'',0);');
run(legacySetupFile);

end

function localWriteFile(fileName,fileText)
%% Write one synthetic script.

fid = fopen(fileName,'w');
assert(fid >= 0);
cleanupObj = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',fileText);

end
