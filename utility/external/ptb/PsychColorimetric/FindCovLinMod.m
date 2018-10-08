function [B,w0,Kw] = FindCovLinMod(Kx,nDim,x0)
% [B,w0,Kw] = FindCovLinMod(Kx,nDim,[x0])
% 
% Find the linear model for a set of vectors
% distributed Normally with covariance matrix K.
%
% The second two return values are only computed
% if x0 is passed.
%
% 8/22/94		dhb		Wrote it.

% Compute the SVD of the covariance matrix
[U,D,V] = svd(Kx);
if (MatMax(U-V) > 1e-10)
	error('Theory says U should equal V in svd of a covariance matrix');
end

% Extract the bases.  They are orthonormal.
B = U(:,1:nDim);

% Compute mean in new basis if raw mean was passed.
if (nargin == 3)
	w0 = B\x0;
	Kw = D(1:nDim,1:nDim);
end



