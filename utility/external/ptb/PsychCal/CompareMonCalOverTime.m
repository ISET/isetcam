% CompareMonCalOverTime
%
% Compare two calibrations of a display.
%
% Refits all files to with common number of primary bases and gamma fitting method.
% These are prompted for.
%
% 1/20/05	dhb, bx		Wrote it.
% 2/12/10   dhb         Don't ask for load code, just prompt for name.
%           dhb         Better plots.  And, ask for which times to compare.
% 2/15/10   dhb         Fix input, not a string.
% 3/1/10    dhb         Allow drawing from different files, refitting data, etc.
% 6/23/11   dhb         Make a chromaticity plot of the comparison as well.

%% Clear and close
clear; close all;

%% Get first calibration file and extract desired calibration
defaultFileName = 'LCDScreen';
thePrompt = sprintf('Enter first calibration filename [%s]: ',defaultFileName);
thenFileName = input(thePrompt,'s');
if (isempty(thenFileName))
    thenFileName = defaultFileName;
end
fprintf(1,'\nLoading from %s.mat\n',thenFileName);
[cal,cals] = LoadCalFile(thenFileName);
fprintf('Calibration file %s read\n',thenFileName);

% Print out available dates
fprintf('Calibration file contains %d calibrations\n',length(cals));
fprintf('Dates:\n');
for i = 1:length(cals)
    fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
end

% Get which to compare
defaultThen = length(cals)-1;
thenIndex = input(sprintf('Enter number of first calibration to compare [%d]: ',defaultThen));
if (isempty(thenIndex))
    thenIndex = defaultThen;
end
if (thenIndex < 1 || thenIndex > length(cals))
    error('Calibration number out of range\n');
end
calThen = cals{thenIndex};

%% Get second calibration file and extract desired calibration.
% This can be the same file, or a different one.
defaultFileName = thenFileName;
thePrompt = sprintf('\nEnter second calibration filename [%s]: ',defaultFileName);
nowFileName = input(thePrompt,'s');
if (isempty(nowFileName))
    nowFileName = defaultFileName;
end
fprintf(1,'\nLoading from %s.mat\n',nowFileName);
[cal,cals] = LoadCalFile(nowFileName);
fprintf('Calibration file %s read\n',nowFileName);

% Print out available dates
fprintf('Calibration file contains %d calibrations\n',length(cals));
fprintf('Dates:\n');
for i = 1:length(cals)
    fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
end

defaultNow = length(cals);
nowIndex = input(sprintf('Enter number of second calibration to compare [%d]: ',defaultNow));
if (isempty(nowIndex))
    nowIndex = defaultNow;
end
if (nowIndex < 1 || nowIndex > length(cals))
    error('Calibration number out of range\n');
end
calNow = cals{nowIndex};

%% Put them on common fitting basis, so that we are comparing the underlying
% data and not how it happened to be fit.
%
% Linear model basis
defaultNPrimaryBases = calNow.nPrimaryBases;
nPrimaryBases = input(sprintf('\nEnter number of primary bases [%d]: ',defaultNPrimaryBases));
if (isempty(nPrimaryBases))
    nPrimaryBases = defaultNPrimaryBases;
end
calThen.nPrimaryBases = nPrimaryBases;
calNow.nPrimaryBases = nPrimaryBases;
calThen = CalibrateFitLinMod(calThen);
calNow = CalibrateFitLinMod(calNow);

% Gamma type
defaultFitType = calNow.describe.gamma.fitType;
fitType = input(sprintf('Enter gamma fit type [%s]: ',defaultFitType),'s');
if (isempty(fitType))
    fitType = defaultFitType;
end
calThen.describe.gamma.fitType = fitType;
calNow.describe.gamma.fitType = fitType;
calThen = CalibrateFitGamma(calThen);
calNow = CalibrateFitGamma(calNow);

%% Say what we're doing
fprintf('\nComparing calibrations:\n');
fprintf('\t%s, %d, %s\n',thenFileName,thenIndex,calThen.describe.date);
fprintf('\t%s, %d, %s\n',nowFileName,nowIndex,calNow.describe.date);

%% Plot spectral power distributions.
%
% Plot as one plot if 3 or fewer primaries.
% Otherwise separate main measurements from what
% are probably the linear model correction terms.
if (size(calNow.gammaTable,2) <= calNow.nDevices)
    figure; clf; hold on
    plot(SToWls(calThen.S_device),calThen.P_device,'r');
    plot(SToWls(calNow.S_device),calNow.P_device,'g-');
    xlabel('Wavelength (nm)');
    ylabel('Power');
    title('Primaries');
else
    figure; clf;
    subplot(1,2,1); hold on
    plot(SToWls(calThen.S_device),calThen.P_device(:,1:calNow.nDevices),'r');
    plot(SToWls(calNow.S_device),calNow.P_device(:,1:calNow.nDevices),'g-');
    xlabel('Wavelength (nm)');
    ylabel('Power');
    title('Primaries');
    subplot(1,2,2); hold on
    plot(SToWls(calThen.S_device),calThen.P_device(:,calNow.nDevices+1:end),'r');
    plot(SToWls(calNow.S_device),calNow.P_device(:,calNow.nDevices+1:end),'g-');
    xlabel('Wavelength (nm)');
    ylabel('Power');
    title('Primaries (high order)');
end

%% Plot ambient
figure; clf; hold on
plot(SToWls(calThen.S_ambient),calThen.P_ambient,'r');
plot(SToWls(calNow.S_ambient),calNow.P_ambient,'g-');
xlabel('Wavelength (nm)');
ylabel('Power');
title('Ambient');

%% Explicitly compute and report ratio of R, G, and B full on spectra
rRatio = calThen.P_device(:,1)\calNow.P_device(:,1);
gRatio = calThen.P_device(:,2)\calNow.P_device(:,2);
bRatio = calThen.P_device(:,3)\calNow.P_device(:,3);
fprintf('Phosphor intensity ratios (now/then): %0.3g, %0.3g, %0.3g\n', ...
	rRatio,gRatio,bRatio);

%% Plot gamma functions
%
% Plot as one plot if 3 or fewer primaries.
% Otherwise separate main measurements from what
% are probably the linear model correction terms.
if (size(calNow.gammaTable,2) <= calNow.nDevices)
    figure; clf; hold on
    plot(calThen.gammaInput,calThen.gammaTable,'r');
    plot(calNow.gammaInput,calNow.gammaTable,'g-');
    xlabel('Input');
    ylabel('Output');
    title('Gamma');
    ylim([0 1.2]);
else
    figure; clf;
    subplot(1,2,1); hold on
    plot(calThen.gammaInput,calThen.gammaTable(:,1:calNow.nDevices),'r');
    plot(calNow.gammaInput,calNow.gammaTable(:,1:calNow.nDevices),'g-');
    xlabel('Input');
    ylabel('Output');
    title('Gamma');
    ylim([0 1.2]);
    subplot(1,2,2); hold on
    plot(calThen.gammaInput,calThen.gammaTable(:,calNow.nDevices+1:end),'r');
    plot(calNow.gammaInput,calNow.gammaTable(:,calNow.nDevices+1:end),'g-');
    xlabel('Input');
    ylabel('Output');
    title('Gamma (high order)');
    ylim([-1.2 1.2]);
end

%% Let's print some luminance information
load T_xyzJuddVos;
T_xyz = SplineCmf(S_xyzJuddVos,683*T_xyzJuddVos,calThen.S_device);
S_xyz = calThen.S_device;
lumsThen = T_xyz(2,:)*calThen.P_device;
maxLumThen = sum(lumsThen(1:calNow.nDevices));
lumsNow = T_xyz(2,:)*calNow.P_device;
maxLumNow = sum(lumsNow(1:calNow.nDevices));
fprintf('Maximum luminance summing primaries: then %0.3g; now %0.3g\n',maxLumThen,maxLumNow);
minLumThen = T_xyz(2,:)*calThen.P_ambient;
minLumNow = T_xyz(2,:)*calNow.P_ambient;
fprintf('Minimum luminance: then %0.3g; now %0.3g\n',minLumThen,minLumNow);

%% Get max lum using calibration routines
calThen = SetSensorColorSpace(calThen,T_xyz,S_xyz);
calNow = SetSensorColorSpace(calNow,T_xyz,S_xyz);
maxXYZThen1 = SettingsToSensor(calThen,[1 1 1]');
maxXYZThen2 = SettingsToSensorAcc(calThen,[1 1 1]');
maxXYZNow1 = SettingsToSensor(calNow,[1 1 1]');
maxXYZNow2 = SettingsToSensorAcc(calNow,[1 1 1]');
fprintf('Maximum luminance SettingsToSensor: then %0.3g; now %0.3g\n',maxXYZThen1(2),maxXYZNow1(2));
fprintf('Maximum luminance SettingsToSensorAcc: then %0.3g; now %0.3g\n',maxXYZThen2(2),maxXYZNow2(2));

%% Plot new and old white point and channel chromaticities
figure; clf; hold on
maxxyYThen = XYZToxyY(maxXYZThen1);
maxxyYNow = XYZToxyY(maxXYZNow1);
plot(maxxyYThen(1),maxxyYThen(2),'ro','MarkerFaceColor','r','MarkerSize',10);
plot(maxxyYNow(1),maxxyYNow(2),'go','MarkerFaceColor','g','MarkerSize',10);

redxyYThen = XYZToxyY(SettingsToSensor(calThen,[1 0 0]'));
greenxyYThen = XYZToxyY(SettingsToSensor(calThen,[0 1 0]'));
bluexyYThen = XYZToxyY(SettingsToSensor(calThen,[0 0 1]'));
redxyYNow = XYZToxyY(SettingsToSensor(calNow,[1 0 0]'));
greenxyYNow = XYZToxyY(SettingsToSensor(calNow,[0 1 0]'));
bluexyYNow = XYZToxyY(SettingsToSensor(calNow,[0 0 1]'));
plot(redxyYThen(1),redxyYThen(2),'ro','MarkerFaceColor','r','MarkerSize',10);
plot(redxyYNow(1),redxyYNow(2),'go','MarkerFaceColor','g','MarkerSize',10);
plot(greenxyYThen(1),greenxyYThen(2),'ro','MarkerFaceColor','r','MarkerSize',10);
plot(greenxyYNow(1),greenxyYNow(2),'go','MarkerFaceColor','g','MarkerSize',10);
plot(bluexyYThen(1),bluexyYThen(2),'ro','MarkerFaceColor','r','MarkerSize',10);
plot(bluexyYNow(1),bluexyYNow(2),'go','MarkerFaceColor','g','MarkerSize',10);
axis('square');
axis([0.0 0.8 0.0 0.8]);
xlabel('x chromaticity');
ylabel('y chromaticity');
