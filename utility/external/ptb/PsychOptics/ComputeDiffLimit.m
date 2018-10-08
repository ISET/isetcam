function s0 = ComputeDiffLimit(pupil,nm)
% s0 = ComputeDiffLimit(pupil,nm)
%
% Compute the diffraction limit for coherent light.
% (For incoherent light the answer is 2*s0.)
% See page 120 in Goodman. 
% 
% 	"pupil" diameter in mm
% 	"nm" is wavelength in nm
% 	"s0" is highest spatial frequency passed by the pupil in cycles/deg
%
% Goodman, J. W. (1968) Introduction to Fourier Optics. 
% San Francisco: McGraw-Hill. Page 120.
% 
% Goodman's formula involves di, which I think is the distance to the
% image. Goodman's formula gives the limit in
% cycles/unit length.   The formula below gives
% the answer in cycles/degree.

% 7/11/94		dhb		Added this comment.
% 9/8/02		dgp		Cosmetic.

s0 = tan(2*pi/360)*pupil/(2*nm*1e-6);
