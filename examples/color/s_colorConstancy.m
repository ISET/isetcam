%% Stuffed animals scene under different blackbody illuminants
%
% Used this for a class demo of color constancy
%
% See also
%

ieInit;
chdir(fullfile(isetRootPath,'local'));

scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','spectral');
wave = sceneGet(scene,'wave');

% cTemps = 2500:500:8500;
cTemps = linspace(1/7000,1/3000,15);
cTemps = fliplr(1./cTemps);

rgb = cell(numel(cTemps),11);
hdl = ieNewGraphWin;
for ii=1:numel(cTemps)
    bb = blackbody(wave,cTemps(ii),'energy');
    scene = sceneAdjustIlluminant(scene,bb);
    % sceneWindow(scene);
    rgb{ii} = sceneGet(scene,'rgb');
    imagesc(rgb{ii}); axis image; axis off
    if ii==1, exportgraphics(gcf,'colorConstancy.gif');
    else 
        for jj=1:10, exportgraphics(gcf,'colorConstancy.gif','Append',true); end
    end    
end

close(hdl);

%% Not all that useful, but there it is

scene = sceneCreate('uniformD65',512);
wave = sceneGet(scene,'wave');

% cTemps = 2500:500:8500;
cTemps = linspace(1/7000,1/3000,15);
cTemps = fliplr(1./cTemps);

rgb = cell(numel(cTemps),11);
hdl = ieNewGraphWin;
for ii=1:numel(cTemps)
    bb = blackbody(wave,cTemps(ii),'energy');
    scene = sceneAdjustIlluminant(scene,bb);
    % sceneWindow(scene);
    rgb{ii} = sceneGet(scene,'rgb');
    imagesc(rgb{ii}); axis image; axis off
    if ii==1, exportgraphics(gcf,'uniformColor.gif');
    else 
        for jj=1:10, exportgraphics(gcf,'uniformColor.gif','Append',true); end
    end    
end

%% END
