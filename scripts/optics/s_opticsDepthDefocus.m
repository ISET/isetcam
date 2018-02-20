%% Calculating depth of field and defocus
%
% For a thin lens, the *defocus* and *depth of field* can be calculated
% using the <https://en.wikipedia.org/wiki/Lens_(optics) Lensmaker's
% Equation.>  This is quite a practical calculation these days, because
% with the advent of high quality plastic lens manufacturing for cell
% phones, the simple thin lens formulae are increasingly practical.
%
% This script generates a series of graphs that illustrate the defocus in
% diopters assuming the sensor is either at the focal length of the lens,
% or further away.  The graphs clarify how the depth of field varies as we
% change the pupil size.
% 
% See also: opticsCreate, opticsDepthDefocus
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
ieInit

%% Use a simple default lens, as one might find in a cell phone camera
optics  = opticsCreate; 
fLength = opticsGet(optics,'focal length','m');
D0      = opticsGet(optics,'power');

% You could try running this with a different focal length
%   optics = opticsSet(optics,'focal length',0.03);
%   fLength = opticsGet(optics,'focal length','m');
%   D0      = opticsGet(optics,'power');

fprintf('Lens power %f and focal length %f (m)\n',D0,fLength);

%% Defocus of an object at different distances from the thin lens

% Image distance is the distance from the center of the thin lens to the
% image.  Normally the sensor is placed in this image plane.
%

% Object distance is the distance to the object.
% Here are the object distance
nSteps = 500; 
objDist = linspace(fLength*1.5,100*fLength,nSteps);

% Calculate defocus (dioptric error) and plot it relative to total lens
% power  (D0).
D  = opticsDepthDefocus(objDist,optics);

vcNewGraphWin;
semilogx(objDist/fLength,D/D0);
title('Sensor at focal length')
xlabel('Distance to object (units: focal length)'); 
ylabel('Relative dioptric error')
grid on
t = sprintf('Focal length %.1f (mm)',fLength*ieUnitScaleFactor('mm'));
legend(t);

% The significance of defocus in terms of blur of the image depends on the
% pupil radius, as well as the dioptric defocus.  We calculate this below
% in discussing depth of field and the Hopkins w20.

%% The image distance as the object distance increases

% We use the opticsDepthDefocus to calculate the image distance
% for different object distances
[tmp, imgDist] = opticsDepthDefocus(objDist,optics);

vcNewGraphWin;
o = objDist*ieUnitScaleFactor('mm');
plot(o,imgDist*ieUnitScaleFactor('mm'));
xlabel('Distance to object (mm)'); ylabel('Image dist (mm)')
line([o(1) o(end)],[fLength fLength]*ieUnitScaleFactor('mm'),'Color','k','linestyle','--')
grid on
t = sprintf('Focal length %.1f (mm)',fLength*ieUnitScaleFactor('mm'));
legend(t)

%%  Plot with respect to focal lengths

vcNewGraphWin;
plot(objDist/fLength,imgDist/fLength);
xlabel('Distance to object (units: focal length)'); ylabel('Image dist (units: focal length)')
grid on
t = sprintf('Focal length %.1f (mm)',fLength*ieUnitScaleFactor('mm'));
legend(t)

%% Defocus with respect to image plane different from focal image plane

% We arrange the distance between the lens and sensor to be a
% little longer than the focal length. In this case objects in
% good focus are closer than infinity.  We calculate the in-focus
% plane in both meters and focal lengths.
s = 1.1;
D = opticsDepthDefocus(objDist,optics,s*fLength);
[v,ii] = min(abs(D));

fprintf('Sensor plane is located %.3f focal lengths behind thin lens.\n',s)
fprintf('In focus object distance (m) from thin lens: %.3f.\n',objDist(ii));
fprintf('In focus object is %.3f focal lengths from thin lens.\n',objDist(ii)/fLength);

% The dioptric error as a function of object distance (in units of focal
% length
vcNewGraphWin;
semilogx(objDist/fLength,D);
xlabel('Object distance (focal lengths)'); 
ylabel('Dioptric error (1/m)')
grid on
t = sprintf('Focal length %.1f (mm)',fLength*ieUnitScaleFactor('mm'));
legend(t)

%% Calculate the OTF using Hopkins' method

% The dioptric error depends both on the object distance and the pupil
% aperture.
p = opticsGet(optics,'pupil radius');

% The w20 parameter is used by Hopkins to predict the amount of
% defocus. Notice that the formula depends on both the relative
% defocus (D and D0) and the pupil size.
%
% For discussion about the Hopkins w20 measure used in the depth of field
% calculation, see humanCore.
%
s = [0.5 1.5 3];              % Scale factor times the pupil radius
leg = cell(1,length(s));      % Legend
w20 = zeros(length(D),length(s));
lType = {'k-','r--','b--','g-'};

% Graph of object distance versus defocus for different pupil
% sizes. The point is that as the pupil size changes, the defocus
% parameter, w20, also changes.
vcNewGraphWin;
for ii=1:length(s)
    w20(:,ii) = (s(ii)*p)^2/2*(D0.*D)./(D0+D);  % See human Core
    semilogx(objDist/fLength,w20(:,ii),lType{ii}); hold on;
    leg{ii} = sprintf('%.2f (mm)',p*s(ii)*ieUnitScaleFactor('mm'));
end
hold off; grid on; legend(leg)
title('Depth of field')
xlabel('Object distance (re: focal length)');
ylabel('Hopkins w20 (defocus)');

%%
