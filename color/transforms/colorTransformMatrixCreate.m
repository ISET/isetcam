%% Script for creating  color matrix transforms
%
%
%  Stockman
%

%% Stockman and XYZ
wave = 400:5:700;
xyz = ieReadSpectra('XYZ',wave);
stock = ieReadSpectra('Stockman',wave);

vcNewGraphWin
plot(wave,stock)
plot(wave,xyz)

% xyz2sto
% xyz*T = sto; T = inv(xyz)*sto = xyz \ sto
T = xyz \ stock;
pred = xyz*T;
plot(pred(:),stock(:),'.'); grid on; axis equal

% sto2xyz
% sto*T = xyz; T = inv(sto)*xyz = sto \ xyz
T = stock \ xyz;
pred = stock*T;
plot(pred(:),xyz(:),'.'); grid on; axis equal

% These aren't perfect inverses because the data aren't within a linear
% transformation of one another

T1 = colorTransformMatrix('stockman 2 xyz');
T2 = colorTransformMatrix('xyz 2 stockman');
T1*T2

%% End
