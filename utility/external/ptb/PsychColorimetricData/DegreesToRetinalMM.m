function mm = DegreesToRetinalMM(degs,eyeLengthMM,fulltrig)
%  mm = DegreesToRetinalMM(degs,eyeLengthMM,[fulltrig])
%
% Convert foveal extent in degrees to mm of retina in the fovea.
%
% This is implemented by default as a simple linear scaling based on the
% appropriate conversion for small angles.  It does not take the
% non-linearity of the tangent for larger angles into account, nor the
% actual shape and optics of the eye.  Interestingly, although the trig
% calculation would be exactly correct for pinhole camera and a planar
% retina oriented orthogonal to the optical axis, it deviates more from
% what the real eye does than the linear approximation.
%
% In addition, this routine and RetinalMMToDegrees are implemented as the
% exact inverses of each other in this default mode.
%
% If optional argument fulltrig is passed as true (it is false by default),
% then it uses the inverse tangent on the actuall passed mm.  This was the
% behavior prior to July 2015. This behavior does not exactly self invert
% with RetinalMMToDegrees.  Nor does it account for the shape and optics of
% the eye.
%
% Routine EyeLength returns posterior nodal eye lengths for various species
% and sources.  Use 'Human' and 'Rodieck' to get the eye lenght implicit in
% RetinalEccentricityMMToDegrees and DegreesToRetinalEccentricityMM for
% human, and similarly 'Rhesus' and 'PerryCowey' for rhesus.
%
% See also: RetinalMMToDegrees, EyeLength, RetinalEccentricityMMToDegrees, DegreesToRetinalEccentricityMM
%
% 7/15/03  dhb  Wrote it.
% 7/01/15  dhb  Update comments, change default behavior, preserve old behavior optionally.

% Default args
if (nargin < 3 || isempty(fulltrig))
    fulltrig = false;
end

if (~fulltrig)
    factor = 2*tan((pi/180)*1/2)*eyeLengthMM;
    mm = factor*degs;
else  
    mm = 2*tan((pi/180)*degs/2)*eyeLengthMM;
end
