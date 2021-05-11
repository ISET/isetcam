%% Test an RDT scene download
%
% The remote data toolbox is required.
%
% Copyright Imageval Consulting, LLC, 2016

%%
rd = RdtClient('isetbio');

% We did the correction for the 2004, 2008 and 2009 data sets
rd.crp('/resources/scenes/multiband/scien/2004');

%% List the scenes
sList = rd.listArtifacts('printID', true);

%% Download, convert, and show one
ii = 8;
data  = rd.readArtifact(sList(ii).artifactId);
scene = sceneFromBasis(data);
ieAddObject(scene);
sceneWindow;

%%