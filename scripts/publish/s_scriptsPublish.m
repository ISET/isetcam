%% s_scriptsPublish
%
% Publish scripts.
% 
% Find the scripts in a directory and publish them.
%
% Copyright ImageVal Consulting, LLC 2016

%% Do not clear the variables on an ieInit
ieSessionSet('init clear',false);

%%
ieInit;
clear all

%% One at a time
% str = 'optics';    % Which directory
% sDir = {str};

% All at once
% sDir = {'color','metrics','optics','scene'};     % Must also be reset in the loop, below
% sDir = {'scene','optics','sensor','color','metrics','image','display','camera',};
sDir = {'optics'};
maxHeight = 512;
maxWidth  = 512;

% Output directory and format - The number of characters on a comment
% line needs to be reduced for publish.  70 seems OK.
% This could be {'html','pdf'}
oFormats = {'html'};

% Loop on all the directories in the list
for ss = 1:length(sDir)
    fprintf('Script directory: %s \n',sDir{ss});
    oDir = fullfile('/Users/wandell/Google Drive/Business/Imageval/website',sDir{ss});
    % oDir = fullfile(isetRootPath,'local',sDir{ss});

    % Run them - later we can publish them, as a group with similar code.
    cd(fullfile(isetRootPath,'scripts',sDir{ss}));
    theseScripts = dir('*.m');
    nScripts = length(theseScripts);
    fprintf('Executing %d scripts from %s directory\n',nScripts,sDir{ss});
    for thisScript=1:nScripts
        % Need to re-execute on each loop because of the ieInit commands
        cd(fullfile(isetRootPath,'scripts',sDir{ss}));
        theseScripts = dir('*.m');

        fprintf('%d %s ...',thisScript,theseScripts(thisScript).name);
        
        for thisFormat = 1:length(oFormats)
            publish(theseScripts(thisScript).name,...
                'format',oFormats{thisFormat},...
                'outputDir',oDir, ...
                'maxHeight',maxHeight,...
                'maxWidth',maxWidth); 
        end
        
        fprintf('done\n');
    end
    % ieInit forces us to reset.
    % sDir = {str};
    fprintf('***** \n\n');
end


%%