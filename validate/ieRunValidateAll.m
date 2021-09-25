function ieRunValidateAll
%ieRunValidateAll
%
% Syntax
%    ieRunValidateAll
%
% Description
%   Run all of the isetcam validation scripts and print out a report at the
%   end as to whether they threw errors, or not. Scripts inside of
%   isetRootPath/validate are run, except that scripts within the
%   directory 'development' are skipped.
%
%
% 07/26/17  dhb  Wrote this, because we care.

% User/project specific preferences
p = struct(...
    'rootDirectory',           fullfile(isetRootPath, 'validate'), ...
    'tutorialsSourceDir',      fullfile(isetRootPath, 'validate') ...                % local directory where tutorial scripts are located
    );

%% List of scripts to be skipped from automatic publishing.

% Anything with this in its path name is skipped.  The manual viewer test
% is eliminated here because it opens up so many different windows in a
% browser.  We print a reminder to test it from time to time.
scriptsToSkip = {...
    'v_ISET' ...
    'v_manualViewer',...
    'development',...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll'
    };

%% Use UnitTestToolbox method to do this.
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

fprintf('*** We suggest running v_manualViewer from time to time.***\n');

end