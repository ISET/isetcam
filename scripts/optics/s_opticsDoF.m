% s_opticsDoF
%
% Computing the depth of field for a thin lens with a known focal
% length and aperture.
%
% The depth of field formula is
%
%    DOF = (2 f/# C U^2)/ FocalLength^2
%
% The wikipedia article and the Levoy notes are helfpul.
%
% Here is the wikipedia article:  https://en.wikipedia.org/wiki/Depth_of_field
%
% The ISETCam calculation depends only on the opticsCoC calculation. 
% The circle of confusion calculation has a wonderful history
%
% http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
%
% See also
%  s_opticsCoC
%


%%
ieInit


