function out = MakeOrtho(in)
% function out = MakeOrtho(in)
%
% The column space of in and out should be the
% same.  But the columns of out are orthonormal.
% In addition the span of out(:,1:n) is the
% same as the span of in(:,1:n) for any n less
% than the column dimension of in.

[m,n] = size(in);
ortho = zeros(m,n);
work = in;
for i = 1:n
  ortho(:,i) = orth(work(:,i));
  work = work-ortho*ortho'*work;
end
out = ortho;
