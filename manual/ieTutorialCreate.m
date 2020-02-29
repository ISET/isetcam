function ieTutorialCreate
% Publish html files of the principal tutorials
%
% Copy key files that begin with t_<TAB> to a new
% directory.  Run publish on them.  Give the directory to Joyce/Imageval.
%
% BW, Copyright Imageval Consulting, LLC 2015

%% Deal with variable clearing in scripts

% Store starting state
% For this script, set clear to false
initClear = ieSessionGet('init clear');
ieSessionSet('init clear',false);

% Do not use the wait bar so it doesn't appear in the files
wbStatus = ieSessionGet('wait bar');
ieSessionSet('wait bar',false);

ieInit;

%% Make the basic tutorial directory
tHome = fullfile(isetRootPath,'..','tutorials');
if ~exist(tHome,'dir'), mkdir(tHome); end
chdir(tHome);

%% Scene tutorials
chdir(tHome)
if ~exist('./scene','dir'), mkdir('scene'); end
chdir('scene')

tList = {'t_sceneIntroduction.m','t_sceneRGB2Radiance.m','t_sceneSurfaceModels.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'scene'))
movefile('html/*','.');
rmdir('html');

%% OI tutorials
chdir(tHome);
if ~exist('./oi','dir'), mkdir('oi'); end
chdir('oi')

tList = {'t_oiIntroduction.m','t_oiCompute.m','t_oiRTCompute.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'oi'))
movefile('html/*','.');
rmdir('html');


%% Optics tutorials

chdir(tHome);
if ~exist('./optics','dir'), mkdir('optics'); end
chdir('optics')

tList = {'t_opticsAiryDisk.m','t_opticsDiffraction.m','t_opticsImageFormation.m','t_opticsBarrelDistortion.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'optics'))
movefile('html/*','.');
rmdir('html');

%% Sensor
chdir(tHome);
if ~exist('./sensor','dir'), mkdir('sensor'); end
chdir('sensor')

tList = {'t_sensorExposure.m','t_sensorEstimation.m','s_sensorCountingPhotons.m','s_sensorExposureBracket.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'sensor'))
movefile('html/*','.');
rmdir('html');


%% image processing
chdir(tHome);
if ~exist('./ip','dir'), mkdir('ip'); end
chdir('ip')

tList = {'t_ip.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'ip'))
movefile('html/*','.');
rmdir('html');

%% Metrics
chdir(tHome);
if ~exist('./metrics','dir'), mkdir('metrics'); end
chdir('metrics')

tList = {'t_metricsColor.m','t_metricsScielab.m','s_scielabMTF.m','s_scielabPatches.m','s_metricsMTFSlantedBar.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'metrics'))
movefile('html/*','.');
rmdir('html');

%% Display
chdir(tHome);
if ~exist('./display','dir'), mkdir('display'); end
chdir('display')

tList = {'t_displayIntroduction.m','t_displayRendering.m'};
for tt=1:length(tList)
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt}); end
    copyfile(tFile,tList{tt});
    publish(tList{tt},'html')
    publish(tList{tt},'pdf')
    delete(tList{tt});
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'display'))
movefile('html/*','.');
rmdir('html');


%% Return init clear and wait bar status

ieSessionSet('init clear',initClear);
ieSessionSet('wait bar',  wbStatus);

%% END

