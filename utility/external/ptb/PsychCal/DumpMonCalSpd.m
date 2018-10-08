% DumpMonCalSpd
%
% This program reads a standard calibration file and
% reports what is in it.
%
% Assumes exactly three primaries.  There
% may be rare cases where this is not the case, in which case
% you need to look at the calibration data by hand.
%
% This version assumes that the calibration file contains
% measured spectral data.  It needs to be made more generic
% so that it can handle tristimulus and luminance calibrations.
%
% 8/22/97  dhb  Wrote it.
% 2/25/98  dhb  Postpend Spd to the name.
% 8/20/00  dhb  Change name to dump.
% 3/1/02   dhb  Arbitrary file names.
% 5/1/02   dhb  Add DUMPALL flag.
% 9/26/08  dhb, ijk, tyl  Made output easier to read.  Only access named files.
%               Assume three primaries.
% 5/27/11  dhb  Update name of default monitor calibration.

% Initialize
clear; close all;

% Flags
DUMPALL = 1;

% Enter load code
defaultFileName = 'PTB3TestCal';
thePrompt = sprintf('Enter calibration filename [%s]: ',defaultFileName);
newFileName = input(thePrompt,'s');
if (isempty(newFileName))
    newFileName = defaultFileName;
end
fprintf(1,'\nLoading from %s.mat\n',newFileName);
cal_CT = LoadCalFile(newFileName);
fprintf('Calibration file %s read\n\n',newFileName);

% Print out some information from the calibration.
DescribeMonCal(cal_CT);

% Provide information about gamma measurements
% This is probably not method-independent.
fprintf('Gamma measurements were made at %g levels\n',...
    size(cal_CT.rawdata.rawGammaInput,1));
fprintf('Gamma table available at %g levels\n',...
    size(cal_CT.gammaInput,1));

% Put up a plot of the essential data.
figure(1); clf; hold on
plot(SToWls(cal_CT.S_device),cal_CT.P_device(:,1),'r');
plot(SToWls(cal_CT.S_device),cal_CT.P_device(:,2),'g');
plot(SToWls(cal_CT.S_device),cal_CT.P_device(:,3),'b');
xlabel('Wavelength (nm)', 'Fontweight', 'bold');
ylabel('Power', 'Fontweight', 'bold');
title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
axis([380,780,-Inf,Inf]);

% Gamma
figure(2);
if (size(cal_CT.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,1);
end
hold on
plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,1),'r+');
plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,2),'g+');
plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,3),'b+');
xlabel('Input value', 'Fontweight', 'bold');
ylabel('Normalized output', 'Fontweight', 'bold');
title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
hold on
plot(cal_CT.gammaInput,cal_CT.gammaTable(:,1),'r');
plot(cal_CT.gammaInput,cal_CT.gammaTable(:,2),'g');
plot(cal_CT.gammaInput,cal_CT.gammaTable(:,3),'b');
hold off
if (size(cal_CT.rawdata.rawGammaTable,2) > 3)
    subplot(1,2,2); hold on
    plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,4),'r+');
    plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,5),'g+');
    plot(cal_CT.rawdata.rawGammaInput,cal_CT.rawdata.rawGammaTable(:,6),'b+');
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    hold on
    plot(cal_CT.gammaInput,cal_CT.gammaTable(:,4),'r');
    plot(cal_CT.gammaInput,cal_CT.gammaTable(:,5),'g');
    plot(cal_CT.gammaInput,cal_CT.gammaTable(:,6),'b');
end
drawnow;

% Plot full spectral data for each phosphor
if (DUMPALL)
	figure(2+cal_CT.nDevices+1); clf; hold on
	load T_xyz1931
	nDontPlotLowPower = 3;
	T_xyz1931 = SplineCmf(S_xyz1931,683*T_xyz1931,cal_CT.describe.S);
	
	for j = 1:cal_CT.nDevices
		% Get channel measurements into columns of a matrix from raw data in calibration file.
        tempMon = reshape(cal_CT.rawdata.mon(:,j),cal_CT.describe.S(3),cal_CT.describe.nMeas);
		
		% Scale each measurement to the maximum spectrum to allow us to compare shapes visually.
		maxSpectrum = tempMon(:,end);
		scaledMon = tempMon;
		for i = 1:cal_CT.describe.nMeas
			scaledMon(:,i) = scaledMon(:,i)*(scaledMon(:,i)\maxSpectrum);
		end
		
		% Compute phosphor chromaticities
		xyYMon = XYZToxyY(T_xyz1931*tempMon);
        
        % Dump out min and max luminance
        minLum = min(xyYMon(3,:));
        maxLum = max(xyYMon(3,:));
        fprintf('Primary %d, max luminance %0.2f cd/m2, min %0.2f cd/m2\n',j,maxLum,minLum);
		
		% Plot raw spectra
		figure(2+j); clf
        subplot(1,2,1);
		plot(SToWls(cal_CT.S_device),tempMon);
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Power', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
		
		% Plot scaled spectra
		subplot(1,2,2);
		plot(SToWls(cal_CT.S_device),scaledMon(:,nDontPlotLowPower+1:end));
        xlabel('Wavelength (nm)', 'Fontweight', 'bold');
        ylabel('Normalized Power', 'Fontweight', 'bold');
        axis([380,780,-Inf,Inf]);
		drawnow;
        
        % Keep singular values
        monSVs(:,i) = svd(tempMon);
		
		% Plot chromaticities
		figure(2+cal_CT.nDevices+1); hold on
		plot(xyYMon(1,nDontPlotLowPower+1:end)',xyYMon(2,nDontPlotLowPower+1:end)','+');

	end
end

% Plot chromaticities
figure(2+cal_CT.nDevices+1); hold on
plot(xyYMon(1,nDontPlotLowPower+1:end)',xyYMon(2,nDontPlotLowPower+1:end)','+');
axis([0.0 1 0 1]); axis('square');
xlabel('x chromaticity');
ylabel('y chromaticity');

return


