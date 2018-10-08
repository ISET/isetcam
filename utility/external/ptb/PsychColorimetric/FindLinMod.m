function [B,A] = FindLinMod(X,n_dimension)
% [B,A] = FindLinMod(X,n_dimension)
% 
% Find an n_dimension linear model for the
% data in the columns of X.
%
% B - basis matrix for the linear model
%  (n_wavelengths by n_dimension)
% A - coefficients to approximate data within model
%  (n_dimension by n_data)
% X - matrix whose columns contain the data
%  (n_wavelengths by n_data)
%  (n_data >= n_dimension)
% n_dimension - dimension of the linear model to find

% Do the singular value decomposition
% (If X is very large you may need a bigger
% computer.)
[U,D,V] = svd(X);

% Extract the appropriate parts of the SVD
B = U(:,1:n_dimension);
temp = D*V';
A = temp(1:n_dimension,:);
