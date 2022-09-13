function [img, xy, cmap, fhandle] = ieHistImage(X, varargin)
% Create an intensity histogram from the (x,y) data in two columns of X
%
% Synopsis
%    [img, xy, figHandle] = ieHistImage(X, [plotFlag = true], fhandle)
%
% Inputs:
%   X:  An N x 2 matrix of the scatter plot values.
%
% Optional key/val pairs
%   method   - Use histcn or scatplot drawing method (default: scatplot)
%   plotFlag - logical, default true
%   fhandle  - Figure handle
%   edges    - Number of edges on x and y axes 
%
% Outputs
%   img     - Image histogram
%   xy      - Cell array x and y coordinates of the image
%   cmap    - Color map used in ieHistImage
%   fhandle - Matlab figure handle
%
% See also
%   scatplot, histcn,v_extHistcn

% Examples:
%{
  X    = [1:1024,2000:10:2100]; a = 1; b = 0.01;
  Y    = a*X + b;
  Y    = Y + randn(size(Y))*64;
  edges = [64,32];
  [imgH, xy, cmap] = ieHistImage([X(:),Y(:)],'hist type','histcn','edges',edges,'plot flag',true);
  g = fspecial('gaussian',[8,8]);
  imgHG = conv2(imgH,g,'same');
  ieNewGraphWin; imagesc(imgHG); colormap(cmap); axis xy; grid on; axis square
%}
%{
  X    = [1:1024,2000:1:2100]; a = 1; b = 0.01;
  Y    = a*X + b;
  Y    = Y + randn(size(Y))*64;
  imgH = ieHistImage([X(:),Y(:)],'hist type','scatplot','scatmethod','voronoi');
  identityLine;
%}

%% Check parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addRequired('X',@(x)(size(x,2) == 2));
p.addParameter('plotflag',true,@islogical);
p.addParameter('fhandle',[],@(x)(isequal(class(x),'matlab.ui.Figure')));
p.addParameter('edges',[32,32],@isvector);
p.addParameter('histtype','scatplot',@ischar);

p.addParameter('scatmethod','',@ischar);
p.addParameter('scatradius',8,@isnumeric);
p.parse(X,varargin{:});

plotFlag = p.Results.plotflag;
fhandle  = p.Results.fhandle;
edges    = p.Results.edges;

%% Calls external function histcn to form the image
switch p.Results.histtype
    case 'histcn'
        % Do the calculation.  
        % The image and the x,y values of the image ('mid')
        [img, ~, tmp] = histcn(X,edges(1),edges(2));
        xy{1} = tmp{1,1};
        xy{2} = tmp{1,2};
        % ieNewGraphWin; plot(X(:,1),X(:,2),'.'); axis equal; identityLine;
        
    case 'scatplot'
        x = X(:,1); y = X(:,2);
        method = 'voronoi';
        radius = sqrt((range(x)/30)^2 + (range(y)/30)^2);
        N = 100;  % Not sure
        n = 5;    % Smoothing?
        po = 1;   % Plot options
        ms = 4;   % Marker size        
        scatStruct = scatplot(x,y,method,radius,N,n,po,ms,gray(256));
        img = scatStruct.zif;
        xy{1} = scatStruct.xi(1,:);
        xy{2} = scatStruct.yi(:,1);
    otherwise
        error('Unknown histogram method %s.',p.Results.histtype);
end

%% We will allow more parameters here
if plotFlag
    if isempty(fhandle), fhandle = ieNewGraphWin;
    else,                figure(fhandle)
    end
    
    imagesc(xy{1},xy{2},img);
    
    axis xy; cmap = 0.4 + 0.6*gray(256);
    colormap(0.4 + 0.6*gray(256)); colorbar
    grid on; axis square;
end

end



