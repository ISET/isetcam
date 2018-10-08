function [xSfGridCyclesDeg,ySfGridCyclesDeg] = PositionGridMinutesToSfGridCyclesDeg(xGridMinutes,yGridMinutes)
%PositionGridMinutesToSfGridCyclesDeg  Convert mesh sf coords to mesh position coords
%    xSfGridCyclesDeg,ySfGridCyclesDeg] = PositionGridMinutesToSfGridCyclesDeg(xGridMinutes,yGridMinutes)
%
% Convert passed x,y position mesh grids in minutes to corresponding
% sf mesh grids in cycles/degree.  Useful for psf/lsf/otf calculation


%% Generate spatial frequency grids
%
% Samples are evenly spaced and the same for both x and y (checked above).
% Handle even versus odd dimension properly for fft conventions.
[m,n] = size(xGridMinutes);
if (m ~= n)
    error('Passed grids should be square');
end
centerPosition = floor(n/2) + 1;
spatialXExtentMinutes = xGridMinutes(centerPosition,end)-xGridMinutes(centerPosition,1);
spatialYExtentMinutes = yGridMinutes(end,centerPosition)-yGridMinutes(1,centerPosition);
if (spatialXExtentMinutes ~= spatialYExtentMinutes)
    error('Spatial frequency extent not matched in x and y');
end
if (rem(n,2) == 0)
    sfCyclesDeg = 60*(-n/2:n/2-1)/spatialXExtentMinutes;
else
    sfCyclesDeg = 60*(-floor(n/2):floor(n/2))/spatialXExtentMinutes;
end
[xSfGridCyclesDeg,ySfGridCyclesDeg] = meshgrid(sfCyclesDeg,sfCyclesDeg);