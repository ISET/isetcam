%% The circle of confusion
%
% A large reason for image blur arises from simple geometry - the
% image point is not at the focal distance. Geometric blur is
% quantified by the size of the *circle of confusion*, which is the
% diameter of a point image. The function *opticsCoC* calculates the
% circle of confusion.
%
% We semilogy the circle of confusion here for different F#s and Focal
% length lenses.
%
% The depth of field is calculated from the CoC.  One picks a
% criterion size for the CoC and finds the near and far points at the
% size.  The distance between them is the depth of field.  This DoF
% will vary with the optics and also with the distance of the point
% from the lens.
%
% For a description of the Circle of Confusion [see this Wikipedia
% page](http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field)
% It links to the original wonderful article describing the geometry.
%
% See also:
%   opticsCoC, opticsDoF, s_opticsDoF
%

%%
ieInit

%% Calculate the circle of confusion diameter for different points
lineStyle = {'-','--'};
oDist = [0.5 3];  % meters

%%
for oo = [1,2]

    % A 50 mm f# 2 lens
    fN = 2;
    fL = 0.050;
    optics = opticsCreate;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm','n samples',50);

    hdl = ieNewGraphWin;

    % Plot the circle diameter as a function of distance
    semilogy(xDist,c,'b','LineStyle',lineStyle{oo}); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)');    

    %% Shrink the aperture

    fN = 8;
    fL = 0.050;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm','n samples',50);

    % Plot the circle diameter as a function of distance
    hold on;
    semilogy(xDist,c,'r','LineStyle',lineStyle(oo)); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)')    

    %% Keep the same F# but change to focal length

    fN = 2;
    fL = 0.100;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm','n samples',50);

    % Plot the circle diameter as a function of distance
    hold on;
    semilogy(xDist,c,'k','LineStyle',lineStyle(oo)); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)')

    legend({'F# 2 FL 50 mm','F# 8 FL 50 mm','F# 2 FL 100 mm'});
    title(sprintf('Circle of Confusion - Focus distance %.1f m',oDist(oo)));
    drawnow;
end

%%

