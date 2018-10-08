function [f,g] = LjgToXYZFun(XYZ,Ljg)
% [f,g] = LjgToXYZFun(XYZ,Ljg)
%
% Optimization function for LjgToXYZ numerical
% search.  Not vectorized.
%
% 3/27/01  dhb  Wrote it.

% Convert back.
Ljg1 = XYZToLjg(XYZ);

% Handle case where XYZ is so weird that
% an imaginary value is returned.
if (any(~isreal(Ljg1)))
	sdiff = (abs(Ljg1)-Ljg).^2;
	f = sum(sdiff);
	g = 10;
else
	sdiff = (Ljg1-Ljg).^2;
	f = sum(sdiff);
	g = -XYZ;
end
