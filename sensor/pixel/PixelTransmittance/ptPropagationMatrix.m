function L = ptPropagationMatrix(n,d,theta,lambda)
%
%  L = ptPropagationMatrix(n,d,theta,lambda)
%
% AUTHOR: 	Peter Catrysse
% DATE:		June,July, August 2000

k = 2*pi/lambda*n;

%L = [[ones(1,1,length(theta)) zeros(1,1,length(theta))]; ...
%        [zeros(1,1,length(theta)) ones(1,1,length(theta))]];
L = [[exp(i*k*d.*cos(theta)) zeros(1,1,length(theta))];...
      [zeros(1,1,length(theta)) exp(-i*k*d.*cos(theta))]];

return;
