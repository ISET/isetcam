function [support, spread, delta] = conePlot(xy,coneType, support, spread, delta)
% Plot an image of the cone mosaic
%
%    [support, spread, delta] = conePlot(xy,coneType, [support], [spread], [delta])
%
% xy:        Cone positions (um)
% coneTYpe:  an integer from 1:4 where 1 means no cone (K), 2:4 are L,M,S
% support, spread, delta are gaussian blurring parameters for creating the
% image
%
% These images can be compared with the ones measured by Hofer et al. in
% the J. Neuroscience paper and then published by Williams in a JOV paper.  
% I downloaded those from
%   http://www.journalofvision.org/5/5/5/article.aspx#tab1
%
% Those data and the plotting routine for them are in the repository under
% cone/data/williams.
%
% See also:  sensorConePlot, humanConeMosaic
%
% Example:
%  [sensor, xy, coneType] = sensorCreateConeMosaic;
%  conePlot(xy,coneType);
%
% Copyright ImagEval LLLC, 2009

if ieNotDefined('delta'),   delta = 0.4; end  % Sampling in microns
% support and spread are adjusted below, after the grid is built

% low = floor(min(xy(1,:))); high = ceil(max(xy(1,:)));
fgrid = ffndgrid(xy,coneType,delta);
fgrid = full(fgrid);

% Find the positions in the cfa of the empty (K) and three cone types
K = find(fgrid == 1); L = find(fgrid == 2); 
M = find(fgrid == 3); S = find(fgrid == 4);

% Wherever there is a red cone, we put (1,0,0) and so forth for the
% other cone types.
% We start with a coneImage that is nCones x 3
coneImage = zeros(numel(fgrid),3);

% We set the L cone rows to red, ... and so forth
coneImage(K,:) = repmat([0,0,0],length(K),1);
coneImage(L,:) = repmat([1,0,0],length(L),1);
coneImage(M,:) = repmat([0,1,0],length(M),1);
coneImage(S,:) = repmat([0,0,1],length(S),1);

% Reshape the image to its actual (row,col,3) size
coneImage = reshape(coneImage,size(fgrid,1),size(fgrid,2),3);
% mp = [0 0 0 ; 1 0 0 ; 0 1 0; 0 0 1]; image(fgrid); colormap(mp)

% Blur the image by a Gaussian - we set blur and support here.
if ieNotDefined('spread')
    l = find(fgrid(1,:) > 0);  % Digital image spacing
    spread = (l(2)-l(1))/3;
end
if ieNotDefined('support'), support = round(3*[spread spread]); end

g = fspecial('gaussian',support,spread);
tmp = imfilter(coneImage,g);

% Show the image
h = vcNewGraphWin;
set(h,'Name','ISET: Human cone mosaic');
imagescRGB(tmp);

return;

