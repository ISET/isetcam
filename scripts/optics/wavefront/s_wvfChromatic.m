%% Create different diffraction limited cases
%
% Include human LCA and not
% Different pupil sizes
%
% See also
%  oiGet(oi,'optics psf data')
%  oiGet(oi,'optics psf xaxis')
%  oiPlot() ...

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
wvf = wvfComputePSF(wvf,'lca',true,'force',true);
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

ieNewGraphWin; plot(oiOTF(:),wvfOTF(:),'.');
identityLine;

%% Show multiple point spreads as images

wList = wvfGet(wvf,'wave');

% Compute with LCA for all wavelengths
wvf = wvfComputePSF(wvf,'lca',true,'force',true);

ieNewGraphWin([],'upper left big');
nPanels = ceil(sqrt(numel(wList)));

for ii = 1:numel(wList)
    subplot(nPanels,nPanels,ii);
    wvfPlot(wvf,'image psf space','um',wList(ii),60,'airy disk','no window');    
    colormap(gray);

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(ww,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f AiryD %.2f',wList(ii),AD));
end

%% Run on an image

sceneGrid = sceneCreate('grid lines',384,64);
sceneGrid = sceneSet(sceneGrid,'fov',1);

oi = oiCompute(wvf,sceneGrid);
oiWindow(oi);

%% Now try it but compute with LCA turned off

wvf = wvfComputePSF(wvf,'lca',false,'force',true);
oi = oiCompute(wvf,sceneGrid);
oiWindow(oi);

%% END


