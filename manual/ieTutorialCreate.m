function ieTutorialCreate
% Publish html and pdf files of the principal tutorials
%
% Synopsis
%   ieTutorialCreate
%
% Description
%  Creates html and pdf files that are stored on scarlet in
%  brian/public_html/isetcam/publish.  I move them over there using fetch.
%
%  We link to those files from the ISETCam wiki pages.
%
%  The specific files that are chosen for each section of the manual are
%  listed in this function (the tList variables).
%
% See also
%  ieManualCreate - runs m2html to document the functions.
%

%% Deal with variable clearing in scripts

% Store starting state
% For this script, set clear to false
initClear = ieSessionGet('init clear');
ieSessionSet('init clear',false);

% Do not use the wait bar so it doesn't appear in the files
wbStatus = ieSessionGet('wait bar');
ieSessionSet('wait bar',false);

ieInit;

%% Make the publishh tutorial directory
tHome = fullfile(isetRootPath,'local','publish');
if ~exist(tHome,'dir'), mkdir(tHome); end
chdir(tHome);

%% Scene tutorials
chdir(tHome)
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
iePublish(tList,'scene');
disp('Scene is done');

%% OI tutorials
chdir(tHome);
tList = {'t_oiIntroduction.m','t_opticsImageFormation.m','t_opticsDiffraction.m',...
    't_oiCompute.m','s_opticsCoC.m','s_opticsMicrolens.m','t_opticsAiryDisk.m','t_opticsPSFPlot.m',...
    's_opticsDefocus.m','s_opticsDefocusScene.m','s_opticsDLPsf.m',...
    's_opticsSIExamples.m','s_opticsGaussianPSF.m','s_opticsSIIdeal.m',...
    't_wvfZernike.m','t_opticsWVF.m','t_opticsWVFZernike.m','t_wvfAstigmatism.m',...
    't_wvfPlot.m','t_wvfPupilSize.m','t_wvfZernikeSet.m',...
    't_oiRTCompute.m','s_opticsRTGridLines.m','s_opticsRTPSF.m','s_opticsRTPSFView.m',...
    's_opticsRTSynthetic.m','t_opticsBarrelDistortion.m','s_opticsDepthDefocus.m'};
iePublish(tList,'oi');
disp('OI is done');u
%% Sensor
chdir(tHome);

% Some problem with publishing this very nice script
%   's_sensorMCC.m',
tList = {'s_sensorStackedPixels.m','t_sensorInputRefer.m','s_sensorExposureBracket.m','s_sensorCountingPhotons.m',...
    's_sensorRollingShutter.m', 's_sensorAnalyzeDarkVoltage.m','s_sensorExternalAnalysis.m',...
    's_sensorSNR.m','s_sensorSpatialNoiseDSNU.m','s_sensorSpatialNoisePRNU.m',...
    't_sensorSpatialResolution.m','s_sensorSizeResolution.m',...
    's_sensorHDR_PixelSize.m','s_sensorExposureCFA.m','s_sensorMicrolens.m',...
    't_sensorExposureColor.m','t_sensorEstimation.m','s_sensorCFA.m',...
    's_sensorPlotColorFilters.m','s_sensorSpectralEstimation.m'}; 
iePublish(tList,'sensor');
disp('Sensor is done')

%% image processing
chdir(tHome);
tList = {'t_ip.m','t_ipDemosaic.m',...
    's_ipCircleMTF.m','s_ipDisplayResolution.m',...
    's_ipIlluminantCorrection.m','s_ipSensorConversion.m','s_ipHC2RGB',...
    's_ipGamutReflectance.m','s_ipSRGB.m',...
    't_ipJPEGMonochrome.m','t_ipJPEGcolor.m','s_ipWrite.m'};
iePublish(tList,'ip');
disp('IP is done');

%% Metrics
chdir(tHome);

% Problem with publish and't_cielabEllipsoids.m'
tList = {'t_colorEnergyQuanta.m','t_colorSpectrum.m','t_colorMatching.m',...
    't_colorMetamerism.m','t_cielabEllipsoids.m',...
    's_colorIlluminantTransforms.m','t_cieChromaticity.m'};
iePublish(tList,'color');
disp('Color is done');

%% Metrics
chdir(tHome);

% 's_metricsSNRPixelSizeLuxsec.m',
tList = {'t_metricsColor.m','t_metricsScielab.m','t_ieSQRI.m',...
    's_scielabMTF.m','s_scielabPatches.m','s_metricsMTFSlantedBar.m', ...
    's_metricsMacbethDeltaE.m','s_metricsMTFPixelSize.m','s_metricsAcutance.m',...
    's_metricsEdge2MTF.m','s_metricsColorAccuracy.m',...    
    's_metricsVSNR.m'};
iePublish(tList,'metrics');
disp('Metrics is done');

%% Display
chdir(tHome);
tList = {'t_displayIntroduction.m','t_displayRendering.m'};
iePublish(tList,'display');
disp('Display is done.')

%% Return init clear and wait bar status

ieSessionSet('init clear',initClear);
ieSessionSet('wait bar',  wbStatus);

end

%% END

