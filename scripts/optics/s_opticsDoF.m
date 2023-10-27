% Depth of field for a thin lens with a known focal length and aperture.
%
% The depth of field formula from Wikipedia is
%
%    DOF = (2 f/# C U^2)/ FocalLength^2
%
% Here is the wikipedia article:  https://en.wikipedia.org/wiki/Depth_of_field
%
% It is also possible to calculate the DOF by using the opticsCoC
% calculation. We do both calculations here.  You can try varying the 
%
% See also
%  s_opticsCoC
%

% The circle of confusion calculation has a wonderful history
%
% http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
%

%%
ieInit

%% This matches one of the cases in s_opticsCoC

fN = 2;      % Dimensionless
fL = 0.100;  % Meters

optics = opticsCreate;
optics = opticsSet(optics,'fnumber',fN);
optics = opticsSet(optics,'focal length',fL);  % meters

% Object distance
oDist = 2;  % Meters

% CoC criterion.  You should have a look at the plotted CoC to make sure
% that you have a reasonable size CoC.  That would be one where the curve
% actually gets there!
cocDiam = 0.0005;  % Meters

% This depth of field is about 0.36 meters
dof = opticsDoF(optics,oDist,cocDiam);

% And that matches the with of the curve reasonably
[coc,xDist] = opticsCoC(optics,oDist,'nsamples',200);
ieNewGraphWin;
plot(xDist,coc); grid on;
set(gca,'ylim',[0 2]*1e-3,'xlim',[0 5]);
thisLine = line([0 5],[cocDiam,cocDiam]);
thisLine.Color = 'k';
thisLine.LineStyle = '--';
xlabel('Object distance (m)'); ylabel('CoC diameter (m)');

%% Calculating depth of field from CoC

[~,idx1] = min(abs(coc(1:100) - cocDiam));
[~,idx2] = min(abs(coc(101:end) - cocDiam)); idx2 = idx2 + 100;
cocDOF = xDist(idx2) - xDist(idx1);

%%  Make an image showing the dof for a range of F# and Obj Distances

fprintf('Formula based DOF = %.2f m\n',dof);
fprintf('Interpolated from CoC DOF = %.2f m\n',cocDOF);
fprintf('These are usually close!\n');

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





