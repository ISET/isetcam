function s_publishTutorials(tDir)
% Publish tutorials as self-contained HTML files viewable in a browser.
%
% Syntax:
%   s_publishTutorials          % publish all tutorial directories
%   s_publishTutorials scene    % publish one directory (command syntax)
%   s_publishTutorials('scene') % publish one directory (function syntax)
%   s_publishTutorials('scene','oi','sensor') % publish several
%
% Description:
%   Calls ieTutorialPublish on every m-file in the specified tutorial
%   subdirectory (or directories).  HTML is written next to each m-file
%   with figures embedded as base64 so no external PNG files are needed.
%
% Input:
%   tDir - one or more subdirectory names under tutorials/.
%          Defaults to all known tutorial directories when omitted.
%
% Copyright ImageVal Consulting, LLC 2016

allDirs = {'camera','code','color','display','gui',...
    'image','introduction','metrics','oi','optics',...
    'printing','scene','sensor'};

if nargin == 0
    tDir = allDirs;
elseif ischar(tDir)
    tDir = {tDir};
end

ieSessionSet('init clear',false);
ieInit;

maxHeight    = 512;
maxWidth     = 512;
excludeNames = {'Contents.m'};

for ss = 1:numel(tDir)
    fprintf('Tutorial directory: %s\n', tDir{ss});

    tutorialDir   = fullfile(isetRootPath,'tutorials',tDir{ss});
    allTutorials  = dir(fullfile(tutorialDir,'*.m'));
    tutorialNames = excludeTutorials(allTutorials, excludeNames);
    nTutorials    = numel(tutorialNames);
    fprintf('Publishing %d tutorials from %s\n', nTutorials, tDir{ss});

    for ii = 1:nTutorials
        fprintf('  %d  %s ...', ii, tutorialNames(ii).name);
        tutorialFile = fullfile(tutorialDir, tutorialNames(ii).name);
        ieTutorialPublish(tutorialFile, ...
            'maxHeight',      maxHeight,  ...
            'maxWidth',       maxWidth,   ...
            'createThumbnail',false,      ...
            'imageFormat',    'inline');
        fprintf('done\n');
    end

    fprintf('***** done with %s *****\n\n', tDir{ss});
end

end

% -------------------------------------------------------------------------
function keepScripts = excludeTutorials(these, excludeNames)

keepScripts = [];
cnt = 1;
for ii = 1:numel(these)
    if ~ismember(these(ii).name, excludeNames)
        keepScripts(cnt).name = these(ii).name; %#ok<AGROW>
        cnt = cnt + 1;
    end
end

end
