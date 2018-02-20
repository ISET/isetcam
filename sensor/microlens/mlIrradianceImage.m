function mlIrradianceImage(ml,newWindow)
% Make an image of the microlens irradiance at the pixel
%
%   mlIrradianceImage(ml,[newWindow = true])
%
% ml:  Microlens structure
% newWindow:  Open a new graph window (default = true)
%
% 
% Copyright Imageval Consulting, LLC, 2015

%%
if ieNotDefined('newWindow'), newWindow = true; end
if newWindow, vcNewGraphWin; end

x = mlensGet(ml,'xcoordinate');

%% Make the plot
pIrrad = mlensGet(ml,'pixel irradiance');
pWidth = mlensGet(ml,'diameter','microns');

% Set lines closest to pixel width boundaries to white
[v,l] = min(abs(x - (pWidth/2))); %#ok<*ASGLU>
pIrrad(l,:) = 1;   pIrrad(:,l) = 1;
[v,l] = min(abs((-x) - pWidth/2));
pIrrad(l,:) = 1;   pIrrad(:,l) = 1;

% Here it is
imagesc(x,x,pIrrad); colormap('hot'); axis image

% Set up the axes
fontSize = 18;
xlabel('Position (um)','fontsize',fontSize)
title('Pixel efficiency (normalized)','fontsize',fontSize);

% Set up the color bar
b = colorbar('vert'); 
set(b,'ytick',(0:0.25:1));

end