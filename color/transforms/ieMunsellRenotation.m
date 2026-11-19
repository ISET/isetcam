function data = ieMunsellRenotation(dataset)
% Read the Munsell renotation data (Newhall, Nickerson and Judd, 1943)
%
% Synopsis
%   data = ieMunsellRenotation([dataset])
%
% Brief description
%   The Munsell renotation data give the CIE chromaticity (x,y) and
%   luminance factor (Y) of Munsell hue/value/chroma samples under CIE
%   Illuminant C, for the CIE 1931 2-deg observer.  The renotation was
%   produced by the Optical Society of America (now Optica) Subcommittee
%   on the Spacing of the Munsell Colors and defines the modern Munsell
%   system.
%
% Inputs
%   dataset:  'all' (default), 'real', or '1929'
%     'real' - The 2,734 samples tabulated in the 1943 paper.  All lie
%              within the MacAdam limits (realizable surface colors).
%     'all'  - The 'real' samples plus extrapolated samples, 4,995 in
%              total, including Values 0.2-0.8 and 10.  Some extrapolated
%              samples are outside the MacAdam limits.  ieMunsell2XYZ and
%              ieXYZ2Munsell interpolate this dataset.
%     '1929' - The 956 samples of the 1929 Munsell Book of Color, as
%              transcribed from Munsell's notes.
%
% Returns
%   data: struct with fields
%     dataset  - Dataset name
%     notation - N x 1 string array, e.g., "2.5R 4/6"
%     hvc      - N x 3 [H V C], with H on the 100-step hue circle
%                (see ieMunsellNotation)
%     xyY      - N x 3 [x y Y] as published.  Y is relative to magnesium
%                oxide (MgO), not to a perfect reflecting diffuser.
%     XYZ      - N x 3 CIE XYZ with Y relative to a perfect reflecting
%                diffuser (Y = 0.975 * published Y).  This is the scale
%                used by ASTM D1535 and by ieMunsell2XYZ.
%     whiteXYZ - XYZ of a perfect reflecting diffuser under Illuminant C
%     source   - Citation, URL, and terms of use
%
% Description
%   The data files are in data/surfaces/munsell.  They were downloaded
%   from the Munsell Color Science Laboratory at RIT and are included in
%   ISETCam for research use only; see data/surfaces/munsell/README.md
%   for the terms of use.  The renotation specifies the aim
%   colors of the Munsell system; it is not a set of measurements of the
%   chips in a particular Munsell Book of Color.
%
%   The 'real' and 'all' files disagree in a few places.  At 2.5R 9/2,
%   'real' lists x = 0.3210 and 'all' lists x = 0.3220; the 'all' value
%   is consistent with the neighboring samples.  At Values 3 and 6, 'all'
%   lists Y = 6.55 and 30.03 where 'real' (and the 1943 Value formula)
%   give 6.555 and 30.05.  The values are returned as published.
%
%   Reference: S. M. Newhall, D. Nickerson, and D. B. Judd, "Final report
%   of the O.S.A. Subcommittee on the Spacing of the Munsell Colors,"
%   J. Opt. Soc. Am. 33, 385-418 (1943).
%
% See also
%   ieMunsell2XYZ, ieXYZ2Munsell, ieMunsellNotation, chromaticityPlot

% Examples:
%{
d = ieMunsellRenotation('real');
% The Value 5 plane on the chromaticity diagram
idx = d.hvc(:,2) == 5;
chromaticityPlot(d.xyY(idx,1:2));
%}
%{
d = ieMunsellRenotation;
d.notation(1:5)
d.XYZ(1:5,:)
%}

%%
persistent cache
if isempty(cache), cache = struct(); end

if ~exist('dataset','var') || isempty(dataset), dataset = 'all'; end
dataset = lower(char(dataset));
if ~ismember(dataset, {'all','real','1929'})
    error('Unknown dataset "%s".  Use ''all'', ''real'', or ''1929''.', dataset);
end

key = ['d' dataset];   % Field names cannot start with a digit
if isfield(cache, key), data = cache.(key); return; end

%% Read the table: hue name, value, chroma, x, y, Y
fname = fullfile(isetRootPath, 'data', 'surfaces', 'munsell', [dataset '.dat']);
fid = fopen(fname, 'r');
if fid < 0, error('Cannot open Munsell renotation file %s.', fname); end
closeFile = onCleanup(@() fclose(fid));
cols = textscan(fid, '%s %f %f %f %f %f', 'HeaderLines', 1);

notation = string(cols{1}) + " " + string(cols{2}) + "/" + string(cols{3});
hvc = ieMunsellNotation(notation);

data.dataset  = dataset;
data.notation = notation;
data.hvc      = hvc;
data.xyY      = [cols{4} cols{5} cols{6}];
data.XYZ      = xyy2xyz([data.xyY(:,1:2), 0.975*data.xyY(:,3)]);
data.whiteXYZ = [98.074 100 118.232];
data.source   = ['Newhall, Nickerson and Judd, J. Opt. Soc. Am. 33, 385-418 (1943). ' ...
    'Munsell Color Science Laboratory, RIT: ' ...
    'https://www.rit.edu/science/munsell-color-science-lab-educational-resources. ' ...
    'For research use only; see data/surfaces/munsell/README.md.'];

cache.(key) = data;

end
