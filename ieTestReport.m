function summary = ieTestReport(results,runnerName)
% IETESTREPORT - Print a compact unittest summary with failing test names.
%
% Synopsis
%   summary = ieTestReport(results,[runnerName])
%
% Brief
%   MATLAB's unittest text runner prints failures as they occur, but in a
%   long suite the useful names can scroll away. This helper prints a final
%   count and a compact list of tests that failed or did not complete.

if ieNotDefined('runnerName'), runnerName = 'ISETCam'; end

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
