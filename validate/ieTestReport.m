function summary = ieTestReport(results,runnerName,varargin)
% IETESTREPORT - Summarize unit tests or a tutorial/example run checkpoint.
%
% Synopsis
%   summary = ieTestReport(results,[runnerName])
%   summary = ieTestReport(scriptResults,[runnerName],...)
%   summary = ieTestReport(checkpointPath,...)
%   summary = ieTestReport(runDirectory,'List',statuses)
%
% Brief
%   MATLAB's unittest text runner prints failures as they occur, but in a
%   long suite the useful names can scroll away. This helper prints a final
%   count and a compact list of tests that failed or did not complete.
%
%   A tutorial or example checkpoint can be supplied as its checkpoint.mat
%   path or as the containing run directory. Use the 'List' option to print
%   files with requested statuses: 'passed', 'failed', 'skipped', or 'all'.

if nargin < 2, runnerName = ''; end

if localIsCanonicalRun(results)
    if localIsOptionName(runnerName)
        varargin = [{runnerName} varargin];
        runnerName = '';
    end
    summary = localCheckpointReport(localCanonicalCheckpoint(results), ...
        runnerName,varargin{:});
    return;
end

if localIsCheckpointInput(results)
    if localIsOptionName(runnerName)
        varargin = [{runnerName} varargin];
        runnerName = '';
    end
    summary = localCheckpointReport(results,runnerName,varargin{:});
    return;
end

if localIsScriptRunResults(results)
    if localIsOptionName(runnerName)
        varargin = [{runnerName} varargin];
        runnerName = '';
    end
    summary = localScriptResultsReport(results,runnerName,varargin{:});
    return;
end

if isempty(runnerName), runnerName = 'ISETCam'; end

summary = struct('passed',0,'failed',0,'incomplete',0,'notPassed',[]);

if isempty(results)
    fprintf('\n--- %s Test Summary ---\n',runnerName);
    fprintf('No tests were run.\n');
    return;
end

summary.passed = sum([results.Passed]);
summary.failed = sum([results.Failed]);
summary.incomplete = sum([results.Incomplete]);

notPassed = [results.Failed] | [results.Incomplete];
summary.notPassed = results(notPassed);

fprintf('\n--- %s Test Summary ---\n',runnerName);
fprintf('Total Passed:     %d\n',summary.passed);
fprintf('Total Failed:     %d\n',summary.failed);
fprintf('Total Incomplete: %d\n',summary.incomplete);

if any(notPassed)
    fprintf('\nFailed or incomplete tests:\n');
    for ii = find(notPassed)
        status = localStatus(results(ii));
        fprintf('  %-18s %s\n',status,results(ii).Name);
    end
end

end

function tf = localIsCanonicalRun(results)
%% True for the shared schema-versioned tutorial/example run record.

tf = isstruct(results) && isscalar(results) && ...
    all(isfield(results,{'schemaVersion','plannedFiles','results'}));

end

function checkpoint = localCanonicalCheckpoint(run)
%% Adapt a canonical run record to the common reporting representation.

if run.schemaVersion ~= 1
    error('ieTestReport:UnsupportedSchema', ...
        'Unsupported tutorial/example run schema version: %d', ...
        run.schemaVersion);
end
checkpoint = struct();
checkpoint.logInfo = struct('runnerName',run.runnerName, ...
    'targetDir',run.targetDir);
checkpoint.runState = struct('lastEventAt',run.lastEventAt, ...
    'currentFile',run.currentFile,'currentIndex',run.currentIndex, ...
    'totalFiles',numel(run.plannedFiles), ...
    'completedResults',run.results,'state',run.state);

end

function tf = localIsScriptRunResults(results)
%% True for the common tutorial/example runner return struct.

tf = isstruct(results) && all(isfield(results,{'file','status','error'}));

end

function summary = localScriptResultsReport(results,runnerName,varargin)
%% Adapt a completed runner return value to the checkpoint report path.

if isempty(runnerName), runnerName = 'Tutorial/Example'; end
checkpoint = struct();
checkpoint.logInfo = struct('runnerName',runnerName,'targetDir','');
checkpoint.runState = struct( ...
    'lastEventAt','', ...
    'currentFile','', ...
    'currentIndex',numel(results), ...
    'totalFiles',numel(results), ...
    'completedResults',results);
summary = localCheckpointReport(checkpoint,runnerName,varargin{:});

end

function tf = localIsCheckpointInput(results)
%% True for a checkpoint path, run directory, or loaded checkpoint struct.

tf = (ischar(results) || (isstring(results) && isscalar(results))) || ...
    (isstruct(results) && isscalar(results) && isfield(results,'runState'));

end

function tf = localIsOptionName(value)
%% True when the optional runner-name position contains a name-value key.

tf = (ischar(value) || (isstring(value) && isscalar(value))) && ...
    strcmpi(value,'List');

end

function summary = localCheckpointReport(checkpointInput,runnerName,varargin)
%% Load and summarize a tutorial/example checkpoint.

checkpoint = localLoadCheckpoint(checkpointInput);
runState = checkpoint.runState;
if isfield(checkpoint,'logInfo'), logInfo = checkpoint.logInfo;
else, logInfo = struct();
end

if isempty(runnerName)
    if isfield(logInfo,'runnerName') && ~isempty(logInfo.runnerName)
        runnerName = logInfo.runnerName;
    else
        runnerName = 'Tutorial/Example';
    end
end

p = inputParser;
p.addParameter('List',{},@(x)(ischar(x) || isstring(x) || iscell(x)));
p.parse(varargin{:});
listedStatuses = localNormalizeStatusList(p.Results.List);

completedResults = runState.completedResults;
statuses = lower(string({completedResults.status}));
summary = struct();
summary.passed = sum(statuses == "passed");
summary.failed = sum(statuses == "failed");
summary.skipped = sum(statuses == "skipped");
summary.completed = numel(completedResults);
summary.planned = runState.totalFiles;
summary.unfinished = max(summary.planned-summary.completed,0);
summary.currentFile = runState.currentFile;
summary.results = completedResults;
if isfield(runState,'state'), summary.state = runState.state;
elseif summary.unfinished == 0, summary.state = 'Completed';
else, summary.state = 'Running';
end

fprintf('\n--- %s Run Summary ---\n',runnerName);
fprintf('Run State:        %s\n',summary.state);
fprintf('Total Planned:    %d\n',summary.planned);
fprintf('Total Completed:  %d\n',summary.completed);
fprintf('Total Passed:     %d\n',summary.passed);
fprintf('Total Failed:     %d\n',summary.failed);
fprintf('Total Skipped:    %d\n',summary.skipped);
fprintf('Total Unfinished: %d\n',summary.unfinished);

if summary.unfinished > 0 && ~isempty(summary.currentFile)
    fprintf('Last active file: %s\n',localDisplayPath(summary.currentFile,logInfo));
end
if isfield(runState,'lastEventAt') && ~isempty(runState.lastEventAt)
    fprintf('Last checkpoint:  %s\n',runState.lastEventAt);
end

for statusIndex = 1:numel(listedStatuses)
    localPrintFileList(completedResults,listedStatuses{statusIndex},logInfo);
end

end

function checkpoint = localLoadCheckpoint(checkpointInput)
%% Resolve and load checkpoint data.

if isstruct(checkpointInput)
    checkpoint = checkpointInput;
    return;
end

checkpointPath = char(checkpointInput);
if isfolder(checkpointPath)
    checkpointPath = fullfile(checkpointPath,'checkpoint.mat');
end
if ~isfile(checkpointPath)
    error('ieTestReport:CheckpointNotFound', ...
        'Checkpoint file not found: %s',checkpointPath);
end

loadedData = load(checkpointPath);
if isfield(loadedData,'run') && localIsCanonicalRun(loadedData.run)
    checkpoint = localCanonicalCheckpoint(loadedData.run);
elseif isfield(loadedData,'runState') && ...
        isfield(loadedData.runState,'completedResults')
    checkpoint = loadedData;
else
    error('ieTestReport:InvalidCheckpoint', ...
        'File is not a tutorial/example checkpoint: %s',checkpointPath);
end

end

function statuses = localNormalizeStatusList(value)
%% Normalize requested file-list statuses.

if isempty(value)
    statuses = {};
    return;
end
if ischar(value), value = {value};
elseif isstring(value), value = cellstr(value(:));
end

statuses = cellfun(@(x)(lower(char(x))),value,'UniformOutput',false);
if any(strcmp(statuses,'all'))
    statuses = {'passed','failed','skipped'};
end
validStatuses = {'passed','failed','skipped'};
if any(~ismember(statuses,validStatuses))
    error('ieTestReport:InvalidStatus', ...
        'List must contain passed, failed, skipped, or all.');
end
statuses = unique(statuses,'stable');

end

function localPrintFileList(results,status,logInfo)
%% Print files having one requested status.

if isempty(results), matches = false(1,0);
else, matches = strcmpi({results.status},status);
end
fprintf('\n%s files (%d):\n',localTitleCase(status),sum(matches));
for resultIndex = find(matches)
    fileName = localDisplayPath(results(resultIndex).file,logInfo);
    if strcmp(status,'failed') && ~isempty(results(resultIndex).error)
        fprintf('  %s\n    %s\n',fileName,results(resultIndex).error);
    else
        fprintf('  %s\n',fileName);
    end
end

end

function pathName = localDisplayPath(fileName,logInfo)
%% Prefer a path relative to the tutorial/example root.

pathName = fileName;
if isfield(logInfo,'targetDir') && ~isempty(logInfo.targetDir)
    prefix = [logInfo.targetDir filesep];
    if startsWith(pathName,prefix)
        pathName = extractAfter(pathName,strlength(prefix));
    end
end
pathName = char(pathName);

end

function value = localTitleCase(value)
%% Uppercase the first character for a display heading.

value(1) = upper(value(1));

end

function status = localStatus(result)
%% Human-readable status for one TestResult.

if result.Failed && result.Incomplete
    status = 'FAILED/INCOMPLETE';
elseif result.Failed
    status = 'FAILED';
elseif result.Incomplete
    status = 'INCOMPLETE';
else
    status = 'PASSED';
end

end
