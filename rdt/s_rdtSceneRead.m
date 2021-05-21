%% s_rdtSceneRead
%
%  Reading scene data from the Archiva isetbio repository
%
% See also:  RdtClient, sceneFromBasis
% Copyright ImageVal Consulting 2015

%% You must have the RDT toolbox

if isempty(which('RdtClient'))
    fprintf('Remote data toolbox from the ISETBIO distribution is required\n');
    return;
end

%%
ieInit

%% Create the rdt object and open browser
rd = RdtClient('isetbio');

%% Our files are all version '1' at this point.

% Here is an example remote directory.
rd.crp('/resources/scenes/hyperspectral/stanford_database'); % change remote path

% rd.crp('/resources/scenes/hdr'); % change remote path

% Problems here:
% Currently only returns 30 elements
% 'type' is not right because it says jpg when there are nef and pgm files
% as well
a = rd.listArtifacts;

%% Preferred method - send in the whole artifact to readArtifacts (an an s)
data = rd.readArtifacts(a(2));
scene = sceneFromBasis(data{1});
ieAddObject(scene); sceneWindow;

%% Fetch a scene data artifact, specifying the data type as 'type'

sceneB = rd.readArtifact(a(2).artifactId);
scene = sceneFromBasis(sceneB);
ieAddObject(scene); sceneWindow;

%% Third example, when you know the id and that the type is .mat

rottenFruitB = rd.readArtifact('RottenFruit_Cx');
rottenFruit = sceneFromBasis(rottenFruitB);
ieAddObject(rottenFruit); sceneWindow;

%%
