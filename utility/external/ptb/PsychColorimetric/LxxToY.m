function Y = LxxToY(Lxx,white)
% Y = LxxToY(Lxx,white)
% 
% Convert either Lab or Luv to Y, given the XYZ coordinates of
% the white point.
%
% 10/10/93    dhb   Converted from CAP C code.

% Get white point Y and Lstar out of arguments
Lstar = Lxx(1,:);
Yn = white(2);

% Find size and allocate space
[m,n] = size(Lxx);
Y = zeros(1,n);

% Compute Y by inverting conventional formula
Y = Yn * (((Lstar + 16.0)/116.0).^ 3.0);

% Check range to make sure that formula was correct.
% Because Lstar is a monotonic function of Y/Yn, this method 
% of checking the range is OK.
redoIndex = find( (Y/Yn) < 0.008856 );
if (~isempty(redoIndex)) 
  Y(redoIndex) = Yn*(Lstar(redoIndex)/903.3);
end



