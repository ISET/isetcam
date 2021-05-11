function [img, fhandle] = ieHistImage(X, plotFlag, fhandle)
% Create an intensity histogram from the (x,y) data in columns of X
%
% Synopsis
%    [img, figHandle] = ieHistImage(X, [plotFlag = true], fhandle)
%
% X:  An N x 2 matrix of the scatter plot values.  These are divided into
%     32 bins at the moment.
%     We need to add arguments to set the number and values of the histogram edges
%
% pair of param/val arguments might be
%    edge1    vector
%    edge2    vector
%    showPlot (true/false)
%
% BW, Copyright Imageval Consulting, LLC, 2015
%
% See also
%

%% Check parameters
if ieNotDefined('X'), error('X required');
elseif size(X, 2) ~= 2, error('X size is wrong');
end
if ieNotDefined('plotFlag'), plotFlag = true; end
if ieNotDefined('fhandle'), fhandle = []; end

%% Calls external function histcn to form the image

% Do the calculation
[img, ~, mid] = histcn(X);
% vcNewGraphWin; plot(X(:,1),X(:,2),'.'); axis equal; identityLine;

%% We will allow more parameters here
if plotFlag
    if isempty(fhandle), fhandle = ieNewGraphWin;
    else, figure(fhandle)
    end

    imagesc(mid{1:2}, img);
    axis xy;
    colormap(0.4+0.6*gray(256));
    colorbar
end

end
