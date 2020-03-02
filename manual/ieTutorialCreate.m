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

% https://www.mathworks.com/matlabcentral/answers/499628-how-to-set-default-font-size-in-matlab-published-html
styleSheet = fullfile(isetRootPath,'manual','mxdom2simplehtml.xsl');
if ~exist(styleSheet,'file')
    error('Style sheet file missing');
end

%% Make the publishh tutorial directory
tHome = fullfile(isetRootPath,'local','publish');
if ~exist(tHome,'dir'), mkdir(tHome); end
chdir(tHome);

%% Scene tutorials
chdir(tHome)
if ~exist('./scene','dir'), mkdir('scene'); end
chdir('scene')

tList = {'t_sceneIntroduction.m','t_sceneSurfaceModels.m',...
    's_sceneDemo.m','s_sceneExamples.m','s_sceneDataExtractionAndPlotting.m',...
    's_sceneRoi.m', ...
    't_sceneRGB2Radiance.m','s_sceneWavelength.m','s_sceneFromRGB.m',...
    's_sceneFromRGBvsMultispectral.m','s_sceneFromMultispectral.m','s_sceneHCCompress.m',...
    's_sceneHarmonics.m','s_sceneIncreaseSize.m','s_sceneMonochrome.m','s_sceneRender.m',...
    's_sceneRotate.m','s_sceneSlantedBar.m', ...
    's_sceneIlluminant.m','s_sceneDaylight.m','s_sceneChangeIlluminant.m',...
    's_sceneCCT.m','s_sceneReflectanceSamples.m','s_sceneIlluminantMixtures.m',...
    's_sceneIlluminantSpace.m','s_sceneXYZilluminantTransforms.m',...
    's_surfaceMunsell.m','s_sceneReflectanceCharts.m','s_sceneReflectanceChartBasisFunctions.m'};
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end

for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    publish(localFile,'pdf');
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'scene'))
movefile('html/*','.');
rmdir('html');
disp('Scene is done');

%% OI tutorials
chdir(tHome);
if ~exist('./oi','dir'), mkdir('oi'); end
chdir('oi')

tList = {'t_oiIntroduction.m','t_opticsImageFormation.m','t_opticsDiffraction.m',...
    't_oiCompute.m','s_opticsCoC.m','s_opticsMicrolens.m','t_opticsAiryDisk.m','t_opticsPSFPlot.m',...
    's_opticsDefocus.m','s_opticsDefocusScene.m','s_opticsDLPsf.m',...
    's_opticsSIExamples.m','s_opticsGaussianPSF.m','s_opticsSIIdeal.m',...
    't_wvfZernike.m','t_opticsWVF.m','t_opticsWVFZernike.m','t_wvfAstigmatism.m',...
    't_wvfPlot.m','t_wvfPupilSize.m','t_wvfZernikeSet.m',...
    't_oiRTCompute.m','s_opticsRTGridLines.m','s_opticsRTPSF.m','s_opticsRTPSFView.m',...
    's_opticsRTSynthetic.m','t_opticsBarrelDistortion.m','s_opticsDepthDefocus.m'};
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end
for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    publish(localFile,'pdf');
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'oi'))
movefile('html/*','.');
rmdir('html');
disp('OI is done');
%% Sensor
chdir(tHome);
if ~exist('./sensor','dir'), mkdir('sensor'); end
chdir('sensor')


% Some problem with publishing this very nice script
%   's_sensorMCC.m',
tList = {'s_sensorStackedPixels.m','t_sensorInputRefer.m','s_sensorExposureBracket.m','s_sensorCountingPhotons.m',...
    's_sensorRollingShutter.m', 's_sensorAnalyzeDarkVoltage.m','s_sensorExternalAnalysis.m',...
    's_sensorSNR.m','s_sensorSpatialNoiseDSNU.m','s_sensorSpatialNoisePRNU.m',...
    't_sensorSpatialResolution.m','s_sensorSizeResolution.m',...
    's_sensorHDR_PixelSize.m','s_sensorExposureCFA.m','s_sensorMicrolens.m',...
    't_sensorExposureColor.m','t_sensorEstimation.m','s_sensorCFA.m',...
    's_sensorPlotColorFilters.m','s_sensorSpectralEstimation.m'}; 
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end

for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512) 
    if ~isequal(tList{tt},'s_sensorMCC.m'), publish(localFile,'pdf'); end
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'sensor'))
movefile('html/*','.');
rmdir('html');

disp('Sensor is done')

%% image processing
chdir(tHome);
if ~exist('./ip','dir'), mkdir('ip'); end
chdir('ip')

tList = {'t_ip.m','t_ipDemosaic.m','t_ipJPEGMonochrome.m','t_ipJPEGcolor.m'};
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end
for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    publish(localFile,'pdf');
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'ip'))
movefile('html/*','.');
rmdir('html');
disp('IP is done');

%% Metrics
chdir(tHome);
if ~exist('./color','dir'), mkdir('color'); end
chdir('color')

% 't_cieChromaticity.m', 't_cielabEllipsoids.m'
tList = {'t_colorEnergyQuanta.m','t_colorSpectrum.m','t_colorMatching.m',...
    't_colorMetamerism.m',...
    's_colorIlluminantTransforms.m'};

for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end

for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    if ~isequal('t_cieChromaticity.m',tList{tt}) && ...
        ~isequal('t_cielabEllipsoids.m',tList{tt})
        publish(localFile,'pdf');
    end
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'color'))
movefile('html/*','.');
rmdir('html');
disp('Color is done');

%% Metrics
chdir(tHome);
if ~exist('./metrics','dir'), mkdir('metrics'); end
chdir('metrics')

tList = {'t_metricsColor.m','t_metricsScielab.m','t_ieSQRI.m',...
    's_scielabMTF.m','s_scielabPatches.m','s_metricsMTFSlantedBar.m', ...
    's_metricsMacbethDeltaE.m','s_metricsMTFPixelSize.m'};
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end
for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    publish(localFile,'pdf');
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'metrics'))
movefile('html/*','.');
rmdir('html');
disp('Metrics is done');

%% Display
chdir(tHome);
if ~exist('./display','dir'), mkdir('display'); end
chdir('display')

tList = {'t_displayIntroduction.m','t_displayRendering.m'};
for ii=1:length(tList)
    if isempty(which(tList{ii}))
        error('can not find %s\n',tList{ii});
    end
end
for tt=1:length(tList)
    localFile = fullfile(pwd,tList{tt});
    if exist(localFile,'file')
        delete(localFile);
    end
    tFile = which(tList{tt});
    if isempty(tFile), error('Missing file %s',tList{tt});
    else
        copyfile(tFile,localFile);
    end
    publish(localFile, 'stylesheet', styleSheet,'maxWidth',512)  
    publish(localFile,'pdf');
    delete(localFile);
end

% Move the files out of html into the oi directory.
chdir(fullfile(tHome,'display'))
movefile('html/*','.');
rmdir('html');


%% Return init clear and wait bar status

ieSessionSet('init clear',initClear);
ieSessionSet('wait bar',  wbStatus);

%% END

