%% s_rdtSummary
%
% Check on the SCIEN and ISETBIO Archiva repositories
%
% BW ISETBIO Team, Copyright 2016

%%
ieInit

%% Summarize SCIEN

rdt = RdtClient('scien');
%
artifacts = rdt.listArtifacts;
rPaths = rdt.listRemotePaths;
fprintf('SCIEN repository contains\n %d artifacts in %d remote paths\n', length(artifacts), length(rPaths));

%% Summarize ISETBIO
rdt = RdtClient('isetbio');
artifacts = rdt.listArtifacts;
rPaths = rdt.listRemotePaths;
fprintf('ISETBIO repository contains\n %d artifacts in %d remote paths\n', length(artifacts), length(rPaths));

%%  Get one artifact from the isetbio repository

% There is a scene6 artifact that is a matlab file.  This is
% 'City view. Spatial and illuminant data available. Scene was recorded in
% the Picoto area, Braga, Minho reg?'
testA = rdt.searchArtifacts('scene6');
rdt.crp(testA.remotePath);
data = rdt.readArtifact(testA.artifactId);

% this also works because we supply an explicit remote path
data = rdt.readArtifact(testA.artifactId, ...
    'remotePath', testA.remotePath);

% this also works because we supply the whole artifact metadata struct
% NOTE: readArtifacts *with an s* also works with metadata struct *arrays*
% such as returned from searchArtifacts or listArtifacts
dataCell = rdt.readArtifacts(testA);
data = dataCell{1};

ieAddObject(data.scene);
sceneWindow;

%% Download via the URL works
tmp = [tempname, '.mat'];
try % websave version for modern Matlab
    websave(tmp, testA.url);
    load(tmp, 'scene');
    ieAddObject(scene);
    sceneWindow;
catch
    urlwrite(testA.url, tmp);
    load(tmp, 'scene');
    ieAddObject(scene);
    sceneWindow;
end
delete(tmp);

%% Finding all the artifacts in a specific section

% These are files from the Nikon (NEF) and PGM and JPG used by L3
rdt = RdtClient('scien');
rdt.crp('/L3/Farrell/D200/garden');
artifacts = rdt.listArtifacts;
fprintf('%d artifacts returned from L3/Farrell/D200/garden \n', length(artifacts));
rdt.openBrowser

%%