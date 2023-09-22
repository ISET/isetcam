function u = unitLength(v)
% Convert vectors in the rows of v to unit length in rows of u
%
%  u = unitLength(v)
%
% Assuming v is a matrix, we set the length of each row of v to be unit
% length.
%
% Example:
%   v = randn(8,8);
%   u = unitLength(v);
%   diag(u*u')
%
% (c) Imageval Consulting, LLC 2012

% Programming TODO:  Optimize this function for speed and functionality.

% Look at Kendrick's function below for ideas.  In particular, he allows
% specifying whether we want this done for rows or columns In the future we
% will add a parameter, dim = 1 through n to define which dimension we want
% to be unit length. For now, He also uses that bsx stuff which is faster

% Make sure vectors are returned with same shape.
reshapeFlag = 0;

% Make sure vector is a row vector.
[r,c] = size(v);
if c==1, v = v(:)'; reshapeFlag = 1; end

u = diag(1./sqrt(diag(v*v')))*v;

if reshapeFlag, u = reshape(u,r,c); end

end

%% From Kendrick


% function [f,len,sc] = unitLength(m,dim,flag,wantcaution,sc)
%
% % function [f,len,sc] = unitlength(m,dim,flag,wantcaution,sc)
% %
% % <m> is a matrix
% % <dim> (optional) is the dimension of interest.
% %   if supplied, normalize each case oriented along <dim> to have unit length.
% %   if [] or not supplied, normalize length globally.
% % <flag> (optional) is
% %   0 means normal case
% %   1 means make length sqrt(n) where n is number of non-NaN entries
% %   default: 0
% % <wantcaution> (optional) is whether to perform special handling of
% %   weird cases where the length of <m> is very small to start with (see zerodiv.m).
% %   default: 1.
% % <sc> (optional) is a special case.  supply this and we will use it instead of
% %   calculating the actual scale factor.  also, <len> will be returned as [].
% %   to indicate not-supplied, pass in [].
% %
% % unit-length normalize <m> via scaling, operating either on individual cases or globally.
% % the output <f> has the same dimensions as <m>.  also, return <len> which is
% % the vector length of <m> along <dim>.  when <dim> is [], <len> is a scalar;
% % otherwise, <len> is the same dimensions as <m> except collapsed along <dim>.
% % also, return <sc> which is the scale factor divided from <m>.  the dimensions
% % of <sc> is the same as <len>.
% %
% % we ignore NaNs gracefully.
% %
% % note some weird cases:
% %   unitLength([]) is [].
% %   unitLength([0 0]) is [NaN NaN].
% %   unitLength([NaN NaN]) is [NaN NaN].
% %
% % history:
% % 2011/06/27 - oops. handle empty case explicitly (it would have crashed)
% %
% % Example:
% %  a = [3 0 NaN];
% %  isequalwithequalnans(unitlength(a),[1 0 NaN])
% %
% % From Kendrick Kay
%
% % input
% if ~exist('dim','var') || isempty(dim),   dim = []; end
% if ~exist('flag','var') || isempty(flag),   flag = 0; end
% if ~exist('wantcaution','var') || isempty(wantcaution), wantcaution = 1; end
%
% % handle degenerate case up front
% if isempty(m)
%   f = [];
%   len = [];
%   sc = [];
%   return;
% end
%
% % figure out len and sc
% if ~exist('sc','var') || isempty(sc)
%
%   % figure out vector length
%   len = vectorlength(m,dim);
%
%   % figure out scale factor
%   if flag==1
%     if isempty(dim)
%       temp = sqrt(sum(~isnan(m(:))));
%     else
%       temp = sqrt(sum(~isnan(m),dim));
%     end
%     sc = len./temp;
%   else
%     sc = len;
%   end
%
% else
%   len = [];
% end
%
% % ok, do it
% f = bsxfun(@(x,y) zerodiv(x,y,NaN,wantcaution),m,sc);
%
% end
%
% % HM, IS THIS SLOWER OR FASTER:
% % if isempty(dim)
% %   f = zerodiv(m,sc,NaN,wantcaution);
% % else
% %   f = zerodiv(m,repmat(sc,copymatrix(ones(1,ndims(m)),dim,size(m,dim))),NaN,wantcaution);
% % end

