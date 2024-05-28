%% s_scriptsPublish
%
% Publish scripts as HTML files that can be viewed in a browser.
%
% Copyright ImageVal Consulting, LLC 2016

%% Do not clear the variables on an ieInit
ieSessionSet('init clear',false);

%%
ieInit;

%% One scripts sub directory at a time
% str = 'optics';    % Which directory
% tDir = {str};

% All at once
tDir = {'camera','code','color','display','gui',...
    'image','introduction','metrics','oi','optics',...
    'printing','scene','sensor'};
maxHeight = 512;
maxWidth  = 512;

% Output directory and format - The number of characters on a comment
% line needs to be reduced for publish.  70 seems OK.
% This could be {'html','pdf'}
oFormats = {'html'};

excludeNames = {'Contents.m'};

%% Loop on all the directories in the list
for ss = 1:length(tDir)
    fprintf('Script directory: %s \n',tDir{ss});
    oDir = fullfile(isetRootPath,'local','publish',tDir{ss});
    if ~exist(oDir,'dir'), mkdir(oDir); end

    % Run them - later we can publish them, as a group with similar code.
    cd(fullfile(isetRootPath,'tutorials',tDir{ss}));
    allTutorials = dir('*.m');
    tutorialNames = excludeTutorials(allTutorials,excludeNames);
    nTutorials = length(tutorialNames);
    fprintf('Executing %d scripts from %s directory\n',nTutorials,tDir{ss});
    
    for thisTutorial=1:nTutorials
        % Need to re-execute on each loop because of the ieInit commands
        cd(fullfile(isetRootPath,'tutorials',tDir{ss}));
        
        fprintf('%d %s ...',thisTutorial,tutorialNames(thisTutorial).name);
        
        for thisFormat = 1:length(oFormats)
            publish(tutorialNames(thisTutorial).name,...
                'format',oFormats{thisFormat},...
                'outputDir',oDir, ...
                'maxHeight',maxHeight,...
                'maxWidth',maxWidth);
        end
        
        fprintf('done\n');
    end

    fprintf('***** done with directory %s ***** \n\n',tDir{ss});
end


%%
function keepScripts = excludeTutorials(these,excludeNames)

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

