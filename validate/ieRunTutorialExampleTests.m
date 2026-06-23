function run = ieRunTutorialExampleTests(config)
% Run tutorial or example scripts using the shared validation engine.
%
% Syntax:
%   run = ieRunTutorialExampleTests(config)
%
% Required config fields:
%   repositoryName, repositoryRoot, suiteKind, runnerName
%
% Optional config fields:
%   selector, start, skipPathPatterns, conditionalSkipFcn, setupFcn

config = localValidateConfig(config);
if ~isempty(config.setupFcn), config.setupFcn(); end

targetDir = fullfile(config.repositoryRoot,config.suiteKind);
if ~isfolder(targetDir)
    error('ieRunTutorialExampleTests:MissingTarget', ...
        'Suite directory does not exist: %s',targetDir);
end

allFiles = localDiscoverFiles(targetDir);
localRejectDuplicateStems(allFiles,targetDir);
selectedFiles = localSelectFiles(allFiles,targetDir,config.selector);
if isempty(selectedFiles) && ~isempty(config.selector)
    error('ieRunTutorialExampleTests:NoMatch', ...
        'No %s file matched "%s" in %s.', ...
        config.suiteKind,config.selector,targetDir);
end
selectedFiles = localStartFile(selectedFiles,targetDir,config.start);

run = localCreateRun(config,targetDir,selectedFiles);
localWritePlannedFiles(run);
run = localRecordEvent(run,'RunStarted','');

waitBarFlag = ieSessionGet('wait bar');
initClearFlag = ieSessionGet('init clear');
cleanupObj = onCleanup(@() localRestorePreferences(waitBarFlag,initClearFlag));
ieSessionSet('wait bar',false);
ieSessionSet('init clear',true);

fprintf('\n=========================================\n');
fprintf('Running %d scripts in %s\n',numel(selectedFiles),targetDir);
fprintf('Run log: %s\n',run.runDir);
fprintf('=========================================\n');

for fileIndex = 1:numel(selectedFiles)
    filePath = selectedFiles{fileIndex};
    [~,fileName,fileExt] = fileparts(filePath);
    run.currentIndex = fileIndex;
    run.currentFile = filePath;
    resultStartedAt = localTimestamp();
    run = localRecordEvent(run,'ScriptStarted', ...
        localEventDetail(fileIndex,numel(selectedFiles),filePath,''));
    fprintf('Run [%d/%d]: %s%s... ', ...
        fileIndex,numel(selectedFiles),fileName,fileExt);

    skipReason = localSkipReason(filePath,config);
    if ~isempty(skipReason)
        result = localMakeResult(filePath,'Skipped','', ...
            resultStartedAt,localTimestamp(),0);
        run.results(end+1) = result;
        fprintf('SKIPPED\n');
        run = localRecordEvent(run,'ScriptSkipped', ...
            localEventDetail(fileIndex,numel(selectedFiles),filePath,skipReason));
        continue;
    end

    localResetISETState;
    timer = tic;
    [passed,errorText] = localExecuteFile(filePath,targetDir);
    durationSeconds = toc(timer);
    localResetISETState;

    if passed
        result = localMakeResult(filePath,'Passed','', ...
            resultStartedAt,localTimestamp(),durationSeconds);
        eventName = 'ScriptPassed';
        fprintf('\n-----OK-----\n');
    else
        result = localMakeResult(filePath,'Failed',errorText, ...
            resultStartedAt,localTimestamp(),durationSeconds);
        eventName = 'ScriptFailed';
        fprintf('\n----FAILED--\n');
        warning('Script failed: %s',errorText);
    end
    run.results(end+1) = result;
    run = localRecordEvent(run,eventName, ...
        localEventDetail(fileIndex,numel(selectedFiles),filePath,errorText));
end

run.state = 'Completed';
run.currentFile = '';
run.finishedAt = localTimestamp();
summaryText = sprintf('Passed=%d Failed=%d Skipped=%d', ...
    sum(strcmp({run.results.status},'Passed')), ...
    sum(strcmp({run.results.status},'Failed')), ...
    sum(strcmp({run.results.status},'Skipped')));
run = localRecordEvent(run,'RunCompleted',summaryText);
ieTestReport(run);

end

function config = localValidateConfig(config)
%% Validate and fill the shared runner configuration.

if ~isstruct(config) || ~isscalar(config)
    error('ieRunTutorialExampleTests:InvalidConfig', ...
        'config must be a scalar struct.');
end
requiredFields = {'repositoryName','repositoryRoot','suiteKind','runnerName'};
for fieldIndex = 1:numel(requiredFields)
    fieldName = requiredFields{fieldIndex};
    if ~isfield(config,fieldName) || isempty(config.(fieldName))
        error('ieRunTutorialExampleTests:MissingConfig', ...
            'Missing required config field: %s',fieldName);
    end
end

config.repositoryName = char(config.repositoryName);
config.repositoryRoot = char(config.repositoryRoot);
config.suiteKind = lower(char(config.suiteKind));
config.runnerName = char(config.runnerName);
if ~ismember(config.suiteKind,{'tutorials','examples'})
    error('ieRunTutorialExampleTests:InvalidSuiteKind', ...
        'suiteKind must be tutorials or examples.');
end

if ~isfield(config,'selector'), config.selector = ''; end
if ~isfield(config,'start'), config.start = ''; end
if ~isfield(config,'skipPathPatterns'), config.skipPathPatterns = {}; end
if ~isfield(config,'conditionalSkipFcn'), config.conditionalSkipFcn = []; end
if ~isfield(config,'setupFcn'), config.setupFcn = []; end
config.selector = char(config.selector);
config.start = char(config.start);
if ischar(config.skipPathPatterns)
    config.skipPathPatterns = {config.skipPathPatterns};
end
if ~iscell(config.skipPathPatterns)
    error('ieRunTutorialExampleTests:InvalidSkipPatterns', ...
        'skipPathPatterns must be a cell array of character vectors.');
end
if ~isempty(config.conditionalSkipFcn) && ...
        ~isa(config.conditionalSkipFcn,'function_handle')
    error('ieRunTutorialExampleTests:InvalidConditionalSkipFcn', ...
        'conditionalSkipFcn must be a function handle.');
end
if ~isempty(config.setupFcn) && ~isa(config.setupFcn,'function_handle')
    error('ieRunTutorialExampleTests:InvalidSetupFcn', ...
        'setupFcn must be a function handle.');
end

end

function files = localDiscoverFiles(targetDir)
%% Discover canonical plain-text tutorial/example sources.

entries = [dir(fullfile(targetDir,'**','t_*.m')); ...
    dir(fullfile(targetDir,'**','s_*.m'))];
files = cell(numel(entries),1);
for fileIndex = 1:numel(entries)
    files{fileIndex} = fullfile(entries(fileIndex).folder,entries(fileIndex).name);
end
files = unique(files);
files = sort(files);

end

function localRejectDuplicateStems(files,targetDir)
%% Reject ambiguous duplicate script stems before execution.

stems = cell(size(files));
for fileIndex = 1:numel(files)
    [~,stems{fileIndex}] = fileparts(files{fileIndex});
end
[uniqueStems,~,groupIndex] = unique(stems);
counts = accumarray(groupIndex,1);
duplicates = uniqueStems(counts > 1);
if isempty(duplicates), return; end

details = cell(size(duplicates));
for duplicateIndex = 1:numel(duplicates)
    matches = files(strcmp(stems,duplicates{duplicateIndex}));
    matches = cellfun(@(x) localRelativePath(x,targetDir),matches, ...
        'UniformOutput',false);
    details{duplicateIndex} = sprintf('%s: %s',duplicates{duplicateIndex}, ...
        strjoin(matches,', '));
end
error('ieRunTutorialExampleTests:DuplicateStem', ...
    'Duplicate script stems are not supported. %s',strjoin(details,' | '));

end

function selectedFiles = localSelectFiles(files,targetDir,selector)
%% Select all files or one file by stem, name, relative path, or full path.

if isempty(selector)
    selectedFiles = files;
    return;
end
selector = localNormalizePath(selector);
targetDir = localNormalizePath(targetDir);
if startsWith(selector,['.' filesep]), selector = selector(3:end); end
if startsWith(selector,[targetDir filesep])
    selector = extractAfter(selector,strlength(targetDir)+1);
end

matches = false(size(files));
for fileIndex = 1:numel(files)
    filePath = localNormalizePath(files{fileIndex});
    [~,fileName,fileExt] = fileparts(filePath);
    relativePath = localRelativePath(filePath,targetDir);
    matches(fileIndex) = strcmp(fileName,selector) || ...
        strcmp([fileName fileExt],selector) || ...
        strcmp(relativePath,selector) || strcmp(filePath,selector);
end
selectedFiles = files(matches);

end

function selectedFiles = localStartFile(files,targetDir,start)
%% Trim the execution plan so it begins with the requested file.

if isempty(start)
    selectedFiles = files;
    return;
end
matches = localSelectFiles(files,targetDir,start);
if isempty(matches)
    error('ieRunTutorialExampleTests:NoStartMatch', ...
        'No selected file matched start "%s" in %s.',start,targetDir);
end
startIndex = find(strcmp(files,matches{1}),1);
selectedFiles = files(startIndex:end);

end

function run = localCreateRun(config,targetDir,plannedFiles)
%% Construct the canonical run record and output paths.

timeStamp = char(datetime('now','Format','yyyy-MM-dd_HHmmss'));
localDir = fullfile(config.repositoryRoot,'local');
if ~isfolder(localDir), mkdir(localDir); end
runDir = fullfile(localDir,sprintf('%s_%s',timeStamp,config.runnerName));
suffix = 1;
while isfolder(runDir)
    runDir = fullfile(localDir,sprintf('%s_%s_%d', ...
        timeStamp,config.runnerName,suffix));
    suffix = suffix+1;
end
mkdir(runDir);

run = struct();
run.schemaVersion = 1;
run.repositoryName = config.repositoryName;
run.repositoryRoot = config.repositoryRoot;
run.suiteKind = config.suiteKind;
run.runnerName = config.runnerName;
run.targetDir = targetDir;
run.selector = config.selector;
run.start = config.start;
run.state = 'Running';
run.startedAt = localTimestamp();
run.lastEventAt = run.startedAt;
run.finishedAt = '';
run.plannedFiles = plannedFiles;
run.currentIndex = 0;
run.currentFile = '';
run.results = localEmptyResults();
run.runDir = runDir;
run.checkpointFile = fullfile(runDir,'checkpoint.mat');
run.progressFile = fullfile(runDir,'progress.log');

end

function results = localEmptyResults
%% Empty canonical per-file result array.

results = struct('file',{},'status',{},'error',{}, ...
    'startedAt',{},'finishedAt',{},'durationSeconds',{});

end

function result = localMakeResult(file,status,errorText,startedAt,finishedAt,durationSeconds)
%% Construct one canonical file result.

result = struct('file',file,'status',status,'error',errorText, ...
    'startedAt',startedAt,'finishedAt',finishedAt, ...
    'durationSeconds',durationSeconds);

end

function localWritePlannedFiles(run)
%% Persist the deterministic execution plan for convenient inspection.

fid = fopen(fullfile(run.runDir,'planned-files.txt'),'w');
if fid < 0, return; end
cleanupObj = onCleanup(@() fclose(fid));
for fileIndex = 1:numel(run.plannedFiles)
    fprintf(fid,'%s\n',run.plannedFiles{fileIndex});
end

end

function run = localRecordEvent(run,eventName,detail)
%% Append a progress event and atomically checkpoint the canonical run.

run.lastEventAt = localTimestamp();
line = sprintf('[%s] %s',run.lastEventAt,eventName);
if ~isempty(detail), line = sprintf('%s | %s',line,detail); end

fid = fopen(run.progressFile,'a');
if fid >= 0
    fprintf(fid,'%s\n',line);
    fclose(fid);
end
localSaveCheckpoint(run);

end

function localSaveCheckpoint(run)
%% Atomically replace checkpoint.mat with the latest run record.

temporaryFile = [tempname(run.runDir) '.mat'];
cleanupObj = onCleanup(@() localDeleteIfPresent(temporaryFile));
save(temporaryFile,'run');
[moved,message] = movefile(temporaryFile,run.checkpointFile,'f');
if ~moved
    error('ieRunTutorialExampleTests:CheckpointWriteFailed', ...
        'Could not update checkpoint: %s',message);
end

end

function localDeleteIfPresent(fileName)
%% Delete a temporary checkpoint if an update fails.

if isfile(fileName), delete(fileName); end

end

function reason = localSkipReason(filePath,config)
%% Return an empty string or the reason this file is skipped.

commonPatterns = {'deprecated','development','Development', ...
    'xNotOnPath','library'};
patterns = [commonPatterns config.skipPathPatterns];
reason = '';
for patternIndex = 1:numel(patterns)
    if contains(filePath,patterns{patternIndex})
        reason = sprintf('path pattern: %s',patterns{patternIndex});
        return;
    end
end

fileText = fileread(filePath);
if contains(fileText,'% SkipFile')
    reason = 'source marker: % SkipFile';
    return;
elseif contains(fileText,'% UTTBSkip')
    reason = 'legacy source marker: % UTTBSkip';
    return;
end

if isempty(config.conditionalSkipFcn), return; end
conditionalResult = config.conditionalSkipFcn(filePath);
if islogical(conditionalResult) && conditionalResult
    reason = 'conditional skip';
elseif ischar(conditionalResult) || ...
        (isstring(conditionalResult) && isscalar(conditionalResult))
    reason = char(conditionalResult);
end

end

function localResetISETState
%% Reset figures, variables, and vcSESSION using the supported initializer.

ieSessionSet('wait bar',false);
ieSessionSet('init clear',true);
ieInit;
drawnow;

end

function [passed,errorText] = localExecuteFile(filePath,targetDir)
%% Run one script from its directory in this isolated function workspace.

currentDir = pwd;
cleanupObj = onCleanup(@() cd(currentDir));
if ~localIsWithin(filePath,targetDir)
    error('ieRunTutorialExampleTests:OutsideTarget', ...
        'Script path is outside target directory: %s',filePath);
end
cd(fileparts(filePath));
try
    % fprintf('Running %s\n',filePath);
    run(filePath);
    passed = true;
    errorText = '';
catch exception
    passed = false;
    errorText = localCompactError(getReport(exception,'extended','hyperlinks','off'));
end

end

function tf = localIsWithin(filePath,targetDir)
%% Test path containment at a directory boundary.

filePath = localNormalizePath(filePath);
targetDir = localNormalizePath(targetDir);
tf = strcmp(filePath,targetDir) || startsWith(filePath,[targetDir filesep]);

end

function localRestorePreferences(waitBarFlag,initClearFlag)
%% Restore preferences changed by the engine after a normal MATLAB return.

ieSessionSet('wait bar',waitBarFlag);
ieSessionSet('init clear',initClearFlag);

end

function value = localTimestamp
%% Stable human-readable timestamp.

value = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));

end

function detail = localEventDetail(fileIndex,totalFiles,filePath,message)
%% Format one progress-log detail string.

detail = sprintf('[%d/%d] %s',fileIndex,totalFiles,filePath);
if ~isempty(message), detail = sprintf('%s | %s',detail,message); end

end

function value = localCompactError(value)
%% Collapse a multiline MATLAB report for logs and summaries.

value = strtrim(value);
value = regexprep(value,'\s*\n\s*',' | ');

end

function pathName = localRelativePath(filePath,targetDir)
%% Return a normalized path relative to targetDir.

filePath = localNormalizePath(filePath);
targetDir = localNormalizePath(targetDir);
prefix = [targetDir filesep];
if startsWith(filePath,prefix)
    pathName = char(extractAfter(filePath,strlength(prefix)));
else
    pathName = filePath;
end

end

function pathName = localNormalizePath(pathName)
%% Normalize separators without requiring the path to exist.

pathName = char(pathName);
pathName = strrep(pathName,'/',filesep);
pathName = strrep(pathName,'\',filesep);

end
