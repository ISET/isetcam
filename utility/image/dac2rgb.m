function RGB = dac2rgb(DAC, GammaTable)
%Convert RGB values to linear RGB intensities via the gamma table.
%
%     RGB = dac2rgb(DAC, GammaTable)
%
% DAC contains the frame buffer values of the primary color planes. DAC
% values should be in the range [0 1].  They can be in either RGB or XW
% format.
%
% GammaTable -- the look up table that converts DAC to linear RGB
%    If it has one column, all DAC values are changed according to this
%    If it has 3 columns and more than one row, treat input image as
%       3 planes and transform to RGB with the corresponding column.
%    If it is a scalar number, raise the DAC values to this power.
%    If it is a 3 vector, raise the r,g,b DAC values to the respective
%       power.
%    If GammaTable is not given, use a default scalar of 2.2.
%    The entries in GammaTable are assumed to be in the range [0, 1].
%
% RGB is the linear intensity of each display primary.
%
% Example
%
%
% Copyright Imageval LLC, 2013

if ieNotDefined('GammaTable'), GammaTable = 2.2; end

% Indicate input format, and force into XW format for computing here.  It
% will be returned in the input format
if ndims(DAC) == 2
    dFormat = 'XW';
    nPrimaries = size(DAC,2);
else
    dFormat = 'RGB';
    nPrimaries = size(DAC,3);
    [DAC,r,c] = RGB2XWFormat(DAC);
end

% Allocate space for return data
RGB = zeros(size(DAC));

% At this point, the data are in XW format
if isscalar(GammaTable)
    if (nargin==1)
        disp(['Raising DAC values to a power of ' num2str(GammaTable)]);
    end
    RGB = DAC.^GammaTable;
    
elseif isequal(size(GammaTable(:)),[3,1])
    fprintf('Using separate gamma values per primary %.3f\n',GammaTable);
    
    % Stay in XW format
    for ii=1:nPrimaries
        RGB(:,ii) = DAC(:,ii).^GammaTable(ii);
    end
    
elseif ndims(GammaTable) == 2
    % A full table was sent in.  We put the primary values in the dac
    % through different lookup tables, one for the R,G and B.
    DAC = round(DAC * (size(GammaTable,1)-1)) + 1;
    
    if (size(GammaTable,2)==1)
        GammaTable = repmat(GammaTable,1,nPrimaries);
    end
    
    for ii=1:nPrimaries
        RGB(:,ii) = GammaTable(DAC(:,ii));
    end
    
else
    error('Could not parse GammaTable');
end

if isequal(dFormat,'RGB'), RGB = XW2RGBFormat(RGB,r,c); end

return
