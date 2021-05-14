%% Illustrate Camera basics from Stereo Tutorial
%
% In process ... trying to make stereo calculations for a class tutorial.
% Need to get this right and then expand to epipolar geometry and such.
%
% Copyright Imageval LLC, 2016

%%
ieInit

%% Rotate points in 3-space.

% Just testing the model and matrices
%
% Suppose the points are in
% XYZ = randi(20,9,3);
% XYZ = [-6 -6 -6; -3 -3 -3; 0 0 0; 3 3 3; 6 6 6; 9 9 9];
% XYZ = [ 3 3 3; 6 6 6; 9 9 9];

% [X,Y,Z] = sphere(20);
% XYZ = [X(:),Y(:),Z(:)];

% vcNewGraphWin;
% plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'ro-');
% angleList = [pi/4 0 0];
% rXYZ = (rotationMatrix3d(angleList)*XYZ')';
% hold on;
% plot3(rXYZ(:,1),rXYZ(:,2),rXYZ(:,3),'bo-');
% grid on; axis equal
% xlabel('X'); ylabel('Y'); zlabel('Z');

%% Pinhole camera
%
% General camera matrix tutorial
%  https://en.wikipedia.org/wiki/Camera_matrix
%
% In this camera, the sensor plane is perpendicular to the Z-axis.
%
%  https://en.wikipedia.org/wiki/Pinhole_camera_model
%

% Make points that are on the proper side of the Z-plane (away from the
% center of the camera.
f = 4;
XYZ = randi(20,3,9);
XYZ(1,:) = XYZ(1,:) - mean(XYZ(1,:));
XYZ(2,:) = XYZ(2,:) - mean(XYZ(2,:));
XYZ(3,:) = XYZ(3,:) + f;

% This is the projection calculation directly for a pinhole camera, as per
% the wikipedia page
uv = bsxfun(@times, XYZ(1:2,:), f ./ XYZ(3,:));

% Show the 3d points, the points on the z-plane which is the sensor, and
% the lines through them pointing at the center.
vcNewGraphWin;
plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:),'bo');
hold on;
plot3(uv(1,:),uv(2,:),f*ones(1,size(uv,2)),'rx');
for ii=1:size(XYZ,2)
    line([0 ,XYZ(1,ii)],[0,XYZ(2,ii)],[0, XYZ(3,ii)]);
end
grid on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z');
line([0 0],[0 0],[-5 20],'color','g','linewidth',3)

%% Now extend this calculation to the general camera matrix formulation

% Put the points in homogeneous coordinates, and specify the center
% position
XYZh = [XYZ;ones(1,size(XYZ,2))];
vcNewGraphWin; plot3(XYZh(1,:),XYZh(2,:),XYZh(3,:),'bo');
hold on; plot3(C(1),C(2),C(3),'bx');
grid on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z');

% If the center is not at 000 we would have to translate like this
C = [0 0 0]';    % Center
T = zeros(4,4);
T(1:3,1:3) = eye(3,3);
T(:,4) = [-1*C(:);1];
tmp = (T*XYZh);
hold on; plot3(tmp(1,:),tmp(2,:),tmp(3,:),'go');
hold on; plot3(0,0,0,'gx');
grid on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z');

% If the plane is not Z, but rotated, we would rotate like this
angleList = [0,0,0];
R = zeros(4,4);
R(1:3,1:3) = rotationMatrix3d(angleList);
R(4,4) = 1;
tmp = (R*tmp);
hold on; plot3(tmp(1,:),tmp(2,:),tmp(3,:),'ro');
hold on; plot3(0,0,0,'rx');
grid on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z');

% Project onto the sensor plane.
P = zeros(3,4);
P(1:3,1:3) = eye(3,3);
tmp = (P*tmp);

% And deal with the camera intrinsics (focal length, really)
K = eye(3);
K(1,1) = f; K(2,2) = f;
tmp = (K*tmp);

vcNewGraphWin;
plot3(tmp(1,:),tmp(2,:),f*ones(1,size(uv,2)),'rx');
grid on; axis equal

%%
cMatrix = (K*P*R*T);
%% Still not working for translation and maybe other stuff

% Original points and camera center
vcNewGraphWin; plot3(XYZh(1,:),XYZh(2,:),XYZh(3,:),'bo');
hold on; plot3(C(1),C(2),C(3),'bx');
grid on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z');

% Camera matrix followed by homogeneous coordinate
XYZp = (cMatrix*XYZh);
XYZp = bsxfun(@times,XYZp,1./XYZp(3,:));

% The points are in the Z=f plane
hold on; plot3(XYZp(1,:),XYZp(2,:),f*XYZp(3,:),'kx');
grid on; axis equal
xlabel('X'); ylabel('Y');

% Here are the lines from the points to the center
for ii=1:size(XYZ,2)
    line([C(1) ,XYZh(1,ii)],[C(2),XYZh(2,ii)],[C(3), XYZh(3,ii)]);
end


