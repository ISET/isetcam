function lsf = GeislerLSFMinutes(distance)
%GeislerLSFMinutes  Compute Geisler estimate of 2mm pupil human LSF
%   lsf = GeislerLSFMinutes(distance)
%
%   Compute the 2mm pupil LSF from Geisler (1984, JOSA A, 1, pp. 775-782),
%   Figure 1. This is also used in Banks, Geisler & Bennett (1987,Vision
%   Research, 27, 1915-1924).
%
%   They give the parameters of a sum of Gaussians LSF as a function of
%   passed distance.  Distance passed in minutes of arc.
%
%   Return is normalized to a maximum of 1.
%
%   See also WestPSFMinutes, WestLSFMinutes, LsfToPsf, PsfToLsf

weight1 = 0.684;
weight2 = 0.587;
sigma1 = 0.443;
sigma2 = 2.035;
lsf = weight1*normpdf(distance,0,sigma1) + ...
       weight2*normpdf(distance,0,sigma2);
  
lsf = lsf/max(lsf(:));
