function dof = opticsDoF(optics,oDist)
% Depth of field for a thin lens with a known focal length and aperture.
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

%% Calculating depth of field 

% Pick a lens focal length
optics = opticsCreate;
optics = opticsSet(optics,'focal length',0.100);  % meters

% Sweep out object distances and optics fnumbers
oDist = (0.5:0.5:20);
fnumber = (2:1:32);

% Choose a pretty tight criterion for blur (4 super pixels)
CoC = 20e-6;

dof = zeros(numel(oDist),numel(fnumber));
for ii=1:numel(oDist)
    for jj = 1:numel(fnumber)
        optics = opticsSet(optics,'fnumber',fnumber(jj));
        dof(ii,jj) = opticsDoF(optics,oDist(ii),CoC);
    end
end

ieNewGraphWin; imagesc(fnumber,oDist,dof); 
grid on; colormap(hot); colorbar; axis xy;
ylabel('Object distance (m)'); xlabel('F#'); zlabel('DOF (m)');

end



