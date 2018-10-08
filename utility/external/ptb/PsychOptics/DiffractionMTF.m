function mtf = DiffractionMTF(s,pupil,nm)
% mtf = DiffractionMTF(s,pupil,nm)
%
% Compute the diffraction-limited MTF
% for incoherent light.
%
% 	s = spatial frequency in c/deg
% 	pupil = pupil diameter in mm
% 	nm = wavelength in nm
% 
% Goodman, J. W. (1968) Introduction to Fourier Optics. 
% San Francisco: McGraw-Hill.

% 7/11/94		dhb		Wrote it.
% 1/27/00		dgp		Cosmetic.
% 9/8/02		dgp		Cosmetic.

s0 = ComputeDiffLimit(pupil,nm);
mtf = GoodmanDiffrac(s,s0);

