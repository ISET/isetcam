%% s_publishExamples
%
% Publish scripts as HTML files that can be viewed in a browser.
%
% Note on publishing individual files:
% To publish a single example script (e.g., s_myExample.m) with the exact
% formatting and sizing settings used here, use the underlying
% utility directly:
%    iePublish('s_myExample.m');
%
% HTML and figure PNG files are written next to each script m-file.
%
% Copyright ImageVal Consulting, LLC 2016

%% Do not clear the variables on an ieInit
ieSessionSet('init clear',false);

%%
ieInit;

%% One scripts sub directory at a time
%{
% All at once
sDir = {'color','data','display','gui','human','image',...
    'metrics','oi','optics','scene','sensor','utility'};
%}
% Or pick a subset
sDir = {'optics'};
maxHeight = 512;
maxWidth  = 512;

excludeNames = {'Contents.m'};
% Loop on all the directories in the list
for ss = 1:length(sDir)
    fprintf('Script directory: %s \n',sDir{ss});

    scriptDir = fullfile(isetRootPath,'scripts',sDir{ss});
    allScripts = dir(fullfile(scriptDir,'*.m'));
    scriptNames = excludeScripts(allScripts,excludeNames);
    nScripts = length(scriptNames);
    fprintf('Publishing %d scripts from %s directory\n',nScripts,sDir{ss});

    for thisScript=1:nScripts
        fprintf('%d %s ...',thisScript,scriptNames(thisScript).name);
        scriptFile = fullfile(scriptDir,scriptNames(thisScript).name);
        iePublish(scriptFile,...
            'maxHeight',maxHeight,...
            'maxWidth',maxWidth,...
            'createThumbnail',false,...
            'imageFormat','png');

        fprintf('done\n');
    end

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
