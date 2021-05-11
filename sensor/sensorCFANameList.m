function cfaName = sensorCFANameList
% List the valid ISET names for color filter arrays
%
%    cfaName = sensorCFANameList(ISA)
%
% At this time, we support a short list of color filter array types.
% This returns the valid list, and it is used to define the popup boxes in
% sensorWindow. The list will grow in the future.
%
% Examples:
%   cfaNames = sensorCFANameList
%
% Copyright ImagEval Consultants, LLC, 2005

disp('CFA name list');
cfaName = {'Bayer RGB', 'Bayer CMY', 'RGBW', 'Monochrome', 'Other'};
% ...
{'bayer-grbg', 'bayer-rggb', 'bayer-bggr', 'bayer-gbrg', ...
    'bayer-ycmy', 'Monochrome', 'Four Color', 'Other'};

end
