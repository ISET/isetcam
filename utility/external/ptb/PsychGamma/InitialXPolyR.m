function x = InitialXPolyR(values_in,measurements)
% x = InitialXPolyR(values_in,measurements)
% 
% 3/15/94		dhb, jms		Created from InitialXPoly to allow
%								separate order for raw fits.


order = 6;
if (nargin < 2)
  x = zeros(order,1);
else
	x =  [values_in.^6 values_in.^5 ...
        values_in.^4 values_in.^3 values_in.^2, values_in] \ measurements;     
end



