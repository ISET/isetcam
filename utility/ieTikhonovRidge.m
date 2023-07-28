%% Notes:  Tikhonov regularizer (ridge, regression) 
%
% We should turn this into a function.  It can be used for solving the
% Maxwell data and other smooth curves, say as part of Haomiao's
% spectral estimation.
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

%% The Tikhonov regression
%
% Find a shorter solution, x.   How much do we care?  lambda
%
% x = argmin |b-Ax|^2 + lambda*|x|^2
%

%  The closed form Tikhonov solution.  Notice that the curves shrink
%  towards the y = 0 line, making the solution smaller.  The error
%  gets larger as lambda gets larger.

% This is what x looks like, followed by the other, smaller solutions
h = ieNewGraphWin; plot(x,'-k*')
lambda = logspace(-1,0.5,5);
err = zeros(size(lambda));
for lambda = logspace(-1,0,3)
    xR = inv(A'*A + lambda(ii)^2*eye(size(A,2))) * A' * b;
    hold on; plot(xR,'-o');
    err(ii) = norm(b - A*xR);
end
disp(err);

%% Difference operator


% We can use an alternative regularizer to impose a different 
% constraint on the solution, x. We might like a smoothness
% constraint, say to mimize the first derivative.
%
% x = argmin |b - Ax|^2 + lambda*|D*x|^2

% In this case, D is the first derivative operator expressed as a
% matrix, sometimes called the difference operator. Here is the
% derivative operator for this size
n = numel(xR);
D = - eye(n);
for ii = 1 : n-1
    D(ii, ii + 1) = 1;
end

% Get rid of last line
D = D(1:end-1,:);

% This is what x looks like, followed by the other, smoother solutions
h = ieNewGraphWin; plot(x,'-k*')
lambda = logspace(-1,0.5,5);
err = zeros(size(lambda));
for ii = 1:numel(lambda)
    xD = inv(A'*A + lambda(ii)^2*(D'*D)) * A' * b;
    hold on; plot(xD,'-o');
    err(ii) = norm(b - A*xD);
end
disp(err);

% ieNewGraphWin; semilogx(lambda,err);

%% END
