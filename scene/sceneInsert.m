function scene = sceneInsert(scene1,scene2,position)
% Insert the 2nd scene into the first
%
% Synopsis
%   scene = sceneInsert(scene1,scene2,position)
%
% Brief description
%   The first scene should be larger and have the same wavelength
%   samples as the second scene.  The position parameter defines the
%   upper left (row,col) where we insert the second scene.
%   
% Input
%   scene1 - Main scene
%   scene2 - Inserted scene
%
% Return
%   scene - The scene with the insertion
%
% ieExamplesPrint('sceneInsert');
%
% See also
%   sceneAdd, sceneCombine

% Examples:
%{
scene1 = sceneCreate('sweep frequency',256);
scene2 = sceneCreate;
scene = sceneInsert(scene1,scene2,[64 10]);
sceneWindow(scene);
%}
%{
 scene1 = sceneCreate('sweep frequency',256);
 chartP = chartParams;
 scene2 = sceneCreate('reflectance chart',chartP);
 scene2 = sceneSet(scene2,'resize',[32 96]);
 scene = sceneInsert(scene1,scene2,[64 32]);
 sceneWindow(scene);
%}

arguments
    scene1 struct
    scene2 struct
    position (1,:) {mustBeNumeric}
end

%%  Determine direction and merge

assert(isequal(sceneGet(scene1,'wave'),sceneGet(scene2,'wave')));

photons1 = sceneGet(scene1,'photons');
photons2 = sceneGet(scene2,'photons');
sz = sceneGet(scene2,'size');

% These are the rows and columns
rows = (1:sz(1)) + (position(1) - 1);
cols = (1:sz(2)) + (position(2) - 1);
photons1(rows,cols,:) = photons2(:,:,:);

scene =  sceneSet(scene1,'photons',photons1);

end

