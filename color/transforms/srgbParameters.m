function params = srgbParameters(varargin)
% Return the chromaticity and white point of the sRGB standard
%
%    params = srgbParameters
%
% Return sRGB display parameters.  Possible
%   The entire matrix
%
% The sRGB display is defined by three primaries with these chromaticity
% coordinates (x,y,Y) and luminance
%
%     R       G     B         White point
% x	0.6400	0.3000	0.1500     0.3127
% y	0.3300	0.6000	0.0600     0.3290
% Y	0.2126	0.7152	0.0722     1.0000
%
% Examples
%   srgbParameters;
%   srgbParameters('val','chromaticity')
%   srgbParameters('val','xyYwhite')
%   srgbParameters('val','luminance')
%   srgbParameters('val','XYZwhite')
%
% Copyright Imageval Consulting, LLC, 2016


%% Figure out which value we want returned
p = inputParser;
vFunc = @(x)(ismember(x,{'all','chromaticity','luminance','xyYwhite','XYZwhite'}));
p.addParameter('val','all',vFunc);
p.parse(varargin{:});
val = p.Results.val;

srgbP = [ ....
    0.6400	0.3000	0.1500     0.3127;
    0.3300	0.6000	0.0600     0.3290;
    0.2126	0.7152	0.0722     1.0000];

%%

switch val
    case 'all'
        params = srgbP;
    case 'chromaticity'
        params = srgbP(1:2,1:3);
    case 'luminance'
        params = srgbP(3,1:3);
    case {'xyYwhite'}
        % xyY
        params = srgbP(:,4);
    case {'XYZwhite'}
        params = srgbP(:,4);
        params = xyy2xyz(params(:)');
    otherwise
        error('Unknown request %s\n',val);
end


end



