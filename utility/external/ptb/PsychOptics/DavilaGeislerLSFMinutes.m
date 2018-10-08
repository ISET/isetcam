function lsf = DavilaGeislerLSFMinutes(distance)
%DavilaGeislerLSFMinutes  Compute Davila/Geisler estimate of 3mm pupil human LSF
%   lsf = DavilaGeislerLSFMinutes(distance)
%
%   Compute the 3mm pupil LSF from Davila and Geisler (1991, Vision
%   Research, 31, 1369-1380), Figure 1. They give the parameters of a sum
%   of Gaussians LSF as a function of passed distance.  Distance passed in
%   minutes of arc.
%
%   Return is normalized to a maximum of 1.
%
%   See also GeislerLSFMinutes, WestPSFMinutes, WestLSFMinutes, LsfToPsf, PsfToLsf

weight1 = 0.409;
sigma1 = 0.417;
sigma2 = 1.42;
lsf = weight1*normpdf(distance,0,sigma1) + ...
       (1-weight1)*normpdf(distance,0,sigma2);
  
lsf = lsf/max(lsf(:));
