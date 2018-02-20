% This script converts the normalized stockman fundamentals to a form that
% includes the peak absorption efficiency.  It is useful for calculating
% the absolute number of photons absorbed by a sensor.
% 
% load stockman;
% 
% 
% % Rodieck (page 473) says that the percent of photons isomerized by the
% % different cones classes are: (27,26,7) for L,M and S, respectively.  The
% % rod photoisomerization percentage is 23%.
% 
% data = data*diag([.27,.26,.07]);
% 
% commentOrig = comment;
% newComment = ...
%     'Corrected for peak optical transmittance of the ocular media and the internal QE of the isomerization process.';
% comment = [commentOrig, newComment];
% chdir([isetRootPath,filesep,'vCamera-Data',filesep,'human']);
% save stockmanAbs data wavelength comment