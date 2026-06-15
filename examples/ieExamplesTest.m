function testResults = ieExamplesTest()
% ieExamplesTest - Runs all s_* and t_* scripts in the ISETCam examples directory safely
%
% Usage:
%   testResults = ieExamplesTest;
%
% It evaluates each script in the base workspace so that `clear` commands
% within the scripts do not destroy the state of this runner function.
% It catches errors and prints a summary report at the end.

    % Define the target directory relative to isetcam root
    targetDir = fullfile(isetRootPath, 'examples');
    
    % Find all .m files that start with t_ or s_ recursively
    filesS = dir(fullfile(targetDir, '**', 's_*.m'));
    filesT = dir(fullfile(targetDir, '**', 't_*.m'));
    allFiles = [filesS; filesT];
    
    if isempty(allFiles)
        fprintf('No s_* or t_* scripts found in %s.\n', targetDir);
        testResults = struct('file', {}, 'status', {}, 'error', {});
        return;
    end
    
    % Initialize results
    testResults = struct('file', {}, 'status', {}, 'error', {});
    
    fprintf('\n=========================================\n');
    fprintf('Running %d scripts in %s\n', length(allFiles), targetDir);
    fprintf('=========================================\n');
    
    for ii = 1:length(allFiles)
        [~, name, ~] = fileparts(allFiles(ii).name);
        scriptPath = fullfile(allFiles(ii).folder, allFiles(ii).name);
        
        fprintf('Run [%d/%d]: %s... ', ii, length(allFiles), name);
        
        try
            ieInit; % Clean up figures and standard environment
            
            % Execute the script in the base workspace to avoid 'clear'
            % commands wiping out our local variables.
            evalin('base', sprintf('run(''%s'')', scriptPath));
            
            status = 'Passed';
            errMsg = '';
            fprintf('OK\n');
        catch ME
            status = 'Failed';
            errMsg = ME.message;
            fprintf('FAILED\n');
            warning('Script failed: %s', errMsg);
        end
        
        % Save results
        testResults(end+1).file = scriptPath;
        testResults(end).status = status;
        testResults(end).error = errMsg;
        
        % Cleanup current loop figures
        drawnow;
        close all;
    end
    
    % Print summary
    fprintf('\n--- ieExamplesTest Summary ---\n');
    fprintf('Total scripts run: %d\n', length(testResults));
    
    passedCount = sum(strcmp({testResults.status}, 'Passed'));
    failedCount = sum(strcmp({testResults.status}, 'Failed'));
    
    fprintf('Total Passed:     %d\n', passedCount);
    fprintf('Total Failed:     %d\n', failedCount);
    
    if failedCount > 0
        fprintf('\nFailed scripts:\n');
        for ii = 1:length(testResults)
            if strcmp(testResults(ii).status, 'Failed')
                [~, fName, ext] = fileparts(testResults(ii).file);
                fprintf('  %-25s : %s\n', [fName, ext], testResults(ii).error);
            end
        end
    end
end
