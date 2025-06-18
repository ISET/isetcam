function img = imgDeadleaves(n,sigma,options)
% Compute a random image using the dead-leaves model
%
% TODO:  Coordinate with imageDeadleaves.  They are nearly the same.
%        This function is used by sceneDeadleaves.
%
% Syntax
%   image = imgDeadleaves(n,sigma,options);
%
% TODO
%  I would like to put texture patterns inside the disks. *BW*
%
% Inputs
%   n is the size of the image.
%   sigma>0 control the repartition of the size of the basic shape:
%       sigma --> 0  gives more uniform repartition of shape
%       sigma = 3 gives a nearly scale invariant image.
%
% Optional key/value pairs
%   options.nbr_iter put a bound on the number of iteration.
%   options.shape can be 'disk' or 'square'
%
% Outputs
%  img - a gray scale image based on dead leaves model.
%
% References :
%   Dead leaves correct simulation :
%    http://www.warwick.ac.uk/statsdept/staff/WSK/dead.html
%
%   Mathematical analysis
%    The dead leaves model : general results and limits at small scales
%    Yann Gousseau, Fran¸cois Roueff, Preprint 2003
%
%   Scale invariance in the case sigma=3
%    Occlusion Models for Natural Images: A Statistical Study of a Scale-Invariant Dead Leaves Model
%     Lee, Mumford and Huang, IJCV 2003.
%
% Original implementation by 2005 Gabriel Peyré (toolbox_image)
% Re-write for ISETCam (Wandell)
%
% See also
%    sceneCreate
%

% Examples:
%{
 n = 256; sigma = 3; options = [];
 img = sceneDeadleaves(n,sigma,options);
 ieNewGraphWin; imagesc(sceneGet(img,'rgb')); colormap(gray(64));
%}

%% Parameters - TODO:  Use parser

options.null = 0;

if nargin<2
    sigma = 3;
end
if isfield(options,'rmin')
    rmin = options.rmin;
else
    rmin = 0.01;    % maximum proba for rmin, shoult be >0
end
if isfield(options,'rmax')
    rmax = options.rmax;
else
    rmax = 1;    % maximum proba for rmin, shoult be >0
end
if isfield(options,'nbr_iter')
    nbr_iter = options.nbr_iter;
else
    nbr_iter = 5000;
end
if isfield(options,'shape')
    shape = options.shape;
else
    shape = 'disk';
end

%%
img = zeros(n)+Inf;

x = linspace(0,1,n);
[Y,X] = meshgrid(x,x);

% compute radius distribution
k = 200;        % sampling rate of the distrib
r_list = linspace(rmin,rmax,k);
r_dist = 1./r_list.^sigma;
if sigma>0
    r_dist = r_dist - 1/rmax^sigma;
end
r_dist = rescale( cumsum(r_dist) ); % in 0-1

m = n^2;

%%
for i=1:nbr_iter
    
    
    % compute scaling using inverse mapping
    r = rand(1);
    [~,I] = min( abs(r-r_dist) );
    r = r_list(I);
    
    x = rand(1);    % position
    y = rand(1);
    a = rand(1);    % albedo
    
    if strcmp(shape, 'disk')
        I = find(isinf(img) & (X-x).^2 + (Y-y).^2<r^2 );
    else
        I = find(isinf(img) & abs(X-x)<r & abs(Y-y)<r );
    end
    
    m = m - length(I);
    img(I) = a;
    
    if m==0
        % the image is covered
        break;
    end
end

% remove remaining background
% I = find(isinf(M));
img(isinf(img)) = 0;

end