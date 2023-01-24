function  [p, s, mu] = findedge2(cent, nlin, nn)
% [slope, int] = findedge2(cent, nlin, nn)  Fits polynomial equation to data
% Fits poly. equation to data, written to process edge location array
%   cent = array of (centroid) values
%   nlin = length of cent
%   p values are coefficients from the least-square fit
%    x = int + slope*cent(x)
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  form
% Author: Peter Burns, pdburns@ieee.org    
% Updated version of findedge using scaled x values 16 July 2019
% Copyright 2019 by Peter D. Burns. All rights reserved.

 if nargin<3
     nn=1;
 end
%  if nn>3
%      disp(['Warning: Polynominal fit to edge is of order ',num2str(nn)]);
%  end
 index=0:nlin-1;
 % Adding output variable mu makes the fit in centered and scaled x values
 % this improves the fitting, 16 July 2019
[p, s, mu] = polyfit(index, cent, nn); % x = f(y)
 % Next we 'unscale' the polynomial coefficients so we can use them easily
 % later directly in sfrmat4
 p = polyfit_convert(p, index);
