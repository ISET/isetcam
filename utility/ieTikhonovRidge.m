%% Tikhonov regularizer (ridge, regression) 
%
%
% https://en.wikipedia.org/wiki/Ridge_regression#Tikhonov_regularization

%% Consider an ordinary linear equation
%
% b = Ax

% Here is an example.  Underconstrained equation
A = rand(20,10);   % 20 x 10  matrix
b = rand(20,1);    % Predict 20 numbers
x = A\b;           % Only 10 free parameters

bhat = A*x;      % The predicted value of b

%% This is how much we miss with ordinary least squares
ieNewGraphWin;
plot(b(:),bhat(:),'.');
identityLine;
axis square;
norm(b - A*x )

%% This is what x looks like
h = ieNewGraphWin; plot(x)

%% The Tikhonov regression
%
% Find a shorter solution, x.   How much do we care?  lambda
%
% x = argmin |b-Ax|^2 + lambda*|x|^2
%

%  The closed form Tikhonov solution.  Notice that the curves shrink
%  towards the y = 0 line, making the solution smaller.  The error
%  gets larger as lambda gets larger.
for lambda = logspace(-1,0,3)
    xR = inv(A'*A + lambda^2*eye(size(A,2))) * A' * b;
    hold on; plot(xR,'-o');
    norm(b - A*xR)
end

%% Difference operator

% We can use an alternative regularizer to impose a different 
% constraint on the solution, x. We might like a smoothness
% constraint, say to mimize the first derivative.
%
x = argmin |b - Ax|^2 + lambda*|D*x|^2

% In this case, D is the first derivative operator expressed as a matrix, sometimes
% called the difference operator.  

% There is a direct solution for this case

x = inv(A'*A + lambda^2*D'*D) * A' * b


% Computational efficiency % %   By SVD, we can avoid the matrix
inversion and estimate the %   coefficients as [U, D, V'] = svd(X); d
= diag(D); beta = V * diag(d./(d.^2 + lambda))*U'*y

%}