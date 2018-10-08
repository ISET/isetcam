function x = InitialXPoly(values_in,measurements)
% x = InitialXPoly(values_in,measurements)
% 
% 10/22/93	dhb		Changed order from 9 to 6.
% 3/12/94		dhb		Bumped order up to 7.
% 3/13/94		dhb		Bumped order back to 6.	

order = 6;
if (nargin < 2)
  x = zeros(order,1);
else
  x =  [values_in.^6 values_in.^5 ...
       values_in.^4 values_in.^3 values_in.^2, values_in] \ measurements;
end


