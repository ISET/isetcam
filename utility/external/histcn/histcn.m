function [count, edges, mid, loc] = histcn(X, varargin)
% function [count, edges, mid, loc] = histcn(X, edge1, edge2, ..., edgeN)
%
% Purpose: compute n-dimensional histogram
%
% INPUT
%   - X: is (M x N) array, represents M data points in R^N
%   - edgek: are the bin vectors on dimension k, k=1...N.
%     If it is a scalar (Nk), the bins will be the linear subdivision of
%     the data on the range [min(X(:,k)), max(X(:,k))] into Nk
%     sub-intervals
%     If it's empty, a default of 32 subdivions will be used
%
% OUTPUT
%   - count: n-dimensional array count of X on the bins, i.e.,
%         count(i1,i2,...,iN) = cardinal of X such that
%                  edge1(i1) <= X(:,i1) < edge1(i1)+1 and
%                       ...
%                  edgeN(iN) <= X(:,iN) < edgeN(iN)+1
%   - edges: (1 x N) cell, each provides the effective edges used in the
%     respective dimension
%   - mid: (1 x N) cell, provides the mid points of the cellpatch used in
%     the respective dimension
%   - loc: (M x N) array, index location of X in the bins. Points have out
%     of range coordinates will have zero at the corresponding dimension.
%
% DATA ACCUMULATE SYNTAX:
%   [ ... ] = histcn(..., 'AccumData', VAL);
%   where VAL is M x 1 array. Each VAL(k) corresponds to position X(k,:)
%   will be accumulated in the cell containing X. The accumulate result
%   is returned in COUNT.
%   NOTE: Calling without 'AccumData' is similar to having VAL = ones(M,1)
%
%   [ ... ] = histcn(..., 'AccumData', VAL, 'FUN', FUN);
%     applies the function FUN to each subset of elements of VAL.  FUN is
%     a function that accepts a column vector and returns
%     a numeric, logical, or char scalar, or a scalar cell.  A has the same class
%     as the values returned by FUN.  FUN is @SUM by default.  Specify FUN as []
%     for the default behavior.
%
% Usage examples:
%   M = 1e5;
%   N = 3;
%   X = randn(M,N);
%   [N edges mid loc] = histcn(X);
%   imagesc(mid{1:2},N(:,:,ceil(end/2)))
%
% % Compute the mean on rectangular patch from scattered data
%   DataSize = 1e5;
%   Lat = rand(1,DataSize)*180;
%   Lon = rand(1,DataSize)*360;
%   Data = randn(1,DataSize);
%   lat_edge = 0:1:180;
%   lon_edge = 0:1:360;
%   meanData = histcn([Lat(:) Lon(:)], lat_edge, lon_edge, 'AccumData', Data, 'Fun', @mean);
%
% % Show an identity line (ISET)
%  DataSize = 1e5;
%  X = randn(DataSize,1);
%  X = [X(:), X(:)];
%  [N, edges, mid, loc] = histcn(X);
%  imagesc(mid{1:2},N); axis xy; identityLine;
%
% See also: HIST, ACCUMARRAY
% 
% Bruno Luong: <brunoluong@yahoo.com>
% Last update: 25/August/2011

if ndims(X)>2
    error('histcn: X requires to be an (M x N) array of M points in R^N');
end
DEFAULT_NBINS = 64;

AccumData = [];
Fun = {};

% Looks for where optional parameters start
% For now only 'AccumData' is valid
split = find(cellfun('isclass', varargin, 'char'), 1, 'first');
if ~isempty(split)
    for k = split:2:length(varargin)
        if strcmpi(varargin{k},'AccumData')
            AccumData = varargin{k+1}(:);
        elseif strcmpi(varargin{k},'Fun')
            Fun = varargin(k+1); % 1x1 cell
        end
    end
    varargin = varargin(1:split-1);
end

% Get the dimension
nd = size(X,2);
edges = varargin;
if nd<length(edges)
    nd = length(edges); % wasting CPU time warranty
else
    edges(end+1:nd) = {DEFAULT_NBINS};
end

% Allocation of array loc: index location of X in the bins
loc = zeros(size(X));
sz = zeros(1,nd);
% Loop in the dimension
for d=1:nd
    ed = edges{d};
    Xd = X(:,d);
    if isempty(ed)
        ed = DEFAULT_NBINS;
    end
    if isscalar(ed) % automatic linear subdivision
        ed = linspace(min(Xd),max(Xd),ed+1);
    end
    edges{d} = ed;
    % Call histc on this dimension
    [dummy loc(:,d)] = histc(Xd, ed, 1);
    % Use sz(d) = length(ed); to create consistent number of bins
    sz(d) = length(ed)-1;
end % for-loop

% Clean
clear dummy

% This is need for seldome points that hit the right border
sz = max([sz; max(loc,[],1)]);

% Compute the mid points
mid = cellfun(@(e) 0.5*(e(1:end-1)+e(2:end)), edges, ...
              'UniformOutput', false);
          
% Count for points where all coordinates are falling in a corresponding
% bins
if nd==1
    sz = [sz 1]; % Matlab doesn't know what is one-dimensional array!
end

hasdata = all(loc>0, 2);
if ~isempty(AccumData)
    count = accumarray(loc(hasdata,:), AccumData(hasdata), sz, Fun{:});
else
    count = accumarray(loc(hasdata,:), 1, sz);
end

return

end % histcn
