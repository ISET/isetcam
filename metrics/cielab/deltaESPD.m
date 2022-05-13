%% Examples of computing the metric to compare two SPDs
%
% 
%   Suppose s1 and s2 are SPD in energy
%
%

%
% function ang = spdAngles(u,v);
%   ang = atan2(norm(cross(u,v)),dot(u,v));
% end
%

% this is just 
% How do we set the white point?
%
% dE = spdDE(s1,s2,'white point',w);
%{
 wave = 400:10:700;
 s1 = daylight(wave,6500);
 s2 = daylight(wave,4500);
 w = s1;
 ieNewGraphWin; plot(wave,s1,'-',wave,s2,'--');
%}

function dE = deltaESPD(s1,s2,varargin)
% Calculate the deltaE between two spectra
%
% Default white point is s1?  Or a constant energy7?

W =  ieXYZFromEnergy(w(:)',wave);
X1 = ieXYZFromEnergy(s1(:)',wave);
X2 = ieXYZFromEnergy(s2(:)',wave);

X1LAB = ieXYZ2LAB(X1,W);
X2LAB = ieXYZ2LAB(X2,W);
dE = norm(X1LAB - X2LAB);
