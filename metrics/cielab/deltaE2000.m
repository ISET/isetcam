function [de00, errComponents] = deltaE2000(Labstd, Labsample, KLCH)
%Compute CIE delta E 2000 color error metric
%
%    [de00, errComponents] = deltaE2000(Labstd,Labsample, KLCH )
%
% ImagEval comments --
%
%   The CIE delta E standard is a fundamental tool of color science.  The
%   metric is described in a wide variety of textbooks.  It has gone
%   through a series of refinements over the years.  This code is the
%   CIEDE2000.
%
%   K is a 3 vector, in the form [kL, kC, kH]. k =[1 1 1] for the basic
%   conditions (uniform surround field with L*=50, 1000lx illuminance,
%   homogeneous stimulus >4 degree visual angle, color difference between
%   0-5 CIELAB units). In the textile industry kL is commonly set to 2.
%   Default k is [1 1 1];
%
%   The Labstd and Labsample matrices contain corresponding pairs of CIELAB
%   values.  The difference between these is the error measure.  The CIELAB
%   values are computed from CIE XYZ measurements using standard lab
%   equipment.
%   
%   ImagEval added a new return term (errComponents) that contains the
%   separate luminance, chromatic, and hue error terms.  These components,
%   which are scaled and combined 
%
%   The original authors and a reference source for this code are cited
%   below. The comments in the original source code follow:
%
% Original comments --
%
% Compute the CIEDE2000 color-difference between the sample between a
% reference with CIELab coordinates Labsample and a standard with CIELab
% coordinates Labstd
%
% The function works on multiple standard and sample vectors too provided
% Labstd and Labsample are K x 3 matrices with samples and standard
% specification in corresponding rows of Labstd and Labsample The optional
% argument KLCH is a 1x3 vector containing the the value of the parametric
% weighting factors kL, kC, and kH these default to 1 if KLCH is not
% specified.
%
% Based on the article:
% "The CIEDE2000 Color-Difference Formula: Implementation Notes,
% Supplementary Test Data, and Mathematical Observations,", G. Sharma,
% W. Wu, E. N. Dalal, submitted to Color Research and Application,
% January 2004.
%
% Code is available at http://www.ece.rochester.edu/~/gsharma/ciede2000/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

de00 = [];

%% Error checking to ensure that sample and Std vectors are of correct sizes
v=size(Labstd); w = size(Labsample);
if ( v(1) ~= w(1) || v(2) ~= w(2) )
    disp('deltaE00: Standard and Sample sizes do not match');
    return
end % if ( v(1) ~= w(1) | v(2) ~= w(2) )
if ( v(2) ~= 3)
    disp('deltaE00: Standard and Sample Lab vectors should be Kx3  vectors');
    return
end

%% Parametric factors
if (nargin <3 )
    % Values of Parametric factors not specified use defaults
    kl = 1; kc=1; kh =1;
else
    % Use specified Values of Parametric factors
    if ( (size(KLCH,1) ~=1) || (size(KLCH,2) ~=3))
        disp('deltaE00: KLCH must be a 1x3  vector');
        return;
    else
        kl =KLCH(1); kc=KLCH(2); kh =KLCH(3);
    end
end

%%  Main computation
Lstd = Labstd(:,1)';
astd = Labstd(:,2)';
bstd = Labstd(:,3)';
Cabstd = sqrt(astd.^2+bstd.^2);

Lsample = Labsample(:,1)';
asample = Labsample(:,2)';
bsample = Labsample(:,3)';
Cabsample = sqrt(asample.^2+bsample.^2);

Cabarithmean = (Cabstd + Cabsample)/2;

% Some weird stuff ....
G = 0.5* ( 1 - sqrt( (Cabarithmean.^7)./(Cabarithmean.^7 + 25^7)));

apstd = (1+G).*astd; % aprime in paper
apsample = (1+G).*asample; % aprime in paper
Cpsample = sqrt(apsample.^2+bsample.^2);
Cpstd = sqrt(apstd.^2+bstd.^2);

% Compute product of chromas and locations at which it is zero for use later
Cpprod = (Cpsample.*Cpstd);
zcidx = find(Cpprod == 0);


%% Ensure hue is between 0 and 2pi
% NOTE: MATLAB already defines atan2(0,0) as zero but explicitly set it
% just in case future definitions change
hpstd = atan2(bstd,apstd);
hpstd = hpstd+2*pi*(hpstd < 0);  % rollover ones that come -ve
hpstd(find( (abs(apstd)+abs(bstd))== 0) ) = 0;
hpsample = atan2(bsample,apsample);
hpsample = hpsample+2*pi*(hpsample < 0);
hpsample(find( (abs(apsample)+abs(bsample))==0) ) = 0;

%% Luminance and chrominance terms
dL = (Lsample-Lstd);
dC = (Cpsample-Cpstd);

%% Computation of hue difference - which is more complex
dhp = (hpsample-hpstd);
dhp = dhp - 2*pi* (dhp > pi );
dhp = dhp + 2*pi* (dhp < (-pi) );

% set chroma difference to zero if the product of chromas is zero
dhp(zcidx ) = 0;

% Note that the defining equations actually need
% signed Hue and chroma differences which is different
% from prior color difference formulae

dH = 2*sqrt(Cpprod).*sin(dhp/2);
%dH2 = 4*Cpprod.*(sin(dhp/2)).^2;

% weighting functions
Lp = (Lsample+Lstd)/2;
Cp = (Cpstd+Cpsample)/2;

% This is equivalent to that in the paper but simpler programmatically.
% Note average hue is computed in radians and converted to degrees only
% where needed
hp = (hpstd+hpsample)/2;

% Identify positions for which abs hue diff exceeds 180 degrees
hp = hp - ( abs(hpstd-hpsample)  > pi ) *pi;

% rollover ones that come -ve
hp = hp + (hp < 0)*2*pi;

% Check if one of the chroma values is zero, in which case set
% mean hue to the sum which is equivalent to other value
hp(zcidx) = hpsample(zcidx)+hpstd(zcidx);

% This is a mystery to me ... someone needs to comment this stuff -
% ImagEval
Lpm502 = (Lp-50).^2;
Sl = 1 + 0.015*Lpm502./sqrt(20+Lpm502);
Sc = 1+0.045*Cp;
T = 1 - 0.17*cos(hp - pi/6 ) + 0.24*cos(2*hp) + 0.32*cos(3*hp+pi/30) ...
    -0.20*cos(4*hp-63*pi/180);
Sh = 1 + 0.015*Cp.*T;
delthetarad = (30*pi/180)*exp(- ( (180/pi*hp-275)/25).^2);
Rc =  2*sqrt((Cp.^7)./(Cp.^7 + 25^7));
RT =  - sin(2*delthetarad).*Rc;

klSl = kl*Sl;
kcSc = kc*Sc;
khSh = kh*Sh;

% The CIE 00 color difference
de00 = sqrt( (dL./klSl).^2 + (dC./kcSc).^2 + (dH./khSh).^2 + RT.*(dC./kcSc).*(dH./khSh) );

% The components of the dE2000 error are returned here.  We might minimize
% on just the hue, chrominance or luminance term.
if nargout > 1
    errComponents.dL = (dL./klSl);
    errComponents.dC = (dC./kcSc);
    errComponents.dH = (dH./khSh);
    errComponents.RT = RT.*(dC./kcSc).*(dH./khSh);
end

return