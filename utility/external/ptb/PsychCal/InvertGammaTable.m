function iGammaTable = InvertGammaTable(gammaInput,gammaTable,precision)
% iGammaTable = InvertGammaTable(gammaInput,gammaTable,precision)
%
% Build an inverse gamma table.
%
% 1/21/95	dhb	  Wrote it.
% 8/4/96    dhb   Update for stuff bag routines.
% 8/21/97   dhb   Update for structures.
% 11/21/06  dhb   Update for PTB-3.

% Allocate space for the inverse table
[nInputLevels,nDevices] = size(gammaTable);
iGammaTable = zeros(precision,nDevices);

% Set up actual output levels
outDelta = 1/precision;
outputLevels = 0:outDelta:1-outDelta;
searchValues = outputLevels+outDelta/2;
gamutValues = searchValues(ones(nDevices,1),:);

% Make the table
iGammaTable = GamutToSettingsSch(gammaInput,gammaTable,gamutValues)';
		
