% PTBcal = GeneratePTCalStructFromIsetbioDisplayObject(display)
%
% Generate a PTB calibration structure from an ISETBIO display object.
%
% 6/25/15  dhb  Modify to get display size out of ISETBIO object and use it.

function PTBcal = GeneratePTCalStructFromIsetbioDisplayObject(display)

% Start with a totally empty PTBcal
PTBcal = ptb.GenerateEmptyPTBcalStruct();

% Update key properties
PTBcal = updateDisplayDescription(PTBcal,display);
PTBcal = updateSpectralParams(PTBcal, display);
PTBcal = updateGammaParams(PTBcal, display);
end

function PTBcal = updateGammaParams(oldPTBcal, display)
[gammaTable, gammaInput] = retrieveGammaTable(display);


PTBcal = oldPTBcal;
PTBcal.gammaInput = gammaInput';
PTBcal.gammaTable = gammaTable;
PTBcal.nDevices = size(gammaTable,2);
end

function PTBcal = updateSpectralParams(oldPTBcal, display)

[wave, spd] = retrievePrimaries(display);
spectralSamples  = size(wave,1);

PTBcal = oldPTBcal;
PTBcal.describe.S   = WlsToS(wave);
PTBcal.S_ambient    = PTBcal.describe.S;
PTBcal.P_device     = spd;
PTBcal.P_ambient    = displayGet(display,'ambient spd');
PTBcal.T_ambient    = eye(spectralSamples);
PTBcal.T_device     = eye(spectralSamples);

end

function PTBcal = updateDisplayDescription(oldPTBcal,display)
dotsPerMeter = displayGet(display, 'dots per meter');
screenSizeMM = 1000.0*displayGet(display,'size');
screenSizePixels = round(screenSizeMM/1000*dotsPerMeter);

PTBcal = oldPTBcal;
PTBcal.describe.displayDescription.screenSizePixel = screenSizePixels;
PTBcal.describe.displayDescription.screenSizeMM = screenSizeMM;
end


function [gammaTable, gammaInput] = retrieveGammaTable(display)
% Gamma table, remove 4-th primary, if it exists
gammaTable = displayGet(display, 'gTable');
if (size(gammaTable,2) > 3)
    gammaTable = gammaTable(:,1:3);
end
gammaInput = linspace(0,1,size(gammaTable,1));
end

function [wave, spd] = retrievePrimaries(display)
% Remove 4-th primary, if it exists, for testing purposes.
wave = displayGet(display, 'wave');
spd  = displayGet(display, 'spd primaries');
if (size(spd ,2) > 3)
    spd = spd(:,1:3);
end
end


