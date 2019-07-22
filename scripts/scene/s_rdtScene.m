%% Illustrate ISET scenes
%
% ISET can generate many test scenes to evaluate color, resolution and
% noise. In addition, we use a Cloud site to store some interesting data
% that are pubicly available.  
%
% This script illustrates example scenes.
%
% In addition to ISET, to run this script, you must have the RemoteData
% Toolbox on your path.
%
%   Installation: https://github.com/isetbio/RemoteDataToolbox
%   Wiki:         https://github.com/isetbio/RemoteDataToolbox/wiki
%
% Copyright Imageval Consulting, LLC, 2016

%%  Start fresh and open a channel
ieInit;

%% Performance charts

% Spatial charts
scene = sceneCreate('freq orient');
ieAddObject(scene); sceneWindow;

scene = sceneCreate('slanted bar');
ieAddObject(scene); sceneWindow;

% A standard color chart
scene = sceneCreate('macbeth d65');
ieAddObject(scene); sceneWindow;

% A better reflectance chart 
scene = sceneCreate('reflectance chart');
ieAddObject(scene); sceneWindow;

%%  We have also stored natural image spectral radiance data

% A large set is stored as part of the ISETBIO project
rd = RdtClient('isetbio');
rd.crp ('/resources/scenes/hyperspectral/manchester_database/2004');
a = rd.listArtifacts('print',true,'type','mat');

%% Download an example from the hyperspectral database
data = rd.readArtifact(a(1));  

% These are stored using a linear model.  So we convert from the linear
% basis to the scene spectral radiance
scene = sceneFromBasis(data);
ieAddObject(scene); sceneWindow;

%% We have spectral data for faces

rd.crp ('/resources/scenes/multiband/scien/2008');
rd.listArtifacts('print',true,'type','mat');

data = rd.readArtifact('CaucasianAsianAfricanAmerican');  
face = sceneFromBasis(data);
ieAddObject(face); 
sceneSet(face,'gamma',0.8);
% sceneWindow;

%% We also have synthetic, computer graphics scenes with 3D information

% Open a channel to the remote data archive that SCIEN uses
clear rd;
rd = RdtClient('scien');

% Change to the directory that contains the images remotely
rd.crp('/sceneoidata');

% Show what we have
a = rd.listArtifacts('print',true);

%% Load the HDR bench scene and display

% This scene was produced using a graphics rendering program
data = rd.readArtifact(a(1));
scene = data.scene;

sceneWindow(scene); 
scene = sceneSet(scene,'gamma',0.5);

% A nice property of the synthetic scenes is that we have ground truth
% depth maps for them.
scenePlot(scene,'depth map');


%%
