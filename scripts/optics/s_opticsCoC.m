%% The circle of confusion
%
% A large reason for image blur arises from simple geometry - the image
% point is not at the focal distance. Geometric blur is quantified by the
% size of the *circle of confusion*, which is the diameter of a
% point image. The function *opticsCoC* calculates the circle of confusion.
%
% We plot the circle of confusion here for different F#s and Focal length
% lenses.
%
% The depth of field is calculated from the CoC.  One picks a criterion
% size for the CoC and finds the near and far points at the size.  The
% distance between them is the depth of field.  This DoF will vary with the
% optics and also with the distance of the point from the lens.
%
% For a description of the
% <http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
% circle of confusion see this Wikipedia page>. That page links to
% the original wonderful article describing the geometry.
%
% See also:  
%   opticsCoC, opticsDoF
%

%%
ieInit

%% Calculate the circle of confusion diameter for different points
lineStyle = {'-','--'};
oDist = [0.5 3];  % meters
hdl = ieNewGraphWin;

%%
for oo = 1:numel(oDist)
    
    % A 50 mm f# 2 lens
    fN = 2;
    fL = 0.050;
    optics = opticsCreate;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm');

    % Plot the circle diameter as a function of distance
    plot(xDist,c,'b','LineStyle',lineStyle{oo}); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)')

    %% Shrink the aperture

    fN = 8;
    fL = 0.050;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm');

    % Plot the circle diameter as a function of distance
    hold on;
    plot(xDist,c,'r','LineStyle',lineStyle(oo)); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)')

    %% Keep the same F# but change to focal length

    fN = 2;
    fL = 0.100;
    optics = opticsSet(optics,'fnumber',fN);
    optics = opticsSet(optics,'focal length',fL);

    % Set the distance to the inplane focus
    [c, xDist] = opticsCoC(optics,oDist(oo),'unit','mm');

    % Plot the circle diameter as a function of distance
    hold on;
    plot(xDist,c,'k','LineStyle',lineStyle(oo)); grid on;
    xlabel('Object distance (m)');
    ylabel('Diameter of circle of confusion (mm)')

    legend({'F# 2 FL 50 mm','F# 8 FL 50 mm','F# 2 FL 200 mm'});

    title('Circle of Confusion');
    
    set(gca,'xlim',[0 5],'ylim',[0 5]);

end

%%

