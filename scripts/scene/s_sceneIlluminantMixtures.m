%% Combining multiple illuminants in a single scene
%
% Use the *spatial-spectral* illuminant feature to create a scene
% with two illuminants, one at the top and another at the bottom.
%
% ISET scenes represent the scene spectral radiance and the scene
% illuminant.  The spectral radiance is a hypercube of data, that
% is a spectral power distribution at each scene point.
%
% The scene illuminant can be a single spectral power
% distribution, in which case the illuminant is assumed to be the
% same (constant) across the entire scene.  
%
% Alternatively, the scene illuminant can also be a hypercube of
% the same size as the scene spectral radiance.  In that case,
% the illuminant, which we call spatial-spectral, is allowed to
% vary across the scene.
%
% See also: sceneAdjustIlluminant, imageMultiView,
%          illuminantCreate, s_sceneIlluminantSpace
%
% Copyight Imageval Consulting, LLC, 2011

%%
ieInit;

%% The mixture of two illuminants

s1 = sceneCreate('macbeth tungsten');
s1 = sceneIlluminantSS(s1);
illT = sceneGet(s1,'illuminant energy');

s2 = sceneCreate;
s2 = sceneIlluminantSS(s2);
illD65 = sceneGet(s2,'illuminant energy');


%% Make a spatially mixed illuminant
ill = illT;  % Start with tungsten everywhere

% Select the top half from the D65 illuminant
sz = sceneGet(s1,'size');
rows = round(1:(sz(1)/2));
cols = round(1:sz(2));
ill(rows,cols,:) = illD65(rows,cols,:);

% Put the new illuminant in place
s = sceneAdjustIlluminant(s1,ill);
s = sceneSet(s,'name','Mixed illuminant');

ieAddObject(s1);  % Tungsten
ieAddObject(s2);  % D65 
ieAddObject(s);   % Mixed
% sceneWindow;
imageMultiview('scene',1:3,true);

%%