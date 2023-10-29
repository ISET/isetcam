function [MTF, PSF, LSF] = ijspeert(age, p, m, q, phi)
% Calculate the optical MTF or PSF or LSF of the human eye
%
% Syntax:
%   [MTF, PSF, LSF] = Ijspeert(age, p, m, q, phi)
%
% Description:
%    The formula is a function of various parameters included in the inputs
%    section below. The formula uses those parameters to make calculations
%    on the human eye resulting in either the MTF, PSF, or LSF.
%
%    This function contains examples of usage inline. To access, type 'edit
%    ijspeert.m' into the Command Window.
%
% Inputs:
%    age - Numeric. The age of person in years.
%    p   - Numeric. The pupil diameter in mm.
%    m   - Numeric. The pigmentation parameter, from one of the following
%          listed options:
%        0.142 for Caucasian population mean
%        0.16  for mean blue Caucasian eye
%        0.106 for mean brown Caucasian eye
%        0.056 for mean pigmented-skin dark-brown eye
%    q   - Numeric. The spatial frequencies in cycles per degree to compute
%          MTF on.
%    phi - Numeric. The angles in radians to compute PSF and LSF on.
%
% Outputs:
%    MTF - Vector. The modulation transfer function of the human eye.
%          Follows the format of 1 x len(q).
%    PSF - Numeric. The point spread function of the human eye.
%    LSF - Numeric. The line spread function fo the human eye.
%
% Optional key/value pairs:
%    None.
%
% Notes -
%     * [Note: BW - I am suspicious of this because the high sensitivity at
%       60 cpd seems wrong. It is down only 1.5 log units from peak. I am
%       further worried because this function does not provide a
%       wavelength-dependent PSF, and yet we know that chromatic aberration
%       is very important.]
%
% References:
%    Ijspeert et al, Vision Res. 1993 Jan; 33(1):15-20. An improved
%    mathematical description of the foveal visual point spread function
%    with parameters for age, pupil size and pigmentation.
%
%    See corrections in Drasdo N, Thompson CM, Charman WN. Inconsistencies
%    in models of the human ocular modulation transfer function. Vision
%    Res. 1994 May; 34(10):1247-53.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/25/18  jnm  Formatting
%    07/25/18  dhb  Fix broken example.
%    10/08/18  dhb  Fix broken example (typo).

% Examples:
%{
    age = 30;
    pupilDiameter = 3;
    m = 0.142;
    q = [0:60];
    phi = pi;
    [MTF] = ijspeert(age, pupilDiameter, m, q)
    [MTF, PSF] = ijspeert(age, pupilDiameter, m, q, phi) % computes MTF and PSF
%}
%{
    age = 30;
    pupilDiameter = 3;
    m=0.16;
    q = (0:60);
    angRad = (0:50) / 50 * ieDeg2rad(0.1);
    [MTF, PSF] = ijspeert(age, pupilDiameter, m, q, angRad(:)');
    [MTF, PSF, LSF] = ijspeert(age, pupilDiameter, m, q, angRad(:)');
    subplot(1,3,1)
    semilogy(q, MTF)
    subplot(1,3,2)
    plot(angRad, PSF)
    subplot(1,3,3)
    plot(angRad, LSF)
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute prefactors c(i) and parameters beta(i) for the critical
% angle in the functions f_beta
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dependence on age
%    uses: age, m
%    produces: AF, c_sa, c_la
D = 70;  % doubling age of long-angle scattering
         % (relative to the central peak)
AF = 1 + (age / D) ^ 4;  % age factor--the increase of
                         % long-angle scattering with age
c_sa = 1 / (1 + AF / (1 / m - 1));  % sum of two short-angle prefactors
c_la = 1 / (1 + (1 / m - 1) / AF);  % sum of two long-angle prefactors

%% Dependence on pupil size
%    uses: p, AF, c_sa
%    produces: c(1), c(2), beta1, beta2

% the expressions for the following three constants were
% originally obtained by data fitting:
b = 9000 - 936 * (AF ^ 0.5);  % in 1/mm
d = 3.2;                      % in mm
e = (AF ^ 0.5) / 2000;

c(1) = c_sa / (1 + (p / d) ^ 2);
c(2) = c_sa / (1 + (d / p) ^ 2);

beta(1) = (1 + (p / d) ^ 2) / (b * p);            % in c/rad^(-1)
beta(2) = (1 + (d / p) ^ 2) * (e - 1 / (b * p));  % in c/rad^(-1)

%% Dependence on pigmentation
%    uses: m, AF, c_la
%    produces: c3, c4, beta3, beta4
c(3) = c_la / ( (1 + 25*m) * (1 + 1/AF) );
c(4) = c_la - c(3);

% These are in c/rad^(-1)
beta(3) = (10 + 60 * m - 5 / AF) ^ (-1);
beta(4) = 1;

%% Always compute MTF
M_beta(:, :) = exp(-360 * beta(:) * q);

MTF = zeros(1, size(q, 2));
for i = 1:4, MTF = MTF + c(i) * M_beta(i, :); end

%% Compute PSF if vector angles (phi) are given
if (nargin > 4)
    sinphi2 = sin(phi) .^ 2;
    cosphi2 = cos(phi) .^ 2;
    beta2 = beta .^ 2;

    for i = 1:4
      f_beta(i, :) = beta(i) ./ ( 2 * pi * (sinphi2 ...
          + beta2(i) * cosphi2) .^ (1.5));
    end

    PSF = zeros(1, size(phi, 2));
    for i = 1:4, PSF = PSF + c(i) * f_beta(i, :); end

    % Compute LSF if asked for
    if (nargout == 3)

    for i = 1:4
        l_beta(i, :) = beta(i) ./ (pi *(sinphi2 + beta2(i) * cosphi2));
    end

    LSF = zeros(1, size(phi, 2));
    for i = 1:4, LSF = LSF + c(i) * l_beta(i, :); end

    end  % if (nargout == 3)
end    % if (nargin > 4)

end