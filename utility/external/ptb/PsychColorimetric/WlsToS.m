function S = WlsToS(wls)
% S = WlsToS(wls)
%
% Converts a list of wavelengths to a [start delta num]
% description.  Wavelengths must be evenly spaced.
%
% 4/17/02  dhb  Handle special case of one wavelength passed.
%               Delta argument is arbitrarily set to 0 for this case.
% 7/11/03  dhb  Handle case the wls is passed in struct format.
% 1/3/12   dhb  Fix check for evenly spaced wavelengths. 

% Check format.
if (isstruct(wls))
	S = [wls.start wls.step wls.numberSamples];
else
	[m,n] = size(wls);
	if (n ~= 1)
	  error('Passed wavelengths is not a column vector');
	end
	
	% Figure out S vector.
	S = zeros(1,3);
	if (n == 1 && m == 1)
		S(1) = wls;
		S(2) = 0;
		S(3) = 1;
	else	
		S(1) = wls(1);
		S(2) = wls(2)-wls(1);
		S(3) = m;
		chk_wls = SToWls(S);
		if ( any(abs(wls-chk_wls) > 1e-6))
		  error('Passed wavelengths are not evenly spaced');
		end
	end
end
