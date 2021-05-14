function displayObject = GenerateIsetbioDisplayObjectFromPTBCalStruct(displayName, calStruct, varargin)
% displayObject = generateIsetbioDisplayObjectFromCalStructObject(displayName, calStruct, varargin)
%
% Method to generate an isetbio display object with given specifications.
%
% NOTES:
%
% 2/20/2015    npc  Wrote skeleton script for xiamao ding
% 2/24/2015    xd   Updated to compute dpi, and set gamma and spds
% 2/26/2015    npc  Updated to employ SPD subsampling
% 3/1/2015     xd   Updated to take in optional S Vector
% 3/2/2015     xd   Updated to take in ExtraCalData struct
% 3/9/2015     xd   Updated S Vector behavior
% 4/15/2015    npc  Cleaned up a bit, subsample Svector is now a property of ExtraData
% 4/15/2015    npc  Added input arg, to control whether to save the generated isetbio display object
% 6/25/15      dhb  Set ISETBIO display size field

% Check is ExtraCalData
checkExtraData = @(x) isa(x, 'ptb.ExtraCalData');

% Input parser to check validity of inputs
input = inputParser;
addRequired(input, 'displayName', @ischar);
addRequired(input, 'calStruct', @isstruct);
addRequired(input, 'ExtraData', checkExtraData);
addRequired(input, 'saveDisplayObject', @islogical);
parse(input, displayName, calStruct, varargin{:});

% Assemble filename for generated display object
displayFileName = sprintf('%s.mat', displayName);

% Generate a display object
displayObject = displayCreate;

% Set the display's name to the input parameter displayName
displayObject = displaySet(displayObject, 'name', displayFileName);

% Get the wavelength sampling and channel spds, and ambient spd from the CalStruct
S = calStruct.describe.S;
spd = calStruct.P_device;
ambient = calStruct.P_ambient;

if (~isempty(input.Results.ExtraData.subSamplingSvector))
    % Validate that the subSamplingSvector is within range of the original S vector
    validateSVector(S, input.Results.ExtraData.subSamplingSvector);
    fprintf('Will subsample SPDs with a resolution of %d nm\n', input.Results.ExtraData.subSamplingSvector(2));
    
    % SubSample the SPDs
    newS = input.Results.ExtraData.subSamplingSvector;
    lowPassSigmaInNanometers = 4;
    showFig = false;
    [subSampledWave, subSampledSPDs] = ptb.SubSampleSPDs(S, spd, newS, lowPassSigmaInNanometers, showFig);
    [~, subSampledAmbient] = ptb.SubSampleSPDs(S, ambient, newS, lowPassSigmaInNanometers,  showFig);
    
    % Set the display object's SPD to the subsampled versions
    displayObject = displaySet(displayObject, 'wave', subSampledWave);
    displayObject = displaySet(displayObject, 'spd', subSampledSPDs);
    displayObject = displaySet(displayObject, 'ambient spd', subSampledAmbient);
else
    fprintf('Will not subsample SPDs\n');
    % Set the display object's SPD to the original versions
    displayObject = displaySet(displayObject, 'wave', SToWls(S));
    displayObject = displaySet(displayObject, 'spd', spd);
    displayObject = displaySet(displayObject, 'ambient spd', ambient);
end

% Get the display's gamma table.
gammaTable = calStruct.gammaTable;
gammaLength = size(gammaTable,1);
displayObject = displaySet(displayObject, 'gTable', gammaTable);

% Get the display resolution in dots (pixels) per inch
m = calStruct.describe.displayDescription.screenSizeMM;
p = calStruct.describe.displayDescription.screenSizePixel;
m = m/25.4;
mdiag = sqrt(m(1)^2 + m(2)^2);
pdiag = sqrt(p(1)^2 + p(2)^2);
dpi = pdiag / mdiag;
displayObject = displaySet(displayObject, 'dpi', dpi);

% Set the display size
displayObject = displaySet(displayObject,'size',calStruct.describe.displayDescription.screenSizeMM/1000);

% Use the viewing distance obtained from the ExtraData Struct
dist = input.Results.ExtraData.distance;
displayObject = displaySet(displayObject, 'viewing distance', dist);

if (input.Results.saveDisplayObject)
    % Save display object to file
    fprintf('Saving new display object (''%s'').\n', displayName);
    d = displayObject;
    save(displayFileName, 'd');
end

end

function validateSVector(oldS, newS)
% Check that newS fits S vector parameters
SVecAttribute = {'size', [1,3]};
SVecClass = {'double'};
validateattributes(newS, SVecClass, SVecAttribute)

% Check that newS is within range of oldS
newWave = SToWls(newS);
oldWave = SToWls(oldS);
if newS(1) < oldS(1)
    error('S Vector starts at lower nm than original');
elseif newWave(end) > oldWave(end)
    error('S Vector ends at higher nm than original');
end
end