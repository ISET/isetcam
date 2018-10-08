function out = ShiftSpectra(in,Sin,shift)
% out = ShiftSpectra(in,Sin,shift)
%
% Shift spectra along wavelength axis.  Works
% on a single row vector.  Should probably
% be generalized to handle a whole set
% of color matching functions.
%
% 11/23/98  dhb  Wrote it.
% 8/16/00   dhb  Modify to handle row or column vector input.

[m,n] = size(in);
if (m > n)
	in = in';
end

% Generate shifted version, 0.5 nm sampling
S = [380 0.5 801];
shift = 2*shift;
nominal = SplineCmf(Sin,in,S);
shifted = zeros(size(nominal));
if (shift < 0)
	shifted(1:(S(3)-abs(shift))) = nominal((1+abs(shift)):S(3));
else
	shifted((1+abs(shift)):S(3)) = nominal(1:(S(3)-abs(shift)));
end

% For debugging, can print out input and output lambda-max
index1 = find(nominal == max(nominal));
index2 = find(shifted == max(shifted));
wls = SToWls(S);
%fprintf('\tShiftSpectra: Input peak at %g nm, shifted peak at %g nm\n',wls(index1),wls(index2));
	
% Back to normal spacing
out = SplineCmf(S,shifted,Sin);
if (m > n)
	out = out';
end
