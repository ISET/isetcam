%% Illustrate the split pixel sensor implementation
%
% The split pixel design includes two photosites within a single
% pixel.  One has a much higher sensitivity than the other.  In some
% cases, there are multiple readouts from each pixel with different
% conversion gains.  See the notes in sensorCreateSplitPixel for more
% background information.  Ultimately, there will be a class tutorial
% about this design.
%
% This script illustrates how to run the split pixel simulation.  For
% the moment, we only have an implementation of something like the
% Omnivision pixel. We will implement more features over time
% (07.08.2024).
%
% For the computation of an image from the multiple pixels, we have
% two methods.  One provides a value corresponding to the 'average'
% estimate at each pixel from all the sensors.  The other provides a
% value from just the sensor with the 'best snr'.
%
% When you run the simulation, notice that the 'best snr' case, in
% fact, has better snr for the brighter regions. The average combines
% sensors with very noisy pixels, which degrades.  But for the dark
% pixels, where there is very little signal altogether, the average
% may be a bit better.  Hard to say just now.s
%
% Programming Notes:
%  I commented out the various ISET window displays and just show some
%  graphs and images.  It may be useful, if you are running by hand, to
%  show the sensorWindow and ipWindow.
%
% TODO:  
%   * Quantization calculations are needed, based on the high and
%     low conversion gain.
%   * Methods for creating different types of sensor arrays, not just
%     the OVT model.  The Sony IMX490 is halfway implemented.
%   * It is possible to run by combining with just 2 or 3 sensors.
%   * Remember that there are various sceneCreate('hdr *') types
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

%% Now try with a general HDR scene

scene = sceneCreate('hdr image');
scene = sceneSet(scene,'fov',8); 

oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);

sensorArray = sensorCreateArray('splitpixel','exp time',0.05,'size',2*[64 96],'noise flag',1);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');
sensorWindow(sA); sensorSet(sA,'gamma',0.3);

ip = ipCreate; ip = ipCompute(ip,sA); 
ipWindow(ip); ip = ipSet(ip,'gamma',0.3);

%% END