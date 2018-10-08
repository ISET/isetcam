function [w,X,tri,v] = MunsellGriddata3(x,y,z,v,xi,yi,zi,method,options,X,tri)
% [w,X,tri] = MunsellGriddata3(x,y,z,v,xi,yi,zi,method,options,X,tri)
%
% This is a modified version of the Matlab function griddata3.  We modified
% to allow precomputing of the triangulation, and then direct use of that.
% This will allows us to precompute the triangulation (slow) and
% then interpolate using the same triangulation many times (fast, we hope).
%
%GRIDDATA3 Data gridding and hyper-surface fitting for 3-dimensional data.
%   W = GRIDDATA3(X,Y,Z,V,XI,YI,ZI) fits a hyper-surface of the form
%   W = F(X,Y,Z) to the data in the (usually) nonuniformly-spaced vectors
%   (X,Y,Z,V).  GRIDDATA3 interpolates this hyper-surface at the points
%   specified by (XI,YI,ZI) to produce W.
%
%   (XI,YI,ZI) is usually a uniform grid (as produced by MESHGRID) and is
%   where GRIDDATA3 gets its name. 
%
%   [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD) where METHOD is one of
%       'linear'    - Tessellation-based linear interpolation (default)
%       'nearest'   - Nearest neighbor interpolation
%
%   defines the type of surface fit to the data. 
%   All the methods are based on a Delaunay triangulation of the data.
%   If METHOD is [], then the default 'linear' method will be used.
%
%   [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD,OPTIONS) specifies a cell 
%   array of strings OPTIONS to be used as options in Qhull via DELAUNAYN.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%
%   Example:
%      rand('state',0);
%      x = 2*rand(5000,1)-1; y = 2*rand(5000,1)-1; z = 2*rand(5000,1)-1;
%      v = x.^2 + y.^2 + z.^2;
%      d = -0.8:0.05:0.8;
%      [xi,yi,zi] = meshgrid(d,d,d);
%      w = griddata3(x,y,z,v,xi,yi,zi);
%   Since it is difficult to visualize 4D data sets, use isosurface at 0.8:
%      p = patch(isosurface(xi,yi,zi,w,0.8));
%      isonormals(xi,yi,zi,w,p);
%      set(p,'FaceColor','blue','EdgeColor','none');
%      view(3), axis equal, axis off, camlight, lighting phong
%
%   Class support for inputs X,Y,Z,V,XI,YI,ZI: double
%
%   See also GRIDDATA, GRIDDATAN, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.11.4.7 $  $Date: 2007/06/14 05:11:20 $

if nargin < 7
  error('MATLAB:griddata3:NotEnoughInputs', 'Needs at least 7 inputs.');
end
if ( nargin == 7 || isempty(method) )
	method = 'linear';
elseif ~strncmpi(method,'l',1) && ~strncmpi(method,'n',1)
  error('MATLAB:griddata3:InvalidMethod',...
        'METHOD must be one of ''linear'', or ''nearest''.');
end
if nargin == 9
    if ~iscellstr(options)
        error('MATLAB:griddata3:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');           
    end
    opt = options;
else
    opt = [];
end

if ndims(x) > 3 || ndims(y) > 3 || ndims(z) > 3 || ndims(xi) > 3 || ndims(yi) > 3 || ndims(zi) > 3
    error('MATLAB:griddata3:HigherDimArray',...
          'X,Y,Z and XI,YI,ZI cannot be arrays of dimension greater than three.');
end

% This thread computes the triangulation
if (nargin < 10)

    x = x(:); y=y(:); z=z(:); v = v(:);
    m = length(x);
    if m < 3, error('MATLAB:griddata3:NotEnoughPts','Not enough points.'); end
    if m ~= length(y) || m ~= length(z) || m ~= length(v)
        error('MATLAB:griddata3:InputSizeMismatch',...
            'X,Y,Z,V must all have the same size.');
    end

    X = [x y z];

    % Sort (x,y,z) so duplicate points can be averaged before passing to delaunay

    [X, ind] = sortrows(X);
    v = v(ind);
    ind = all(diff(X)'==0);
    if any(ind)
        warning('MATLAB:griddata3:DuplicateDataPoints',['Duplicate x data points ' ...
            'detected: using average of the v values.']);
        ind = [0 ind];
        ind1 = diff(ind);
        fs = find(ind1==1);
        fe = find(ind1==-1);
        if fs(end) == length(ind1) % add an extra term if the last one start at end
            fe = [fe fs(end)+1];
        end

        for i = 1 : length(fs)
            % averaging v values
            v(fe(i)) = mean(v(fs(i):fe(i)));
        end
        X = X(~ind(2:end),:);
        v = v(~ind(2:end));
    end

    switch lower(method(1)),
        case 'l'
            [w,tri] = linear(X,v,[xi(:) yi(:) zi(:)],opt);
        case 'n'
            w = nearest(X,v,[xi(:) yi(:) zi(:)],opt);
        otherwise
            error('MATLAB:griddata3:UnknownMethod', 'Unknown method.');
    end
    w = reshape(w,size(xi));

% If nargin == 11, then we passed the precomputed triangulation and we don't need to do it again.
else
    [w] = linearwithtri(X,v,[xi(:) yi(:) zi(:)],tri);
    w = reshape(w,size(xi));
end



%------------------------------------------------------------
function [zi,tri] = linear(x,y,xi,opt)
%LINEAR Triangle-based linear interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
if isempty(opt)
  tri = delaunayn(x);
else
  tri = delaunayn(x,opt);
end
if isempty(tri),
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = NaN*zeros(size(xi));
  return
end

% Find the nearest triangle (t)
[t,p] = tsearchn(x,tri,xi);

m1 = size(xi,1);
onev = ones(1,size(x,2)+1);
zi = NaN*zeros(m1,1);

for i = 1:m1
  if ~isnan(t(i))
     zi(i) = p(i,:)*y(tri(t(i),:));
  end
end

%------------------------------------------------------------
function [zi] = linearwithtri(x,y,xi,tri)
%LINEAR Triangle-based linear interpolation, takes tri directly.


% Find the nearest triangle (t)
[t,p] = tsearchn(x,tri,xi);

m1 = size(xi,1);
onev = ones(1,size(x,2)+1);
zi = NaN*zeros(m1,1);

for i = 1:m1
  if ~isnan(t(i))
     zi(i) = p(i,:)*y(tri(t(i),:));
  end
end

%------------------------------------------------------------
function zi = nearest(x,y,xi,opt)
%NEAREST Triangle-based nearest neightbor interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
if isempty(opt)
  tri = delaunayn(x);
else
  tri = delaunayn(x,opt);
end
if isempty(tri), 
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = repmat(NaN,size(xi));
  return
end

% Find the nearest vertex
k = dsearchn(x,tri,xi);

zi = k;
d = find(isfinite(k));
zi(d) = y(k(d));

%----------------------------------------------------------

