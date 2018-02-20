function [minel,IJ]= min2(M,userows,usecols)
% finds the location of the single overall minimum element in a 2-d array
% usage: [minel,IJ] = min2(M)
% usage: [minel,IJ] = min2(M,userows,usecols)
%
% The location in a 2-d array of the overall
% minimum element (or the first incidence of
% several, if the minimum is not unique), where
% you may restrict the search to a set of
% specified rows and/or columns.
%
% Note that min2 does NOT convert the matrix to
% linear indexing, so that really huge arrays
% can be worked with.
%
% arguments: (input)
%  M - an (nxm) 2-dimensional numeric array (or
%      vector) that min is able to operate on. M
%      may contain inf or -inf elements.
%
%  userows - (OPTIONAL) a list of the rows to be
%      searched for the minimum. The search will
%      be restricted to this set of rows. If empty.
%      there will be no row restriction.
%
%      userows must be a list of integers
%
%  usecols - (OPTIONAL) a list of the columns to be
%      searched for the minimum. The search will
%      be restricted to this set of columnss. If
%      empty. there will be no column restriction.
%
% arguments: (output)
%  minel - overall minimum element found. If the
%      minimum was ot unique, then this is the
%      first element identified. Ties will be
%      resolved in a way consistent with find.
%
%  IJ - a (1x2) row vector, comtaining respectively
%      the row and column indices of the minimum as
%      found.
%
% Example:
%  M = magic(4)
% ans =
%    16     2     3    13
%     5    11    10     8
%     9     7     6    12
%     4    14    15     1
%
% % the overall minimum
%  [minel,IJ] = min2(M)
% minel =
%      1
% IJ =
%      4     4
%
%
% % a restricted minimum
%  [minel,IJ] = min2(M,[1 2 3],[2 3])
% minel =
%      2
% IJ =
%     1     2
%
%
% See also: max2, min, max, find
% 
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 2/16/09

% check the arguments
if (nargin<1) || (nargin>3)
  error('min2 may have 1, 2, or 3 arguments only')
end

if length(size(M)) > 2
  error('M must be a 2-d array or a vector')
end
[n,m] = size(M);

% default for userows?
if (nargin<2) || isempty(userows)
  userows = 1:n;
else
  userows = unique(userows);
  if ~isnumeric(userows) || any(diff(userows)==0) || ...
      any(userows<1) || any(userows>n) || any(userows~=round(userows))
    error('userows must be a valid set of indices into the rows of M')
  end
end

% default for usecols?
if (nargin<3) || isempty(usecols)
  usecols = 1:m;
else
  usecols = unique(usecols);
  if ~isnumeric(usecols) || any(diff(usecols)==0) || ...
      any(usecols<1) || any(usecols>m) || any(usecols~=round(usecols))
    error('usecols must be a valid set of indices into the columns of M')
  end
end

% restrict the search
Muse = M(userows,usecols);

% The minimum down the rows
[minrows,rowind] = min(Muse,[],1);

% find the best of these minima
% across the columns
[minel,colind] = min(minrows,[],2);
rowind = rowind(colind);

% package the row and column indices
% together, in terms of the original
% matrix in case there was a restiction.
IJ = [userows(rowind),usecols(colind)];




