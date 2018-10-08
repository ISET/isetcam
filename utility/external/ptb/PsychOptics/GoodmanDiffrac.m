function mtf = GoodmanDiffrac(s,s0)
% mtf = GoodmanDiffrac(s,s0)
%
% Compute Equation 6-31 from page 120 of Goodman.
% This is the diffraction-limited optical MTF,
% computed given the coherent diffraction limit s0.
% 
% Goodman, J. W. (1968) Introduction to Fourier Optics. 
% San Francisco: McGraw-Hill.
%
% Note that in the Williams et al. paper (ref??), this
% formula is given for the incoherent diffraction limit,
% which is twice the coherent limit.
% 
% Also see DiffractionMTF.

% 7/11/94		dhb		Added some comments, changed variable names
% 1/27/01		dgp		Cosmetic.
% 9/8/02		dgp		Cosmetic.

mtf = zeros(size(s));
factor = zeros(size(s));
index = find(s <= 2*s0);
temp = ones(size(s(index)));
factor(index) = s(index) ./ (2*s0);
mtf(index) = (2/pi)*( acos(factor(index)) -	factor(index).*sqrt(temp-factor(index).^2) );
  
