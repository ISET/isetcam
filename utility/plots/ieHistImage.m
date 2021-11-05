function [img, fhandle] = ieHistImage(X, varargin)
% Create an intensity histogram from the (x,y) data in columns of X
%
% Synopsis
%    [img, figHandle] = ieHistImage(X, [plotFlag = true], fhandle)
%
% Inputs:
%   X:  An N x 2 matrix of the scatter plot values.  We need to add
%     arguments to set the number and values of the histogram edges 
%
% Optional key/val pairs
%   plotFlag - logical, default true
%   fhandle  - Figure handle
%   pair of param/val arguments might be
%     edge1    vector
%     edge2    vector
%
% Outputs
%   img - Image histogram
%   fhandle - Matlab figure handle
%
% See also
%

% Examples:
%{
  X    = [1:1024,2000:10:2100]; a = 1; b = 0.01;
  Y    = a*X + b; 
  Y    = Y + randn(size(Y))*64;
  edges = [64,64];
  imgH = ieHistImage([X(:),Y(:)],'edges',edges);
  colormap([0.5 0.5 0.5; hot]); grid on;
  g = fspecial('gaussian',[8,8]);
  imgHG = conv2(imgH,g,'same');
  ieNewGraphWin; imagesc(imgHG); axis xy; grid on; axis square
%}

%% Check parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addRequired('X',@(x)(size(x,2) == 2));
p.addParameter('plotflag',true,@islogical);
p.addParameter('fhandle',[],@(x)(isequal(class(x),'matlab.ui.Figure')));
p.addParameter('edges',[32,32],@isvector);

p.parse(X,varargin{:});

plotFlag = p.Results.plotflag;
fhandle  = p.Results.fhandle;
edges    = p.Results.edges;

%% Calls external function histcn to form the image

% Do the calculation
[img, ~, mid] = histcn(X,edges(1),edges(2));
% ieNewGraphWin; plot(X(:,1),X(:,2),'.'); axis equal; identityLine;

%% We will allow more parameters here
if plotFlag
    if isempty(fhandle), fhandle = ieNewGraphWin;
    else,                figure(fhandle)
    end
    
    imagesc(mid{1:2},img);
    axis xy; colormap(0.4 + 0.6*gray(256)); colorbar
end

end



