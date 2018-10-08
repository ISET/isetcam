function calData = CVIAdjustCalData(calData,cviData)
% calData = CVIAdjustCalData(calData,cviData)
%
% Use the fine spectral measurements taken with
% the CVI (see CVIMeasurePhosphors) to adjust
% the coarse spectral measurements taken with
% the PR-650.  Actually, nothing about the
% method is particularly specific to the CVI
% and PR-650 devices, but the names in the
% structures are coded that way.
%
% 1/02/01  dhb, mpr  Wrote it.

% Make sure calData and PR-650 portion
% of cviData have same wavelength spacing.
if (CheckWls(calData.S_device,cviData.pr650.S))
	error('Wavelength sampling mismatch for PR-650 measurements.');
end

% For each phosphor, find scale factor between calibration (calData)
% and reference (cviData) measurements.  Create new spectral data
% by scaling cvi reference measurement by the scale factor.
tempS = cviData.use.S;
temp = cviData.use.spectra;
for i = 1:3
	factor(i) = cviData.pr650.spectra(:,i)\calData.P_device(:,i);
	temp(:,i) = factor(i)*temp(:,i);	
end

% Patch up calibration data
calData.S_device = tempS;
calData.P_device = temp;
calData.T_device = eye(tempS(3));

% Spline ambient to match new wavelength spacing.  Could
% model the ambient as sum of three phosphors and recreate
% a finer version, but that would be a third order correction
% and could go wrong in cases where the ambient also had
% a contribution not from the monitor phosphors.
calData.P_ambient = ...
	SplineSpd(calData.S_ambient,calData.P_ambient,tempS);
calData.S_ambient = tempS;
calData.T_ambient = eye(tempS(3));
