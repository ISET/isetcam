function Y = convolvecirc(X, h)
%  Performs 2D circular convolution
%
%  Y = convolvecirc(X,h)
%
%  The matrix h (kernel) is convolved with the matrix X. The result has the
%  same size as X. There is probably a Matlab circular convolution by now
%  in the image processing toolbox.
%
%  It is assumed that both the row dimension and column dimension  of h do
%  not exceed those of X.  The result is the same as zero-padding h out to
%  the size of X,  and then computing the convolution X*h.
%
% Copyright ImagEval Consultants, LLC, 2003.

[m, n] = size(X);
Y = conv2(X, h);

[r, s] = size(Y);
Y(1:(r - m), :) = Y(1:(r - m), :) + Y((m+1):r, :);
Y(:, 1:(s - n)) = Y(:, 1:(s - n)) + Y(:, (n + 1):s);

% Clip the extent of the result
Y = Y(1:m, 1:n);

return;
