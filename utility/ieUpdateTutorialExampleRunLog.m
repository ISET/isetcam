function ieUpdateTutorialExampleRunLog(logInfo, eventName, runState, detail)
% ieUpdateTutorialExampleRunLog - Append a durable progress event and checkpoint state
%
% Syntax:
%   ieUpdateTutorialExampleRunLog(logInfo, eventName, runState, detail)

if nargin < 4, detail = ''; end

timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
line = sprintf('[%s] %s', timestamp, eventName);
if ~isempty(detail)
    line = sprintf('%s | %s', line, detail);
end

fid = fopen(logInfo.progressFile, 'a');
if fid >= 0
    cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, '%s\n', line);
end

runState.lastEventAt = timestamp;
save(logInfo.checkpointFile, 'logInfo', 'runState');

end