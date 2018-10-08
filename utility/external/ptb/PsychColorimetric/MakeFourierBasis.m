function [B] = MakeFourierBasis(wls,nbasis);
% [B] = MakeFourierBasis(wls,nbasis);
%
% Make a fourier basis set.
%
% 5/17/94   dhb	  Added this comment.
% 11/21/00  dhb   Fix bugs in domain, frequency counting.
% 6/21/03   dhb   More general wl passing, can use S.

% Get domain for sinusoids
wls = MakeItWls(wls);
[n,m] = size(wls);
freqarg = (0:n-1)'/n;

% Make DC
B(:,1) = 0.5*ones(n,1);

% Make cos/sin pairs
k = 1;
freq = 1;
while ( k < nbasis )
  k = k+1;
  B(:,k) = cos( 2*pi*freq*freqarg );
  k = k+1;
  B(:,k) = sin( 2*pi*freq*freqarg );
	freq = freq+1;
end

% Truncate basis set to desired size
B = B(:,1:nbasis);
