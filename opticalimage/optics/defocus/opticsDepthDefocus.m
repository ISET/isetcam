function [D, imgDist] = opticsDepthDefocus(objDist, optics, imgPlaneDist)
% Compute defocus (D, diopters) for vector of object distances (objDist, meters)
%
%   [D, imgDist] = opticsDepthDefocus(objDist,optics,[imgPlaneDist])
%
% Inputs:
%   objDist:  Vector of object distances (meters)
%   optics:   Optics structure
%   imgPlaneDist:  Image plane distance (meters).  Default is focal length
%
% Outputs:
%   D:  Defocus in diopters
%   imgDist:  The image distance at which the obj at objDist is in focus
%
% The lensmaker's equation specifies the relationship between object and
% image plane distances given the focal length of a thin lens. The
% lensmaker's equation for a thin lens is
%
%    1/objDist + 1/imgDist = 1/focalLength
%
% See the thin lens equation description from Wikipedia.
% http://en.wikipedia.org/wiki/Lens_(optics)
%
% The equation can be used for various purposes, including specifying the
% defocus of an object in various imaging conditions.
%
% For example,
%   * Objects at infinity are imaged in the focal plane.
%   * If the image plane is at the focal length, then closer objects will
%   be in defocus and we can assess the degree of defocus.  These will all
%   be positive.
%   * If the image plane distance differs from the focal length, we can
%   compute the defocus as a function of object distance. Object distances
%   closer and further than the in-focus distance will have negative and
%   positive defocus.
%
% There are additional lensmaker's formulae for general lenses with
% specified curvature and index of refraction measurements.  There are also
% depth of field formulae in Wikipedia and elsewhere.
%
% Examples:
%    optics = opticsCreate; fLength = opticsGet(optics,'focal length','m');
%    nSteps = 500; objDist = linspace(fLength*1.5,50*fLength,nSteps);
%    D0 = opticsGet(optics,'power');
%
% Show defocus relative to total lens power
%    figure(1)
%    [D, imgDist] = opticsDepthDefocus(objDist,optics);
%    plot(objDist,D/D0);
%    xlabel('Distance to object (m)'); ylabel('Relative dioptric error')
%
% Object and image distances
%    figure(1)
%    [D, imgDist] = opticsDepthDefocus(objDist,optics);
%    plot(objDist,imgDist);
%    xlabel('Distance to object (m)'); ylabel('Image dist (m)')
%    line([objDist(1) objDist(end)],[fLength fLength],'Color','k','linestyle','--')
%
% Defocus with respect to image plane different from focal image plane
%    figure(1)
%    [D, imgDist] = opticsDepthDefocus(objDist,optics,2*fLength);
%    plot(objDist/fLength,D);
%    xlabel('Distance to object (re: Focal length)'); ylabel('Dioptric error (1/m)')
%    [v,ii] = min(abs(D)); fprintf('In focus objDist:  %.3f re fLength %.3f\n',objDist(ii),objDist(ii)/fLength);
%    figure(1)
%
% See also:  opticsDefocusedMTF, defocusMTF, humanCore
%
% Copyright ImagEval Consultants, LLC, 2010.

% Simple alegebraic observations about the lensmaker's equation
%
%  It is convenient to express the object distance as a multiple of focal
%  lengths, objDist = N*fLength.  In that case
%
%   1/imgDist = 1/fLength - 1/(N*fLength)
%   1/imgDist = (1/fLength) (1 - 1/N)
%   imgDist   = fLength/(1 - (1/N))
%   imgDist   = fLength / ((N - 1)/N)
%   imgDist   = fLength * (N/(N-1))
%
% This expresses how the imgDist approaches the focal length as N gets
% large. The difference between the image plane and the focal plane is
%
%   errDist = fLength - fLength * (N/(N-1))
%   errDist = fLength * (1 - (N/(N-1))
%
% The blurring caused by this difference in best image plane depends on the
% pupil aperture as well as the focal length.  For small pupil apertures,
% there is less of a penalty in defocus (e.g., a pinhole).  The
% significance of the pupil aperture is captured in other (see, e.g.
% humanCore and opticsReducedSFandW20).
%

if ieNotDefined('objDist'), error('No distance specified'); end
if ieNotDefined('optics'), optics = vcGetObject('optics'); end
fLength = opticsGet(optics, 'focal length', 'm');

if ieNotDefined('imgPlaneDist'), imgPlaneDist = fLength; end
if imgPlaneDist < fLength, error('Virtual image: img plane closer than fLength - not computed'); end

% Compute the image distance for various object distances

% Lensmaker's equation for a thin lens can be written:
%
%    1/imgDist = (1/fLength - 1./objDist);
% so
%    imgDist = (1/fLength - 1./objDist).^-1;
% and
imgDist = (fLength * objDist) ./ (objDist - fLength);
% figure(1); plot(objDist,imgDist)
% xlabel('Distance to object (m)'); ylabel('Distance to image plane (m)')
% line([objDist(1) objDist(end)],[fLength fLength],'Color','k','linestyle','--')
%  figure(1)

% Compute the defocus - this is the dioptric power of a lens that would
% shift the image from its current distance (imgDist) to the desired image
% plane (imgPlaneDist).
D = (1 ./ imgDist) - (1 / imgPlaneDist);

%  figure(1); plot(objDist,D)
%  xlabel('Distance to object (m)'); ylabel('Dioptric error (1/m)')
%  figure(1)

return
