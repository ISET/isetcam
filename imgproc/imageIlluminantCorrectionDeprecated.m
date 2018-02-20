function T = imageIlluminantCorrection(vci,vciTarget)
% Linear transform from sensor catch to desired representation
%
%  T = imageIlluminantCorrection(vci,vciTarget)
%
% The transformation T converts data under one illuminant into
% the target illuminant data.  If the data are NxMxW, then
%
%   correctedData = imageLinearTransform(originalData,T);
%
% See also: imageSensorCorrection
%
% Example
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Argument checking
if ieNotDefined('vci'),      vci = vcGetObject('vci'); end
if ieNotDefined('vciTarget'),error('vciTarget required'); end

tData = ipGet(vciTarget,'result');
oData = ipGet(vci,'result');

tData = RGB2XWFormat(tData);
oData = RGB2XWFormat(oData);

% Matrix inversion - no correction for noise or white weighting
% desired = T*actual 
T = tData' / oData';

% predicted = T*oData;
% plot(tData(:),predicted(:),'.')

return
