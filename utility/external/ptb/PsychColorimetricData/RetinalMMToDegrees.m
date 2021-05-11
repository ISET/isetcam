function degs = RetinalMMToDegrees(mm, eyeLengthMM, fulltrig)
% degs = RetinalMMToDegrees(mm,eyeLengthMM,[fulltrig])
%
% Convert fovela extent in mm of retina in the fovea to degrees of visual
% angle.
%
% This is implemented by default as a simple linear scaling based on the
% appropriate conversion for small angles.  It does not take the
% non-linearity of the tangent for larger angles into account, nor the
% actual shape and optics of the eye.  Interestingly, although the trig
% calculation would be exactly correct for pinhole camera and a planar
% retina oriented orthogonal to the optical axis, it deviates more from
% what the real eye does than the linear approximation.
%
% In addition, this routine is implemented as the exact inverse of what
% DegreesToRetinalMM does, rather than having the two routines do
% independent forward and backward linear approximations.
%
% If optional argument fulltrig is passed as true (it is false by default),
% then it uses the inverse tangent on the actuall passed mm.  This was the
% behavior prior to July 2015. This behavior does not exactly self invert
% with DegreesToRetinalMM.  Nor does it account for the shape and optics of
% the eye.
%
% Routine EyeLength returns posterior nodal eye lengths for various
% species and sources.  Use 'Human' and 'Rodieck' to get the eye
% length implicit in RetinalEccentricityMMToDegrees and
% DegreesToRetinalEccentricityMM for human, and similarly 'Rhesus' and
% 'PerryCowey' for rhesus.
%
% See also: DegreesToRetinalMM, EyeLength, RetinalEccentricityMMToDegrees, DegreesToRetinalEccentricityMM
%
% 7/15/03  dhb  Wrote it.
% 7/01/15  dhb  Update comments, change default behavior, preserve old behavior optionally.

% Default args
if (nargin < 3 || isempty(fulltrig))
    fulltrig = false;
end

if (~fulltrig)
    factor = 1 / DegreesToRetinalMM(1, eyeLengthMM);
    degs = factor * mm;
else
    tanarg = (mm / 2) / eyeLengthMM;
    degs = 2 * (180 / pi) * atan(tanarg);
end