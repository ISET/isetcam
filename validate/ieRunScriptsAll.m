function ieRunScriptsAll
%ieRunValidateAll
%
% Syntax
%    ieRunScriptsAll
%
% Description
%   Run all of the isetcam scripts and print out a report at the end as to
%   whether they threw errors, or not. Scripts inside of
%   isetRootPath/scripts are run, except that scripts within the directory
%   'development' are skipped.
%
%
% 07/26/17  dhb  Wrote this, because we care.

%%  Set for app designer buggy stuff

ieSessionSet('waitbar','off');

%%

% User/project specific preferences
% local directory where tutorial scripts are located
p = struct(...
    'rootDirectory',       fullfile(isetRootPath, 'scripts'), ...
    'tutorialsSourceDir',  fullfile(isetRootPath, 'scripts') ...
    );

%% List of scripts to be skipped from automatic publishing.
%
% Anything with this in its path name is skipped.
%
% The scripts are skipped because they write out files that are already in
% the repository and we don't want to over-write them.
scriptsToSkip = {...
    'Contents',...
    'development',...
    'jpegFiles', ...
    's_displaySurfaceReflectance',...
    's_reflectanceBasis',...
    'readrawsensor', ...
    'chromAb',...
    'publish',...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll'
    };

%% Use UnitTestToolbox method to do this.
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');
end