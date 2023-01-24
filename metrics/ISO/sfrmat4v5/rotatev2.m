function [a, nlin, npix, rflag] = rotatev2(a)
%[a, nlin, npix, rflag] = rotatev2(a)     Rotate edge array vertical
% Rotate array so that the edge feature is in the vertical orientation
% Test based on array values not dimensions.
% a = input array(npix, nlin, ncol)
% nlin, npix are after rotation if any
% flag = 0 no roation, = 1 rotation was performed
%
% Needs: rotate90
%
% 24 Sept. 2008
% Copyright (c) 2008 Peter D. Burns

dim = size(a);
nlin = dim(1);
npix = dim(2);
a = double(a);

% Select which color record, normally the second (green) is good
if length(dim) == 3
    mm = 2;
else
    mm =1;
end

nn = 3;  % Limits test area. Normally not a problem.
%Compute v, h ranges
testv = abs(mean(a(end-nn,:,mm))-mean(a(nn,:,mm)));
testh = abs(mean(a(:,end-nn,mm))-mean(a(:,nn,mm)));

 rflag =0;
if testv > testh
 rflag =1;
 a = rotate90(a);
 temp=nlin;
 nlin = npix;
 npix = temp;

end
