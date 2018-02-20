function s = ieMvnrnd(mu,Sigma,K)
% Multivariate normal random number generator
%
%    s = ieMvnrnd(mu,Sigma,K)
%
% The data will be d dimensional.  n is the number of samples, although
% this can be specified two ways (see below).
%
%   mu:  Matrix (n x d) of n samples by d dimensions.
%   Sigma: Covariance matrix (d x d)
%   K:     Number of samples.  Typically used if mu has only one row, then
%   there is a repmat which rewrites mu to K rows for K samples.  Matlab
%   calls K the number of 'cases'.
%
%
% Example:
% Univariate
%   mu = zeros(1000,1);
%   Sigma = 1;
%   s = ieMvnrnd(mu,Sigma); vcNewGraphWin; hist(s,50);
%
%   mu = 0; Sigma = 1; K = 1000; s = ieMvnrnd(mu,Sigma,K); 
%   vcNewGraphWin; hist(s,50);
%
% Bivariate Covariance
%   mu = zeros(500,2); 
%   Sigma(1,1) = 0.5;  Sigma(2,2) = 1; 
%   Sigma(1,2) = -0.3; Sigma(2,1) = Sigma(1,2);
%   s = ieMvnrnd(mu,Sigma); 
%   vcNewGraphWin; plot(s(:,1),s(:,2),'.'); 
%   axis equal; set(gca,'xlim',[-5 5],'ylim',[-5 5])
%
%
% Author: http://homepages.inf.ed.ac.uk/imurray2/code/matlab_octave_missing/mvnrnd.m
% Iain Murray 2003 -- I got sick of this simple thing not being in Octave and
%                     locking up a stats-toolbox license in Matlab for no good
%                     reason.
% Original comments
% Draw n random d-dimensional vectors from a multivariate Gaussian
% distribution with mean mu (n x d) and covariance matrix Sigma (d x d).  K
% specifies how many samples for each condition.
% 
%
% Reformatted and restructured for Imageval in 2012


%% Argument
if ieNotDefined('mu'), mu = 0; end
if ieNotDefined('Sigma'), Sigma = 1; end

% If mu is column vector and Sigma not a scalar then assume user didn't
% read help but let them off and flip mu. Don't be more liberal than this
% or it will encourage errors (eg what should you do if mu is square?).
if ((size(mu,2)==1) && (~isequal(size(Sigma),[1,1]))), mu=mu'; end

% May 2004 take a third arg, cases. Makes it more compatible with Matlab's.
if nargin==3, mu=repmat(mu,K,1); end
[n,d]=size(mu);

if (size(Sigma)~= [d,d])
	error('Sigma must have dimensions dxd where mu is nxd.');
end

try
	U=chol(Sigma);
catch
	[E,Lambda]=eig(Sigma);
	if (min(diag(Lambda))<0),error('Sigma must be positive semi-definite.'),end
	U = sqrt(Lambda)*E';
end

s = randn(n,d)*U + mu;

end

%%
% {{{ END OF CODE --- Guess I should provide an explanation:
% 
% We can draw from axis aligned unit Gaussians with randn(d)
% 	x ~ A*exp(-0.5*x'*x)
% We can then rotate this distribution using
% 	y = U'*x
% Note that
% 	x = inv(U')*y
% Our new variable y is distributed according to:
% 	y ~ B*exp(-0.5*y'*inv(U'*U)*y)
% or
% 	y ~ N(0,Sigma)
% where
% 	Sigma = U'*U
% For a given Sigma we can use the chol function to find the corresponding U,
% draw x and find y. We can adjust for a non-zero mean by just adding it on.
% 
% But the Cholsky decomposition function doesn't always work...
% Consider Sigma=[1 1;1 1]. Now inv(Sigma) doesn't actually exist, but Matlab's
% mvnrnd provides samples with this covariance st x(1)~N(0,1) x(2)=x(1). The
% fast way to deal with this would do something similar to chol but be clever
% when the rows aren't linearly independent. However, I can't be bothered, so
% another way of doing the decomposition is by diagonalising Sigma (which is
% slower but works).
% if
% 	[E,Lambda]=eig(Sigma)
% then
% 	Sigma = E*Lambda*E'
% so
% 	U = sqrt(Lambda)*E'
% If any Lambdas are negative then Sigma just isn't even positive semi-definite
% so we can give up.
% }}}