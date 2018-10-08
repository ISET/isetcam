function Ljg = XYZToLjg(XYZ)
% Ljg = XYZToLjg(XYZ)
%
% Convert XYZ (10 degree) to OSA Ljg coordinates.  Formulae
% derived from MacAdam (1974, JOSA, 64, pp. 1691-1702).  Note that
% MacAdam's formulae are in error for the case Y0 less than 30.  The
% correct formulae may be deduced by examing Semelroth's (JOSA, 1970, 16,
% 1685-1689) Eqn. 3, from which MacAdam's incomplete Eqn. 1 is derived.
%
% Note that the above problem is propogated into the formulae
% reported in Wyszecki and Stiles, 2cd edition.  In addition, W+S
% reverse the formulae for G and J and leave out the final
% transformation from scriptL to L.
%
% Finally the formualae published in Brainard (2003, Color appearance and
% color difference specification. In The Science of Color, 2cd edition,
% S. K. Shevell (ed.), Optical Society of America, Washington D.C., 191-216),
% which correct for the above errors, introduce a new mistake: The coefficient
% on B^1/3 for the j coordinate in Eq. 5-2 should be -9.7, rather than the
% the +9.7 that is published.
%
% The output of this routine was verified against the tabulated
% values in W+S, Table I(6.6.4).  These are republished from
% MacAdam (1978, JOSA, 68, 121-130).  See OSAUCSTest.
%
% 3/27/01  dhb  Wrote it.
% 7/14/10  dhb  Added comment that the formulae in my chapter have a typo.
%               The code here is and was correct.

% Define XYZToRGB matrix.
M_XYZToRGB = [0.799 0.4194 -0.1648 ; 
						 -0.4493 1.3265 0.0927 ;
						 -0.1149 0.3394 0.7170];
RGB = M_XYZToRGB*XYZ;
RGB3 = RGB.^(1/3);

% Compute xyY from XYZ
xyY = XYZToxyY(XYZ);

% Compute Y0
x = xyY(1,:);
y = xyY(2,:);
Y = xyY(3,:);
Y0 = Y.* ...
				  (4.4934*(x.^2)+4.3034*(y.^2)-4.276*(x.*y) ...
			    -1.3744*x - 2.5643*y + 1.8103);

% Compute scriptL.  Note that MacAdam does not correctly
% handle the case of Y0 < 30.
scriptL = zeros(size(Y0));
index = find(Y0 > 30);
if (~isempty(index))
	scriptL(index) = 5.9 * ((Y0(index).^(1/3))-(2/3)+0.042*((abs(Y0(index)-30)).^(1/3)));
end
index = find(Y0 <= 30);
if (~isempty(index))
	scriptL(index) = 5.9 * ((Y0(index).^(1/3))-(2/3)-0.042*((abs(Y0(index)-30)).^(1/3)));
end

% Compute C.  Use version that depends on scriptL, as I'm not sure
% the alternate version is correct for Y0 < 30 (I didn't check).
C = scriptL./(5.9*((Y0.^(1/3))-(2/3)));

% Compute L,g,j.
Ljg = zeros(size(XYZ));
Ljg(1,:) = (scriptL-14.4)/sqrt(2);
Ljg(2,:) = C.*([1.7 8 -9.7]*RGB3);
Ljg(3,:) = C.*([-13.7 17.7 -4]*RGB3);

