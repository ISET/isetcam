%% s_colorCielabSweep
%
% Compare CIELAB contrast directions in a spatial frequency sweep
%
% All three panels share a sinusoidal sweep and an XYZ baseline. The center
% sweep is mainly in the a* direction, with smaller L* and b* components.
% The left panel reduces the L* component and the right reduces the b*
% component. These directions are local to the baseline color.
%
% The script displays the labeled comparison and leaves rgbImage in the
% workspace as an sRGB-encoded image suitable for image or imwrite.
%
% Used in FISE, human color appearance section.  Not that the
% appearance of the edge on the right is blurred, compared to the edge
% appearance on the left.
%
% See also: ieLAB2XYZ, srgbParameters, lrgb2srgb

%% Parameters
nRows = 680*2;
panelWidth = 336;
frequencyTop = 4.5;             % Local spatial frequency in cycles per image height
frequencyBottom = 100;

baseLab = [78, 0, 0];           % Baseline under the D65 white point
amplitudeLab = [-10, 34, 8];    % Signed peak amplitudes in local [L*, a*, b*] units
lightnessScale = 0.6;            % Fraction of L* modulation retained on the left
blueYellowScale = -0.6;          % Fraction of b* modulation retained on the right

%% Express the three modulation directions in XYZ
whiteXYZ = srgbParameters('val', 'XYZwhite');
baseXYZ = ieLAB2XYZ(baseLab, whiteXYZ, true);

% Each row of xyzPerLab is the XYZ change per unit of one CIELAB coordinate
% at the baseline. Compute it with a centered difference, then use those
% fixed directions throughout the sweep so that the modulation stays linear.
labStep = 0.01;
labOffsets = labStep*eye(3);
xyzPlus = ieLAB2XYZ(baseLab + labOffsets, whiteXYZ, true);
xyzMinus = ieLAB2XYZ(baseLab - labOffsets, whiteXYZ, true);
xyzPerLab = (xyzPlus - xyzMinus)/(2*labStep);

panelScales = [lightnessScale, 1, 1; ...
               1, 1, 1; ...
               1, 1, blueYellowScale];
amplitudeXYZ = (panelScales.*amplitudeLab)*xyzPerLab;

%% Keep the full sinusoid inside the sRGB gamut
% Bound both peaks in linear RGB. If needed, apply one contrast scale to
% all three panels so their relative amplitudes are preserved.
xyzToLinearRGB = colorTransformMatrix('xyz2srgb');
baseRGB = baseXYZ*xyzToLinearRGB;
headroom = min(baseRGB, 1 - baseRGB);
assert(all(headroom >= 0), 'The baseline color must be inside the sRGB gamut.');

peakSwing = max(abs(amplitudeXYZ*xyzToLinearRGB), [], 1);
modulated = peakSwing > 0;
gamutScale = min([1, headroom(modulated)./peakSwing(modulated)]);
amplitudeXYZ = gamutScale*amplitudeXYZ;

%% Build the sweep and encode it for display
% Integrate a quadratic frequency ramp to obtain the phase in cycles.
rowPosition = (0:nRows-1)'/nRows;
phase = frequencyTop*rowPosition + (frequencyBottom-frequencyTop)*rowPosition.^3/3;
sweep = -sin(2*pi*phase);

% At each row, XYZ = baseline + sweep(row) * amplitudeXYZ(panel, :).
xyzProfiles = reshape(baseXYZ, 1, 1, 3) + sweep.*reshape(amplitudeXYZ, 1, 3, 3);
linearRGB = imageLinearTransform(xyzProfiles, xyzToLinearRGB);
rgbProfiles = lrgb2srgb(ieClip(linearRGB, 0, 1));  % Clip floating-point roundoff at gamut bounds
rgbImage = repelem(rgbProfiles, 1, panelWidth, 1);

%% Display with headings above the image
sweepFigure = ieNewGraphWin([], 'upper left big', 'CIELAB frequency sweep');
sweepAxes = axes('Parent', sweepFigure, 'Position', [0.025, 0.025, 0.95, 0.95]);
image(sweepAxes, rgbImage);
axis(sweepAxes, 'image', 'off');
headerHeight = 0.1*nRows;
ylim(sweepAxes, [0.5-headerHeight, nRows+0.5]);
panelCenters = ((1:3) - 0.5)*panelWidth + 0.5;
labels = ["Reduced L* contrast", "Original", "Reduced b* contrast"];
text(sweepAxes, panelCenters, repmat(0.5-headerHeight/2, 1, 3), labels, ...
    'HorizontalAlignment', 'center', 'FontSize', 15, 'Interpreter', 'none');
