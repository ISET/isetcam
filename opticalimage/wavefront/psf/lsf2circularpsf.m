function psf = lsf2circularpsf(lsf)
% Convert Line Spread Function (lsf) to a circularly symmetric PSF
%
% Calls the Psychtoolbox function LsfToPsf. This is close, but not
% truly exact.  Worth checking at some point where the small
% differences come from.
%
% Inputs
%  lsf: Line spread function, 1D vector.  Must be close to symmetric.
%
% See also
%   PsfToLsf, psf2lsf
%

% Example:
%{
% LSF has to be symmetric around the center point.  Even and odd
% handled differently.  Needs some more comments.
psf = gauss2(8,129,8,129); psf = psf/max(psf(:));
lsf = psf2lsf(psf);
psf2 = LsfToPsf(lsf); psf2 = psf2/max(psf2(:));
ieNewGraphWin([],'tall');
tiledlayout(3,1)
nexttile; plot(psf(:),psf2(:),'o'); identityLine
nexttile; mesh(psf - psf2);
nexttile; mesh(psf2);
%}

psf = LsfToPsf(lsf);

end
