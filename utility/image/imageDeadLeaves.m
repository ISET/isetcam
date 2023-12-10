function [M, rseed] = imageDeadLeaves(n,sigma,options)
% Compute a random image using the dead-leaves model
%
%   [M, rseed] = imageDeadLeaves(n,sigma,options);
%
% Inputs
%   n is the size of the image.
%   sigma>0 control the repartition of the size of the basic shape:
%       sigma --> 0  gives more uniform repartition of shape
%       sigma=3 gives a nearly scale invariant image.
%   options.nbr_iter put a bound on the number of iteration.
%   options.shape can be 'disk' or 'square'
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
% Initial download from
%  https://www.mathworks.com/matlabcentral/fileexchange/16201-toolbox-image?focused=5133062&tab=function
%  Modified significantly by BW.
%
% Copyright (c) 2005 Gabriel Peyré

% TODO
%   * Set initial seed for reproducible result
%   * Consider extension to color

% Examples:
%{
 options.shape = 'disk';
 n     = 256;
 sigma = 3;
 [img, rseed] = imageDeadLeaves(n,sigma,options);
 vcNewGraphWin; imagesc(img);
 colormap(gray(64)); axis image; truesize
%}
%{
 % Produces exactly the same image twice.  Use rseed = rng; for new image.
 options.shape = 'disk';
 n     = 256;
 sigma = 3;
 [img, rseed] = imageDeadLeaves(n,sigma,options);
 options.rseed = rseed;
 img = imageDeadLeaves(n,sigma,options);
 vcNewGraphWin; imagesc(img);
 colormap(gray(64)); axis image; truesize
%}

%% Set up options
options.null = 0;

if nargin<2, sigma = 3; end

if isfield(options,'rmin'), rmin = options.rmin;
else,                       rmin = 0.01;    % maximum proba for rmin, shoult be > 0
end

if isfield(options,'rmax'),   rmax = options.rmax;
else,                         rmax = 1;    % maximum proba for rmin, should be > 0
end

if isfield(options,'nbr_iter'), nbr_iter = options.nbr_iter;
else,                           nbr_iter = 5000;
end

if isfield(options,'rseed'),    rng(options.rseed); rseed = options.rseed;
else,                           rseed = rng;
end

if isfield(options,'shape'),    shape = options.shape;
else,                           shape = 'disk';
end

%%
M = zeros(n)+Inf;  % Set background to Inf

x = linspace(0,1,n);
[Y,X] = meshgrid(x,x);

% compute radius distribution
k = 200;        % sampling rate of the distrib
r_list = linspace(rmin,rmax,k);
r_dist = 1./r_list.^sigma;
if sigma > 0, r_dist = r_dist - (1/rmax^sigma);
end

%  Used to be rescale (see below)
r_dist = ieScale( cumsum(r_dist) ); % in 0-1.

m = n^2;

for i=1:nbr_iter
    
    % compute scaling using inverse mapping
    r = rand(1);
    [~,I] = min( abs(r-r_dist) );
    r = r_list(I);
    
    x = rand(1); y = rand(1);  % position
    a = rand(1);               % reflectance (albedo)
    
    % Find the disk or square at the random position
    switch shape
        case 'disk'
            I = find(isinf(M) & ((X-x).^2 + (Y-y).^2) < r^2 );
        case 'square'
            I = find(isinf(M) & abs(X-x)<r & abs(Y-y) < r );
        otherwise
            error('Unknown shape %s\n',shape);
    end
    
    % Set the albedo at these locations
    m = m - length(I);
    M(I) = a;
    
    % If no more places left, you are done.
    if m==0, break; end      % the image is covered
end

% remove remaining background
lst = isinf(M);
uncovered = sum(lst(:));
if uncovered > 0
    fprintf('Filled in %d pixels with 0\n',uncovered)
    M(lst) = 0;
end

end

