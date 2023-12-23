%% s_focusLensTable
%
% This should become obsolete, and we should use lensFocus() on the fly.
% The FL files are still here for now, but they should go away.
%
% For each 'json'-lens file, make a look-up table from dist (in mm) to
% focal length (mm). Whenever we use a particular file, and we have a
% distance from the camera to the 'lookat' value in the PBRT file, we use
% this table to find the in-focus film distance.  Though sometimes, we just
% use
%
%     lensFocus(theLens,theDistance)
%
% We build the whole table, T, that has the different *.dat files in the
% data/lens directory as the rows and the distance to object as the
% columns. The entries are the focalDistance (all distances are
% millimeters, mm).
%
%   T(whichLens,dist) = focalDistance
%
% When the values are negative, we set the entry to NaN.
%
% We plot the focal distance vs. the object distance.  
%
% Finally, we write out file (lensFile.FL.mat) that contains the values
% 'dist' and focalDistance as parameters that can be used to interpolate
% for any distance in a scene.
%
%   focalLength = load(fullfile(p,[flname,'.FL.mat']));
%   focalDistance = interp1(focalLength.dist,focalLength.focalDistance,objDist);
%
% BW SCIEN Stanford, 2017
%
% See also
%   lensC.plot('focal distance')

% Examples:
%{
    % ETTBSkip
    % DHB: This is broken because we don't have piRootPath.  But the header
    % comment says the whole thing is obsolete, so I'm not going to try
    % to fix, and instead avoid autocheck with ETTBSkip.
    %
    % For a single lens file, rather than all the files in the directory, do
    % this 
    fullFile = fullfile(piRootPath,'data','lens','microlens.json');
    [p,n,~] = fileparts(fullFile);
    flFile = fullfile(piRootPath,'data','lens',[n,'.FL.mat']);
    thisLens = lensC('filename',fullFile);
    dist = logspace(0.1,4,30);
    for jj=1:numel(dist)
        focalDistance(jj) = lensFocus(thisLens,dist(jj));
    end
    save(flFile,'dist','focalDistance');
%}

%%  All the lenses in the pbrt2ISET directory

lensDir = piGetDir('lens');

% wide, tessar, fisheye, dgauss, telephoto, 2el, 2EL
lensFiles = dir(fullfile(lensDir,'*.json'));   

dist = logspace(0.1,4,30);

%% Calculate the focal distances

focalDistance = zeros(length(lensFiles),length(dist));

for ii=1:length(lensFiles)
    fname = fullfile(lensDir,lensFiles(ii).name);
    thisLens = lensC('filename',fname);
    for jj=1:length(dist)
        focalDistance(ii,jj) = lensFocus(thisLens,dist(jj));
    end
end

%%  When the distance is too small, we can't get a good focus.

% In that case, the distance is negative
vcNewGraphWin;
focalDistance(focalDistance < 0) = NaN;
loglog(dist,focalDistance');
xlabel('Object distance (mm)'); ylabel('Focal length (mm)');
grid on

%%  Write out the focalLength data for each of the lens files

allFocalDistances = focalDistance;
for ii=1:length(lensFiles)
    [p,n,~] = fileparts(lensFiles(ii).name);
    flFile = fullfile(lensDir,[n,'.FL.mat']);
    focalDistance = allFocalDistances(ii,:);
    save(flFile,'dist','focalDistance');
end

%%