function out = ieMunsellNotation(in, nDigits)
% Convert between Munsell notation text and numeric [H V C] values
%
% Synopsis
%   hvc      = ieMunsellNotation(notation)
%   notation = ieMunsellNotation(hvc, [nDigits])
%
% Brief description
%   Munsell colors are written as text, such as '5R 4/14' (hue 5R, value 4,
%   chroma 14) or 'N 5/' for a neutral.  The ISETCam Munsell functions also
%   use a numeric form, [H V C], in which the hue is a single number on the
%   100-step Munsell hue circle.  This function converts in either
%   direction.
%
% Inputs
%   in:      Either
%            - Text: a char row vector, string array, or cell array of
%              char, such as '5R 4/14', "2.5YR 6.5/8", or {'N 5/','10RP 3/2'}
%            - Numeric N x 3 matrix with columns [H V C]
%   nDigits: Decimal places used when writing text (default 1).  Trailing
%            zeros are dropped, so [5 4 14] is written as "5R 4/14".
%
% Returns
%   out:     For text input, an N x 3 matrix [H V C].
%            For numeric input, an N x 1 string array.  Rows containing NaN
%            (other than the hue of a neutral) are returned as <missing>.
%
% Description
%   Hue number.  The ten Munsell hue families, in order around the hue
%   circle, are R YR Y GY G BG B PB P RP.  Within a family the hue step
%   runs from 0 (exclusive) to 10 (inclusive).  The hue number is
%
%       H = (family index - 1)*10 + hue step,   0 < H <= 100
%
%   so 5R = 5, 10R = 10, 2.5YR = 12.5, 5PB = 75, and 10RP = 100.  A hue step
%   of 0 is the same as step 10 of the preceding family (0YR = 10R).
%   Numeric hues outside (0,100] are wrapped onto the circle.
%
%   Neutrals.  Achromatic colors are written 'N V/'.  The forms 'N V',
%   'NV', and 'N V/0' are also accepted.  Their numeric form is [NaN V 0].
%   When writing text, a sample whose chroma rounds to zero is written as
%   a neutral.
%
% See also
%   ieMunsell2XYZ, ieXYZ2Munsell, ieMunsellRenotation

% Examples:
%{
hvc = ieMunsellNotation({'5R 4/14','2.5YR 6.5/8','N 5/'})
%}
%{
ieMunsellNotation([5 4 14; 12.5 6.5 8; NaN 5 0; 100 3 2])
%}

%%
if ~exist('in','var') || isempty(in), error('Munsell notation or [H V C] values are required.'); end
if ~exist('nDigits','var') || isempty(nDigits), nDigits = 1; end

families = ["R","YR","Y","GY","G","BG","B","PB","P","RP"];

if isnumeric(in)
    out = hvc2text(double(in), nDigits, families);
elseif ischar(in) || isstring(in) || iscellstr(in)
    out = text2hvc(string(in), families);
else
    error('Input must be Munsell notation text or an N x 3 [H V C] matrix.');
end

end

%% ---------------------------------------------------------------------
function hvc = text2hvc(txt, families)
% Parse notation strings into N x 3 [H V C]

txt = upper(strtrim(txt(:)));
hvc = nan(numel(txt), 3);

num       = '(\d+\.?\d*|\.\d+)';
chromatic = ['^' num '\s*([A-Z]{1,2})\s*' num '\s*/\s*' num '$'];
neutral   = ['^N\s*' num '\s*(?:/\s*(?:0*\.?0*)?)?$'];

for ii = 1:numel(txt)
    tok = regexp(txt(ii), chromatic, 'tokens', 'once');
    if ~isempty(tok)
        family = find(families == tok(2));
        step   = str2double(tok(1));
        if isempty(family)
            error('Unknown Munsell hue family "%s" in "%s".', tok(2), txt(ii));
        elseif step > 10
            error('Munsell hue step must be between 0 and 10 in "%s".', txt(ii));
        end
        hvc(ii,:) = [wrapHue((family-1)*10 + step), str2double(tok(3)), str2double(tok(4))];
        continue;
    end

    tok = regexp(txt(ii), neutral, 'tokens', 'once');
    if ~isempty(tok)
        hvc(ii,:) = [NaN, str2double(tok(1)), 0];
        continue;
    end

    error('Cannot parse Munsell notation "%s".', txt(ii));
end

end

%% ---------------------------------------------------------------------
function txt = hvc2text(hvc, nDigits, families)
% Format N x 3 [H V C] as notation strings

if size(hvc,2) ~= 3, error('Numeric input must be N x 3 [H V C].'); end

txt = strings(size(hvc,1), 1);
for ii = 1:size(hvc,1)
    V = round(hvc(ii,2), nDigits);
    C = round(hvc(ii,3), nDigits);
    if isnan(V) || isnan(C)
        txt(ii) = missing;
    elseif C == 0
        txt(ii) = sprintf('N %s/', fmt(V));
    elseif isnan(hvc(ii,1))
        txt(ii) = missing;
    else
        H      = wrapHue(round(wrapHue(hvc(ii,1)), nDigits));
        family = ceil(H/10);
        step   = round(H - 10*(family-1), nDigits);
        txt(ii) = sprintf('%s%s %s/%s', fmt(step), families(family), fmt(V), fmt(C));
    end
end

end

%% ---------------------------------------------------------------------
function H = wrapHue(H)
% Map hue numbers onto (0,100]
H = mod(H, 100);
H(H == 0) = 100;
end

function s = fmt(x)
% Shortest decimal form, without trailing zeros
s = sprintf('%g', x);
end
