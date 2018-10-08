function trolands = LumToTrolands(luminance,pupilAreaMM)
% trolands = LumToTrolands(luminance,pupilAreaMM)
%
% Convert luminance in photopic/scotopic cd/m2 to corresponding
% trolands.
%
% 7/29/03  dhb  Wrote it.

trolands = luminance*pupilAreaMM;
