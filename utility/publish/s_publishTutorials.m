%% s_publishTutorials
%
% Publish tutorials as HTML files that can be viewed in a browser.
%
% HTML and figure PNG files are written next to each tutorial m-file.
%
% Copyright ImageVal Consulting, LLC 2016

%% Do not clear the variables on an ieInit
ieSessionSet('init clear',false);

%%
ieInit;

%% One tutorial sub directory at a time
str = 'scene';    % Which directory
tDir = {str};

%{
% All at once
tDir = {'camera','code','color','display','gui',...
    'image','introduction','metrics','oi','optics',...
    'printing','scene','sensor'};
%}

maxHeight = 512;
maxWidth  = 512;

excludeNames = {'Contents.m'};

%% Loop on all the directories in the list
for ss = 1:length(tDir)
    fprintf('Tutorial directory: %s \n',tDir{ss});

    tutorialDir = fullfile(isetRootPath,'tutorials',tDir{ss});
    allTutorials = dir(fullfile(tutorialDir,'*.m'));
    tutorialNames = excludeTutorials(allTutorials,excludeNames);
    nTutorials = length(tutorialNames);
    fprintf('Publishing %d tutorials from %s directory\n',nTutorials,tDir{ss});

    for thisTutorial=1:nTutorials
        fprintf('%d %s ...',thisTutorial,tutorialNames(thisTutorial).name);
        tutorialFile = fullfile(tutorialDir,tutorialNames(thisTutorial).name);
        ieTutorialPublish(tutorialFile,...
            'maxHeight',maxHeight,...
            'maxWidth',maxWidth,...
            'createThumbnail',false,...
            'imageFormat','png');

        fprintf('done\n');
    end

    fprintf('***** done with directory %s ***** \n\n',tDir{ss});
end


%%
function keepScripts = excludeTutorials(these,excludeNames)

keepScripts = [];

cnt = 1;
for ii=1:length(these)
    if ismember(these(ii).name,excludeNames)
        % Do nothing
    else
        % Add to the list we keep.  Notice that only the name is preserved.
        keepScripts(cnt).name = these(ii).name; %#ok<AGROW>
        cnt = cnt+1;
    end
end

end
