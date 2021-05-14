function I = ptInterfaceMatrix(rho,tau)
%
%  I = ptInterfaceMatrix(rho,tau)
%
% AUTHOR: 	Peter Catrysse
% DATE:		June,July, August 2000
%
%

I = [[ones(1,1,length(rho))./tau rho./tau]; ...
    [rho./tau ones(1,1,length(rho))./tau]];

return;
