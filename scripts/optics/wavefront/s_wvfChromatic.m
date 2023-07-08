%% Create different diffraction limited cases
%
%  Different pointspreads as a function of wavelength
%  With human LCA and no LCA
%  Run on a grid lines image with and without LCA
%
% See also
%   s_wvfDiffraction, v_opticsFlare

%%
ieInit;

%% Multiple wavelengths

wList = 400:10:700;
wvf = wvfCreate('wave',wList);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3;
fNumber = 3; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

% Turn on LCA.  Compute.
wvf = wvfCompute(wvf,'human lca',true);
oi = wvf2oi(wvf);

%% Sample 4 pointspreads as images

wList = linspace(400,700,4);
ieNewGraphWin; colormap(gray);
for ii = 1:numel(wList)
    subplot(2,2,ii)
    wvfPlot(wvf,'image psf space','um',wList(ii),60,'airy disk',true,'no window');
    colormap(gray);
end

%% Check the OTF relationships between OI and WVF

% OTF from oi
oiOTF = oiGet(oi,'optics otf',700);
ieNewGraphWin; mesh(abs(oiOTF));

% OTF from wvf.  Needs the ifftshift
wvfOTF = wvfGet(wvf,'otf',700);
ieNewGraphWin; mesh(abs(wvfOTF));

% BW: This only works for ifftshift, not fftshift
wvfOTF = ifftshift(wvfOTF);
ieNewGraphWin; mesh(abs(wvfOTF));

ieNewGraphWin; loglog(abs(oiOTF(:)),abs(wvfOTF(:)),'.');
identityLine;

%% Show multiple point spreads as images

wList = wvfGet(wvf,'wave');

% Compute with LCA for all wavelengths
wvf = wvfCompute(wvf,'human lca',true);

ieNewGraphWin([],'upper left big');
nPanels = ceil(sqrt(numel(wList)));

for ii = 1:numel(wList)
    subplot(nPanels,nPanels,ii);
    wvfPlot(wvf,'image psf space','um',wList(ii),60,'airy disk','no window');    
    colormap(gray);

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(wList(ii),fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f AiryD %.2f',wList(ii),AD));
end

%% Run on an image

sceneGrid = sceneCreate('grid lines',384,64);
sceneGrid = sceneSet(sceneGrid,'fov',1);

oi = oiCompute(wvf,sceneGrid);
oi = oiSet(oi,'name','LCA on');
oiWindow(oi);

%% Now try it but compute with LCA turned off

wvf = wvfCompute(wvf,'human lca',false);
oi = oiCompute(wvf,sceneGrid);
oi = oiSet(oi,'name','LCA off');
oiWindow(oi);

%% END


