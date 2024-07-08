%% Illustrate the split pixel sensor implementation
%
%

%%
ieInit;

%% Here is a high dynamic range test chart

% The parameters are set to match a small split pixel sensor below
scene = sceneCreate('hdr chart','cols per level',12,'n levels',8,'d range',10^5);
scene = sceneSet(scene,'fov',8); 

oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
% oiWindow(oi);

%% Make a sensor array that can see the whole range

% The sensor size is big enough to capture the whole chart
sensorArray = sensorCreateArray('splitpixel','exp time',0.1,'size',2*[64 96],'noise flag',0);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');

% This is the combined
sensorWindow(sA);
sensorPlot(sA,'volts hline',[1 48],'twolines',true);
set(gca,'yscale','log');

%% These are the individual sensors

for ii=1:numel(s); sensorWindow(s(ii)); end       

%%
ip = ipCreate; ip = ipCompute(ip,sA); ipWindow(ip);

%%  Show the map of how many sensors contribute to each pixel

ieNewGraphWin; 
mesh(sA.metadata.npixels); colormap(jet(4)); colorbar;
set(gca,'zlim',[1 4]);

%%
[sA,s]=sensorComputeArray(sensorArray,oi,'method','bestsnr');

% This is the combined
sensorWindow(sA);
sensorPlot(sA,'volts hline',[1 48],'twolines',true);
set(gca,'yscale','log');

%% END