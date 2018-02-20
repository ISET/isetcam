function outArray = unpadarray(inArray,unpadSize)
% Inverts padarray.  Not much tested yet.  Work on it.
%
% Roughly an inverse.  Tested quite thoroughly.  Hmmm.
% 
%

if ieNotDefined('inArray'), error('Input array required'); end
if ieNotDefined('unpadSize'), error('unpad size required'); end

if length(unpadSize) < 2, unpadSize(2) = 0; end

r = size(inArray,1);
c = size(inArray,2);

rows = (unpadSize(1)+1):(r-unpadSize(1));
cols = (unpadSize(2)+1):(c-unpadSize(2));

if ndims(inArray) == 3
    outArray = inArray(rows,cols,:);
else
    outArray = inArray(rows,cols);
end

return

