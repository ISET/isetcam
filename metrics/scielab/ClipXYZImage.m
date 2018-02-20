function resImage = ClipXYZImage(xyzImage, whitePt)
% Clips the xyzImage to be > 0 and within the white point range 
%
%  resImage = ClipXYZImage(xyzImage, whitePt)
%
% The white point range is [0,white_point] for each of the 3 dimensions.
%
% Copyright ImagEval Consultants, LLC, 2003.

[M, N, L]=size(xyzImage);

resImage = zeros(M,N,L);
for ii=1:L
  t = xyzImage(:,:,ii);
  t(t<0) = 0; 
  t(t>whitePt(ii)) = whitePt(ii);
  resImage(:,:,ii) = t;
end

return
