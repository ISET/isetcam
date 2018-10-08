function [xGridMinutes,yGridMinutes] = SfGridCyclesDegToPositionGridMinutes(xSfGridCyclesDeg,ySfGridCyclesDeg)
%SfGridCyclesDegreeToPositionGridMinutes  Convert mesh sf coords to mesh position coords
%    [xGridMinutes,yGridMinutes] = SfGridCyclesDegToPositionGridMinutes(xSfGridCyclesDeg,ySfGridCyclesDeg)
%
% Convert passed x,y sf mesh grids in cycles/degree to corresponding
% position mesh grids in minutes.  Useful for psf/lsf/otf calculation.

%% Generate position grids
%
% Samples are evenly spaced and the same for both x and y (checked above).
% Handle even versus odd dimension properly for fft conventions.
[m,n] = size(xSfGridCyclesDeg);
if (m ~= n)
    error('Passed grids should be square');
end
centerPosition = floor(n/2) + 1;
spatialFrequencyXExtentCyclesDeg = xSfGridCyclesDeg(centerPosition,end)-xSfGridCyclesDeg(centerPosition,1);
spatialFrequencyYExtentCyclesDeg = ySfGridCyclesDeg(end,centerPosition)-ySfGridCyclesDeg(1,centerPosition);
if (spatialFrequencyXExtentCyclesDeg ~= spatialFrequencyYExtentCyclesDeg)
    error('Spatial frequency extent not matched in x and y');
end

spatialFrequencyExtentCyclesMinute = spatialFrequencyXExtentCyclesDeg/60;
if (rem(n,2) == 0)
    positionMinutes = (-n/2:n/2-1)/spatialFrequencyExtentCyclesMinute;
else
    positionMinutes = (-floor(n/2):floor(n/2))/spatialFrequencyExtentCyclesMinute;
end
[xGridMinutes,yGridMinutes] = meshgrid(positionMinutes,positionMinutes);