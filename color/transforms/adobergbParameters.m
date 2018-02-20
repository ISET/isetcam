function params = adobergbParameters(varargin)
% Return the chromaticity and white point of the sRGB standard
%
%    params = adobergbParameters
%
% Return Adobe RGB display parameters.  
%
% The Adobe display is defined by three primaries with these chromaticity
% coordinates (x,y,Y) and luminance.  Using the information on wikipedia at
% adbove_rgb_color_space we inferred these values for the reference
%
%     R       G     B              White point
% x  0.64   0.21   0.15               0.3127
% y  0.33   0.71   0.06               0.3290
% Y  47.5744   100.3776  12.0320      160 
%
% They also define a black, that we could use someday
%
% XYZ of Black:  0.5282 0.5557 0.6052 (xy is same as white 0.3127, 0.3290)
%
% Examples
%   adobergbParameters
%   adobergbParameters('val','chromaticity')
%   adobergbParameters('val','xyYwhite')
%   adobergbParameters('val','luminance')
%   adobergbParameters('val','XYZwhite')
%   adobergbParameters('val','XYZblack')
% Copyright Imageval Consulting, LLC, 2016


%% Figure out which value we want returned
p = inputParser;
vFunc = @(x)(ismember(x,{'all','chromaticity','luminance','xyYwhite','XYZwhite','XYZblack'}));
p.addParameter('val','all',vFunc);
p.parse(varargin{:});
val = p.Results.val;

adobergbP = [ ....
     0.64   0.21   0.15      0.3127;
     0.33   0.71   0.06      0.3290;
    47.5744   100.3776  12.0320      160];

%%

switch val
    case 'all'
        params = adobergbP;
    case 'chromaticity'
        params = adobergbP(1:2,1:3);
    case 'luminance'
        params = adobergbP(3,1:3);
    case {'xyYwhite'}
        % xyY
        params = adobergbP(:,4);
    case {'XYZwhite'}
        params = adobergbP(:,4);
        params = xyy2xyz(params(:)');
    case {'XYZblack'}
        params = [0.5282 0.5557 0.6052];
    otherwise
        error('Unknown request %s\n',val);
end


end



