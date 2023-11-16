function [smf0, r, smf1d] = watsonRGCSpacing(fovCols)
% Receptive field density as a function of visual field location
%
% Syntax:
%   [smf0, r, smfld] = watsonRGCSpacing(fovCols)
%
% Descrtipion:
%    Receptive field density as a function of visual field location.
%
%    The watson retinal ganglion cell spacing function, using the paper
%    referenced below.
%
% Inputs:
%    fovCols - Numeric. The number of columns, used to determine degrees
%              within the field of view.
%
% Outputs:
%    smf0    - Matrix. The spacing for midget RGC's. It is a square matrix
%              with each side measuring fovCols + 1.
%    r       - Vector. The range. r = [.05:.1:100];
%    smfld   - Matrix. Spacing of RGC accross the field.
%
% Optional key/value pairs:
%    None.
%
% References:
%    Scientific source: A formula for human retinal ganglion cell receptive
%    field density as a function of visual field location. Andrew (Beau)
%    Watson, Journal of Vision, June 2014, Vol.14, 15. doi:10.1167/14.7.15
%    http://jov.arvojournals.org/article.aspx?articleid=2279458#87788093
%

% History:
%    xx/xx/17  JRG  ISETBIO Team, 2017
%    07/06/18  jnm  Formatting

%%
% Table 1
%
% Parameters and error for fits of Equation 4 in four meridians. Note: Also
% shown are measured and predicted cumulative counts along each meridian
% within the displacement zone. The next-to-last column shows the fitting
% error outside the displacement zone. The last column indicates the
% assumed limit of the displacement zone.
%
% Meridian  k   a        r2      re     Data   Model  Error  rz
%                                       count
% Temporal  1   0.9851   1.058   22.14  485.1  485.7  0.23   11
% Superior  2   0.9935   1.035   16.35  526.1  528.9  0.12   17
% Nasal     3   0.9729   1.084   7.633  660.9  661.1  0.01   17
% Inferior  4   0.996    0.9932  12.13  449.3  452.1  0.93   17
%
% Table 2
%
% Parameters of the displacement function (Equation 5 and vcNewGraphWin 6).
% Meridian   ?       ?(deg)  ?        ?       ?(deg)
% Temporal   1.8938  2.4598  0.91565  14.904  ?0.09386
% Nasal      2.4607  1.7463  0.77754  15.111  ?0.15933
%
% Item                                         Value     Unit
% Peak cone density                            14,804.6  deg^-2
% Peak RGCf density                            33,162.3  deg^-2
% Peak mRGCf density                           29,609.2  deg^-2
% Minimum on-center mRGCf (or cone) spacing    0.5299    arcmin
% Peak on-center mRGCf (or cone) Nyquist       65.37     cycles/deg
% f(0), midget fraction at zero eccentricity   1/1.12 = 0.8928
% rm, scale factor for decline in midget fraction with eccentricity
%                                              41.03     deg
%

%%
% 2
% f0inv = 1.12;
% dc = 14804.6;
% dgf0 = 2 * (f0inv) * dc
dgf0 = 33163.2; % deg ^ -2

% 4
% vcNewGraphWin;
for k = 1:4
    % switch k
    %     case 1
    %         paramsk = [0.9851  1.058   22.14]; % [a r2 re]
    %     case 2
    %         paramsk = [0.9935  1.035   16.35]; % [a r2 re]
    %     case 3
    %         paramsk = [0.9729  1.084   7.633]; % [a r2 re]
    %     case 4
    %         paramsk = [0.996   0.9932  12.13]; % [a r2 re]
    % end
    paramsk = [0.9851    1.058    22.14;...
               0.9935    1.035    16.35;...
               0.9729    1.084    7.633;...
               0.996    0.9932    12.13];

    r = [.05:.1:100];
    % dgf = dgf0 * [paramsk(1) * (1 + r ./ paramsk(2)) .^ -2 + ...
    %    (1 - paramsk(1)) * exp(-r ./ paramsk(3))];

    dgf(k, :) = dgf0 * [paramsk(k, 1) * (1 + r ./ paramsk(k, 2)) .^ -2 ...
        + (1 - paramsk(k, 1)) * exp(-r ./ paramsk(k, 3))];

    % vcNewGraphWin;
    % hold on
    % plot(r, dgf); set(gca, 'xscale', 'log');
    % set(gca, 'yscale', 'log');
end

% xlabel('eccentricity (degrees)');
% ylabel('density');
% grid on
%%
% % 7
fr = (1 / 1.12) * (1 + r ./ 41.03) .^ -1;
% 8

for k = 1:4, dmf1d(k, :) = fr .* dgf(k, :); end

vcNewGraphWin;
cind = 'rbgk';
hold on;
for k = 1:4
    dmf1d(k, :) = fr .* dgf(k, :);
    plot(r, dmf1d(k, :), cind(k), 'linewidth', 2);
end
% vcNewGraphWin;
% plot(r, dmf1d);
set(gca, 'xscale', 'log');
set(gca, 'yscale', 'log');
grid on;
axis([0.05 100 1 1e5]);
legend('Temporal', 'Superior', 'Nasal', 'Inferior');
xlabel('Eccentricity (degrees)');
ylabel('Density (1/deg^2)');
set(gca, 'fontsize', 14);
% 9
smf1d = sqrt(2 ./ (sqrt(3) * dmf1d));
% vcNewGraphWin;
% plot(r, smf1d);
% grid on;

%%

% Temporal  1  0.9851  1.058   22.14   485.1  485.7  0.23  11
% Superior  2  0.9935  1.035   16.35   526.1  528.9  0.12  17
% Nasal     3  0.9729  1.084   7.633   660.9  661.1  0.01  17
% Inferior  4  0.996   0.9932  12.13   449.3  452.1  0.93  17
%

% smf = 4xr pts
clear smf
% x = 1;
% y = 1;
% rxy = sqrt(x .^ 2 + y .^ 2);
xctr = 0;
% for x = .1:.1:1
% degarr = [-40:.25:40];

% degStart = -27.5;
% degEnd = 27.5;
% degarr = [-27.5:((degEnd - degStart) / 1080):27.5];

degStart = -fovCols / 2;
degEnd = fovCols / 2;
% Prior code
% degarr = [degStart: (degEnd - degStart) / cols : degEnd];
degarr = (degStart: (degEnd - degStart) / fovCols : degEnd);

convertDensityFactor = sqrt(2);

for x = degarr
    xctr = xctr + 1;
    yctr = 0;
    % for y = .1:.1:1
    for y = degarr
        yctr = yctr + 1;

        rxy = sqrt(x .^ 2 + y .^ 2);

        if x <= 0 && y >= 0
            karr = [1 2];
        elseif x > 0 && y > 0
            karr = [3 2];
        elseif x > 0 && y < 0
            karr = [3 4];
        elseif x <= 0 && y <= 0
            karr = [1 4];
        end
        kctr = 0;
        for k = karr
            kctr = kctr+1;
            dgfE(xctr, yctr, kctr) = dgf0 * [paramsk(k, 1) * ...
                (1 + rxy ./ paramsk(k, 2)) .^ -2 + ...
                (1 - paramsk(k, 1)) * exp(-rxy ./ paramsk(k, 3))];

            fr = (1 / 1.12) * (1 + rxy ./ 41.03) .^ -1;

            dmf(xctr, yctr, kctr) = fr * dgfE(xctr, yctr, kctr);
            smf(xctr, yctr, kctr) = ...
                sqrt(2 ./ (sqrt(3) * dmf(xctr, yctr, kctr)));
        end

        smf0(xctr, yctr) = convertDensityFactor * (1 / rxy) * ...
            sqrt(x ^ 2 * smf(xctr, yctr, 1) .^ 2 + y ^ 2 ...
            * smf(xctr, yctr, 2) .^ 2);
    end
end

vcNewGraphWin;
% subplot(121);
% plot(r, smf1d);
% xlabel('Eccentricity (degrees)');
% ylabel('RF Size (degrees)');
% grid on;
% subplot(122);
contourf(degarr, degarr, smf0', [0:max(smf0(:)) / 20:max(smf0(:))]);
axis square
title(sprintf('Human Midget RGC RF Size (degrees)'));
colorbar;

xlabel(sprintf(...
    'Eccentricity (degrees)\nTemporal <---------------------> Nasal'));
ylabel(sprintf(...
    'Eccentricity (degrees)\nInferior <---------------------> Superior'));
set(gca, 'fontsize', 14);

% s = (1 / rxy) * sqrt(x ^ 2 * dgf(1, :) .^ 2 + y ^ 2 * dgf(2, :) .^ 2);

end
%%