function [overlap,numGrid,numGridSpot] = pvFullOverlap(OPTICS,PIXEL)
%
% This code is used to calculate the full overlap between the diode and
% the focused spot
%
% AUTHOR: Peter Catrysse, Brian Wandell, Ting Chen
% DATE: June 1999, 08/05/99, 03/27/2000 
% Setting up local variables
f = opticsGet(OPTICS,'focallength'); 	% Focal Length [m]
D = opticsGet(OPTICS,'diameter');       % Diameter [m]
w = pixelGet(PIXEL,'width');            % Diode size [m]
h = pixelGet(PIXEL,'depth');            % Distance from surface to diode [m]
d = D * (h / f);      		            % Spot size on chip surface
% Now for diode with index (m,n), one grid point with local 
% coordinate of (x,y) center at (mL, nL) will have a global 
% coordinate of (mL+x, nL+y)
% Now we set up the grid for the photodiode
% We choose an odd number of grid points in
% both dimensions to have a center pixel
numGrid = floor(51 * w/d);
% This number will play a role in determining the numGridSpot
% of the optical spot at the surface when focussed on the
% photodetector surface. The bigger the difference in size
% of this spot and the pixel diode size, the bigger numGrid
% has to be otherwise we are undersampling the optical spot.
% We deal with this by choosing numGrid such that numGridSpot = 51
if (numGrid/2 - round(numGrid/2)) == 0
        numGrid = numGrid+1;
end
%numGrid
diodeGrid= zeros(numGrid);
[x,y] = meshgrid(linspace(-w/2,w/2,numGrid),linspace(-w/2,w/2,numGrid));
diodeGrid(find((abs(x)<w/2)&(abs(y)<w/2))) = 1;
diodeGrid = diodeGrid / length(find((abs(x)<w/2)&(abs(y)<w/2)));
% Now we set up the grid for the focused spot. In order for the sampling steps
% to be of equal for both the photodiode grid and the spot grid, we need this:
numGridSpot = floor(d/(w/numGrid));
% This number has to be odd as well so that we can have a center pixel
if (numGridSpot/2 - round(numGridSpot/2)) == 0
        numGridSpot = numGridSpot+1;
end
%numGridSpot
spot = zeros(numGridSpot);
[x,y]=meshgrid(linspace(-d/2,d/2,numGridSpot),linspace(-d/2,d/2,numGridSpot));
spot(find(sqrt(x.^2+y.^2)<d/2)) = 1;
spot = spot / length(find(sqrt(x.^2+y.^2)<d/2));
% Full convolution of the photodiode and the focused spot
% This includes all the positions and angles
overlap = conv2(diodeGrid,spot);
return;