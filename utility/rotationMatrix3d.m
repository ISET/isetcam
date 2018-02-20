function rMatrix = rotationMatrix3d(angleList, scale)
% Returns a 3x3 rotation matrix, possibly with a scale factor
%
%     rMatrix = rotationMatrix3d(angleList, [scale])
%
% angleList:  3 vector of (x,y,z) rotations in radians
% scale:      1 vector or 3 vector of x,y,z scale factors
%
% Returns
%  rMatrix: 3x3 rotation matrix corresponding to the angular rotations
% around the x,y,z axes (in that order) specified in angleList.
%
% Optionally applies a scale factor, either a global scale (if 'scale' is a
% scalar), or separate X, Y and Z scales if 'scale' is 1x3.
%
% http://www.euclideanspace.com/maths/algebra/matrix/orthogonal/rotation/
%
% The returned rotation matrix is
%
%   rMatrix = RotX * RotY * RotZ * scale;
%
% so the rotated points = rMatrix*[3xN];
%
% AUTHOR: Wade 091603
%         2003.09.16 Dougherty added scale
% (c) Stanford VISTA Team

angleList=angleList(:);
if (length(angleList)~=3), error('Must have 3 angles in the angle list'); end
if(~exist('scale','var') || isempty(scale)), scale = 1; end

if(length(scale)==1),     scale = eye(3)*scale;
elseif(length(scale)==3), scale = [scale(1) 0 0; 0 scale(2) 0; 0 0 scale(3)];
else                      error('Scale must be a scalar or 1x3.');
end

tx=angleList(1);
ty=angleList(2);
tz=angleList(3);

% Compute the individual matrices for clarity
RotX=[ 1 	0 	0;...
    0 	cos(tx) 	-sin(tx);...
    0 	sin(tx) 	cos(tx)];

RotY=[ cos(ty) 	0 	-sin(ty);...
    0       1   0;...
    sin(ty) 0 cos(ty)];

RotZ=[cos(tz)  -sin(tz)  0;...
    sin(tz)  cos(tz)  0;...
    0     0  1];

% This is what we return;
rMatrix=RotX*RotY*RotZ*scale;

return