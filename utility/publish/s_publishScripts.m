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
saveDir = pwd;
%{
% All at once
sDir = {'color','data','display','gui','human','image',...
    'metrics','oi','optics','scene','sensor','utility'};
%}
% Or pick a subset
sDir = {'optics'};
maxHeight = 512;
maxWidth  = 512;

% Output directory and format - The number of characters on a comment
% line needs to be reduced for publish.  70 seems OK.
% This could be {'html','pdf'}
oFormats = {'html'};

excludeNames = {'Contents.m'};
% Loop on all the directories in the list
for ss = 1:length(sDir)
    fprintf('Script directory: %s \n',sDir{ss});
    oDir = fullfile(isetRootPath,'local','scripts',sDir{ss});
    if ~exist(oDir,'dir'), mkdir(oDir); end

    % Run them - later we can publish them, as a group with similar code.
    cd(fullfile(isetRootPath,'scripts',sDir{ss}));
    allScripts = dir('*.m');
    scriptNames = excludeScripts(allScripts,excludeNames);
    nScripts = length(scriptNames);
    fprintf('Executing %d scripts from %s directory\n',nScripts,sDir{ss});
    
    for thisScript=1:nScripts
        % Need to re-execute on each loop because of the ieInit commands
        cd(fullfile(isetRootPath,'scripts',sDir{ss}));
        
        fprintf('%d %s ...',thisScript,scriptNames(thisScript).name);
        
        for thisFormat = 1:length(oFormats)
            publish(scriptNames(thisScript).name,...
                'format',oFormats{thisFormat},...
                'outputDir',oDir, ...
                'maxHeight',maxHeight,...
                'maxWidth',maxWidth);
        end
        
        fprintf('done\n');
    end
    % ieInit forces us to reset.
    % sDir = {str};
    fprintf('***** Finished directory %s \n\n',sDir{ss});
end


%%
function keepScripts = excludeScripts(theseScripts,excludeNames)

keepScripts = [];

cnt = 1;
for ii=1:length(theseScripts)
    if ismember(theseScripts(ii).name,excludeNames)
        % Do nothing
    else
        % Add to the list we keep.  Notice that only the name is preserved.
        keepScripts(cnt).name = theseScripts(ii).name; %#ok<AGROW>
        cnt = cnt+1;
    end
end

end

