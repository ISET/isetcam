function scene = sceneDeadleaves(n,sigma,options)
% Compute a random image using the dead-leaves model
%
% Syntax
%   scene = sceneDeadleaves(n,sigma,options);
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
%    sceneCreate, imgDeadleaves
%

% Examples:
%{
 n = 256; sigma = 3; options = [];
 scene = sceneDeadleaves(n,sigma,options);
 sceneWindow(scene);
%}

%% Parameters - TODO:  Use parser

options.null = 0;

if nargin<2
    sigma = 3;
end

% These parameters need to be exposed in the input arguments.
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

%%  Build up the scene from the image

img = imgDeadleaves(n,sigma,options);

rgb = zeros(size(img,1),size(img,2),3);
for ii=1:3
    rgb(:,:,ii) = img;
end

dispCal = 'OLED-Sony.mat';
scene = sceneFromFile(img,'rgb',100,dispCal);
scene = sceneSet(scene,'fov',10);
scene = sceneSet(scene,'Name','Dead leaves');

end