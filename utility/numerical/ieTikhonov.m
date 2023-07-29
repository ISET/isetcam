function [x,xOLS] = ieTikhonov(A,b,varargin)
% Tikohonov regularizer (also called ridge regression)
%
% Synopsis
%     [x,xOLS] = ieTikhonov(A,b,varargin)
%
% Brief description
%   Solves for x in b = Ax, subject to different regularization constraints
%
% Inputs
%   A      -   A matrix (m x n)
%   b      -   A vector (m)
%
% Optional key/val pairs
%   minnorm      - weight for min norm
%   smoothness   - weight for 2nd derivative smoothness
%
% Output
%   x    - The solution subject to the constraints
%   xOLS - The linsolve solution
%
% Description
%  This is the form of the Tikhonov regularizer we use for now to solve for
%
%      x = Ab
%
% The solution:
%
%   x = inv(A'*A + lambda1*eye(size(A,2)) + lambda2*(D2'*D2)) * (A' * b);
%
%  D2 is the 2nd derivative operator, which enforces smoothness.  the
%  Identity enforces a minimum norm
%
%  We may implement more regularization terms in the future.
%
% See also
%  t_codeTikhonovRidge for an explainer

% Examples:
%{
 A = rand(20,10);   % 20 x 10  matrix
 b = rand(20,1);    % Predict 20 numbers
 [x,xOLS] = ieTikhonov(A,b,'minnorm',5);
 ieNewGraphWin; p1 = plot(x,'k:'); hold on; p2 = plot(xOLS,'k-'); 
 xaxisLine;
 legend([p1 p2],'x','xOLS')
%}

% TODO:  More regularizers.  Expand the thinking

%%
p = inputParser;
p.addRequired('A',@ismatrix);
p.addRequired('b',@isvector);
p.addParameter('minnorm',0,@isscalar);
p.addParameter('smoothness',0,@isscalar);

p.parse(A,b,varargin{:});
lambda1 = p.Results.minnorm;
lambda2 = p.Results.smoothness;

%% Use the 2nd derivative and identity as defaults

% Not slow, so start with this simple approach
D2 = diff(eye(size(A,2)), 2);  % Second-order finite difference matrix

% The Tikhonov/Ridge equation
x = inv(A'*A + lambda1*eye(size(A,2)) + lambda2*(D2'*D2)) * (A' * b);

if nargout > 1
    xOLS = linsolve(A,b);
end

end

