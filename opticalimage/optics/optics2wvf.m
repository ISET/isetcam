function wvf = optics2wvf(optics)
% Create a wvf from the optics parameters
%
% Synopsis
%   wvf = optics2wvf(optics)
%
% Brief
%  This function only matches the Zernike coefficients, wavelength, and
%  pupil diameter.  It ignores parameters such as the Stiles Crawford
%  and others.  The wvfCompute is NOT run.
%
% Input
%  optics
%
% Key/val
%  N/A
%
% Output
%  wvf
%
% Description
%    We think we handled the pupil diameter cases correctly.  The z
%    coeffs are defined with respect to some diameter (measured
%    pupil). The calculation we are doing is with respect to the
%    diameter that is stored in the optics.  We think they can diverge
%    and that this is handled correctly by wvfCompute.
%
% See also
%   wvf2optics

% Match the wavelength and Zernike coefficients
wvf = wvfCreate('wave',optics.OTF.wave,'zcoeffs',optics.zCoeffs);

% Pupil diameter for the circle where the zCoeffs are defined
wvf = wvfSet(wvf,'measured pupil diameter',optics.zDiameterMM);

% Only allows meter now. - ZL
wvf = wvfSet(wvf, 'focal length', opticsGet(optics, 'focal length', 'mm'), 'mm');

% Pupil diameter that we are currently calculation
wvf = wvfSet(wvf,'calc pupil diameter',opticsGet(optics,'diameter','mm'));

end
