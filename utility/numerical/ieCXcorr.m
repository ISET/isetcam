function [xc,lags] = ieCXcorr(a,b)
% Circular Cross Correlation function estimates. 
%
% ieCXcorr(a,b), where a and b represent samples taken over time interval T
% which is assumed to be a common period of two corresponded periodic signals. 
% a and b are supposed to be length M row vectors, either real or complex.
% 
% [x,c]=ieCXcorr(a,b) returns the length M-1 circular cross correlation sequence c
% with corresponded lags x.
%   
% The circular cross correlation is:
%
%         c(k) = sum[a(n)*conj(b(n+k))]/[norm(a)*norm(b)]; 
%
% where vector b is shifted CIRCULARLY by k samples.
%
% Example
%   a = (1:10)'; b = circshift(a,-3);
%   [xc, lags] = ieCXcorr(a,b)
%   vcNewGraphWin; plot(lags,xc);
%
% Modified from cxcorr() in Matlab file exchange
%
% For circular covariance between a and b look for CXCOV(a,b) in
% http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&objectId=1093734
%
% Reference:
% A. V. Oppenheim, R. W. Schafer and J. R. Buck, Discrete-Time Signal Processing, 
% Upper Saddler River, NJ : Prentice Hall, 1999.
%
% Author: G. Levin, Apr. 26, 2004.
%
% Modified by Imageval Consulting, LLC, 2015

a = a(:)'; b = b(:)'; 
if length(a) ~= length(b)
    error('Vector length ength mismatch.');
end

% Input vector normalization
na=norm(a); nb=norm(b);
a=a/na; b=b/nb;

% Compute xcorrelation
xc = zeros(size(a));
for k=1:length(b)
    xc(k)=a*b';
    b=[b(end),b(1:end-1)]; %circular shift
end

lags = (0:length(b)-1);

end
