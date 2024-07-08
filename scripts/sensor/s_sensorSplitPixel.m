%% Illustrate the split pixel sensor implementation
%
% Notice that the 'best snr' case, in fact, has better snr.  The
% average combines sensors with very noisy pixels.
%
% I commented out the various ISET window displays and just show some
% graphs and images.  It may be useful, if you are running by hand, to
% show the sensorWindow and ipWindow.
%
% TODO:  
%   * Quantization calculations are needed, based on the high and
%     low conversion gain.
%   * Methods for creating different types of sensor arrays, not just
%     the OVT model.
%
% See also
%   sensorCreateArray, sensorComputeArray, sensorCreateSplitPixel

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
sensorArray = sensorCreateArray('splitpixel','exp time',0.1,'size',2*[64 96],'noise flag',1);
[sA,s]      = sensorComputeArray(sensorArray,oi,'method','average');

% This is the combined
% sensorWindow(sA);
sensorPlot(sA,'volts hline',[1 48],'twolines',true);
set(gca,'yscale','log');

%% These are the individual sensors

% for ii=1:numel(s); sensorWindow(s(ii)); end      
ieNewGraphWin; tiledlayout(2,2);
for ii=1:numel(s)
    nexttile;
    imagesc(sensorGet(s(ii),'rgb'));
end

%%
ip = ipCreate; 
ip = ipCompute(ip,sA);
rgb = ipGet(ip,'srgb');
ieNewGraphWin; imagesc(rgb);  title('Average')
% ipWindow(ip);

%%  Show the map of how many sensors contribute to each pixel

ieNewGraphWin; 
mesh(sA.metadata.npixels); colormap(jet(4)); colorbar;
set(gca,'zlim',[1 4]);

%%
sA=sensorComputeArray(sensorArray,oi,'method','bestsnr');

% This is the combined
% sensorWindow(sA);
sensorPlot(sA,'volts hline',[1 48],'twolines',true);
set(gca,'yscale','log');

%%
ip = ipCompute(ip,sA); 
rgb = ipGet(ip,'srgb');
ieNewGraphWin; imagesc(rgb); title('Best SNR')
% ipWindow(ip);

%% Now with only two pixels, no extra conversion gain

clear sensorArray;
tmp = sensorCreateArray('splitpixel','exp time',0.1,'size',2*[64 96],'noise flag',1);
sensorArray(1) = tmp(1);
sensorArray(2) = tmp(3);
[sA,s] = sensorComputeArray(sensorArray,oi,'method','bestsnr');
sensorWindow(sA);
for ii=1:numel(s); sensorWindow(s(ii)); end

%% Average methods
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');
sensorWindow(sA);
for ii=1:numel(s); sensorWindow(s(ii)); end

%% END