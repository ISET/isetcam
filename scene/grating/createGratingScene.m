function [gratingScene] = createGratingScene(chromaticDir, spatialFrequency, varargin)
% Create a grating scene using sceGrating
%
% Syntax:
%   [gratingScene] = createGratingScene(chromaticDir, spatialFreqency)
%
% Description:
%    Create a @sceneEngine object representing a chromatic grating scene.  Key/value pairs
%    control parameters.
%
% Inputs:
%   chromaticDir      - Three dimensional vector giving L, M, and S
%                       contrasts for the grating at 100% contrast.
%   spatialFrequency  - Grating spatial frequency.
%
% Outputs:
%   gratingScene      - Created sceneEngine
%
% Optional key/value pairs:
%   'spatialPhase'      - The spatial phase of the stimulus, in degrees
%                         Default 0.
%   'orientation'       - The orientation of the stimulus, in degrees.
%                         Default 90 (vertical grating).
%   'duration'          - The duration of the stimulus, in seconds.
%                         Default: 0.1.
%   'presentationMode'  - Presentation mode, for now either 'flashed' (1
%                         frame), or 'sampled motion', (4 frames, with
%                         spatial phase advancing by 90 degs in each frame)
%
% See also: t_modulatedGratingsSceneGenerateion, t_spatialCSF
%

% History:
%   10/23/20  dhb  Added comments.
%   11/07/20  npc  Added 'presentationMode' key/value pair   
%   12/10/20  npc  Remove override of minPixelsNumPerCycle 

% Set up parameters with defaults
p = inputParser;
p.addParameter('meanLuminanceCdPerM2', 40, @isscalar);
p.addParameter('meanChromaticityXY', [0.3 0.32], @(x)(isnumeric(x) && numel(x) == 2));
p.addParameter('spatialPhase', 0, @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('spatialEnvelope', 'disk', @(x)(ischar(x) && ismember(x, {'disk', 'rect', 'soft','halfcos'})));
p.addParameter('orientation', 90, @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('duration', 0.1, @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('spatialPhaseAdvanceDegs', 45,  @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('temporalFrequencyHz', 1,  @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('presentationMode', 'flashed', @(x)(ischar(x) && ismember(x,{'flashed', 'drifted', 'counter phase modulated'})));
p.addParameter('pixelsNum', 128, @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('fovDegs', 1.0, @(x)(isnumeric(x) && numel(x) == 1));
p.addParameter('spatialEnvelopeRadiusDegs', 1.0, @(x)(isscalar(x)));
p.addParameter('minPixelsNumPerCycle', 10, @(x)(isscalar(x)));
p.addParameter('spectralSupport', 400:20:750, @isnumeric);
p.addParameter('warningInsteadOfErrorOnOutOfGamut', false, @islogical);
parse(p, varargin{:});

% Compute function handle for grating stimulispatialEnvelopeRadiusDegs = app.stimSizeDegs/2;
sceneComputeFunction = @sceGrating;

% Retrieve the default params for the grating stimulus
gratingParams = sceGrating();

gratingParams.coneContrastModulation = chromaticDir;
gratingParams.spatialFrequencyCyclesPerDeg = spatialFrequency;

% Configure those parameters that we adjust through key/value pairs.
% chromatic direction and and spatial frequency of the grating
% with a 90 deg orientation, and a cosine spatial phase
gratingParams.meanLuminanceCdPerM2 = p.Results.meanLuminanceCdPerM2;
gratingParams.meanChromaticityXY = p.Results.meanChromaticityXY;
gratingParams.spatialPhaseDegs = p.Results.spatialPhase;
gratingParams.spatialEnvelope = p.Results.spatialEnvelope;
gratingParams.orientationDegs = p.Results.orientation;
gratingParams.pixelsNum = p.Results.pixelsNum;
gratingParams.fovDegs = p.Results.fovDegs;
gratingParams.spatialEnvelopeRadiusDegs = p.Results.spatialEnvelopeRadiusDegs;
gratingParams.minPixelsNumPerCycle = p.Results.minPixelsNumPerCycle;
gratingParams.spectralSupport = p.Results.spectralSupport;
gratingParams.warningInsteadOfErrorOnOutOfGamut = p.Results.warningInsteadOfErrorOnOutOfGamut;

% Set pixel size
pixelsNum = p.Results.pixelsNum;
if(pixelsNum >= 1)
    gratingParams.pixelsNum = pixelsNum;
end

% Configure temporal modulation:
switch (p.Results.presentationMode)
    case 'flashed'
        % Single frame presentation
        gratingParams.frameDurationSeconds = p.Results.duration;
        gratingParams.temporalModulation = 'flashed';
        gratingParams.temporalModulationParams =  struct(...
            'stimOnFrameIndices', 1, 'stimDurationFramesNum', 1);
        
    case 'drifted'
        gratingParams.temporalModulation = 'drifted';
        gratingParams.frameDurationSeconds = 1.0/(p.Results.temporalFrequencyHz*360/p.Results.spatialPhaseAdvanceDegs);
        gratingParams.temporalModulationParams =  struct(...
            'temporalFrequencyHz', p.Results.temporalFrequencyHz, ...
            'stimDurationTemporalCycles', p.Results.duration * p.Results.temporalFrequencyHz);
        
    case 'counter phase modulated'
        gratingParams.temporalModulation = 'counter phase modulated';
        gratingParams.frameDurationSeconds = 1.0/(p.Results.temporalFrequencyHz*360/p.Results.spatialPhaseAdvanceDegs);
        gratingParams.temporalModulationParams =  struct(...
            'temporalFrequencyHz', p.Results.temporalFrequencyHz, ...
            'stimDurationTemporalCycles', p.Results.duration * p.Results.temporalFrequencyHz);
        
    otherwise
        error('Unknown presentationMode: ''%s''.', p.Results.presentationMode);
        
end

% Instantiate a sceneEngine with the above sceneComputeFunctionHandle
% and the custom grating params.
gratingScene = sceneEngine(sceneComputeFunction, gratingParams);

end