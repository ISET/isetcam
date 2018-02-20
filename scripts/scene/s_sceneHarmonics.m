%% Creating scenes with spatial frequency (harmonic) patterns
%
% Scenes comprising *harmonic patterns and sums of harmonics* are
% frequently used to evaluate image systems.  *sceneCreate*
% generates these patterns. 
%
% The parameters set the frequency, contrast, phase, angle, row
% and col size of the harmonic. The frequency is cycles/image, so
% if you know the horizontal field of view, just divide to obtain
% cycles per degree.
%
% See also:  sceneCreate
%
% Copyright: ImagEval Consulting 2011

%%
ieInit

%% The harmonic parameters

params.freq = 1;
params.contrast = 1;
params.ph = 0;
params.ang= 0; params.row = 128;
params.col = 128;
params.GaborFlag=0;

% The basic call to sceneCreate with the params is
[scene,params] = sceneCreate('harmonic',params);
ieAddObject(scene); sceneWindow;

%% The sum of two (or more) harmonics

% Set the slots for freq, contrast, ang, and ph to vectors of the
% same length to define the multiple harmonics.
    
params.freq =  [1 5];         % spatial frequencies of 1 and 5
params.contrast = [0.2, 0.6]; % contrast of the two frequencies
params.ang  = [0, 0];         % orientations
params.ph  = [0 pi/3];        % phases

TwoFreq = sceneCreate('harmonic',params);
ieAddObject(TwoFreq); sceneWindow;

%% Vary the orientation of the two harmonics

params.freq =  [2 5];         % spatial frequencies of 1 and 5
params.contrast = [0.6, 0.6]; % contrast of the two frequencies
params.ang  = [pi/4, -pi/4];  % orientations
params.ph  = [0 0];           % phase

TwoFreq = sceneCreate('harmonic',params);
ieAddObject(TwoFreq); sceneWindow;

%%  another example

params.freq =  [5 5]; % spatial frequencies of 1 and 5
params.contrast = [0.6, 0.6]; % contrast of the two frequencies
params.ang  = [pi/4, -pi/4]; % orientations
params.ph  = [0 0]; % phase

TwoFreq = sceneCreate('harmonic',params);
ieAddObject(TwoFreq); sceneWindow;

%%