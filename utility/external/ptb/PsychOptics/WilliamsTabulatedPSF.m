function [positionMinutes,psf] = WilliamsTabulatedPSF
%WILLIAMSTABULATEDPSF  Tabulated PSF from Williams et al. 1994
%   function [positionMinutes,psf] = WILLIAMSTABULATEDPSF
%
%   This function returns the slice through the PSF in Table 2 of
%   Williams et al. 1994, JOSA A, 11, 3123-3135.
%
%   See also WILLIAMSMTF, DIFFRACTIONMTF, PSYCHOPTICSTEST

% 2/4/17  dhb  Typed this in, after all these years.

tabulatedData = ...
    [0	6.98E+06
    0.1	6.69E+06
    0.2	5.87E+06
    0.3	4.71E+06
    0.4	3.43E+06
    0.5	2.27E+06
    0.6	1.37E+06
    0.7	7.90E+05
    0.8	5.02E+05
    0.9	4.12E+05
    1	4.14E+05
    1.1	4.26E+05
    1.2	4.06E+05
    1.3	3.52E+05
    1.4	2.84E+05
    1.5	2.25E+05
    1.6	1.89E+05
    1.7	1.74E+05
    1.8	1.68E+05
    1.9	1.61E+05
    2	1.47E+05
    2.1	1.27E+05
    2.2	1.06E+05
    2.3	9.10E+04
    2.4	8.28E+04
    2.5	7.93E+04
    2.6	7.69E+04
    2.7	7.22E+04
    2.8	6.47E+04
    2.9	5.62E+04
    3	4.89E+04
    3.1	4.45E+04
    3.2	4.26E+04
    3.3	4.17E+04
    3.4	4.01E+04
    3.5	3.70E+04
    3.6	3.29E+04
    3.7	2.91E+04
    3.8	2.65E+04
    3.9	2.54E+04
    4	2.50E+04
    4.1	2.44E+04
    4.2	2.31E+04
    4.3	2.10E+04
    4.4	1.88E+04
    4.5	1.72E+04
    4.6	1.64E+04
    4.7	1.62E+04
    4.8	1.61E+04
    4.9	1.54E+04
    5	1.43E+04];

positionMinutes = tabulatedData(:,1);
psf = tabulatedData(:,2);

end