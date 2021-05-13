function [result, whitePt] = scComputeSCIELAB(xyz, whitePt, params)
% Compute S-CIELAB representation of a single XYZ image
%
%     [result,whitePt] = scComputeSCIELAB(xyz,whitePt,params);
%
% xyz:      an image (row,col,3)
% whitePt:  the white point of the image
%           it can be either be a 3-vector or a cell
%           array whose first entry is a 3-vector.
% params:
%
% By default, deltaEver is the CIELAB 2000 delta E (dE).  For backwards
% compatibility, it is possible to ask for earlier versions:
%  deltaEVer = '1976'; or
%  deltaEVer = '1994';
%
% Example:
%   params.deltaEversion = '2000';   % Which CIELAB version
%   params.sampPerDeg = sampPerDeg;  % Sets up the viewing distance
%   params.imageFormat = imageformat; %
%   params.filterSize = sampPerDeg;
%   params.filters = [];             % Not precomputed
%   sLAB = scComputeSCIELAB(xyz,whitePt,params);
%
% Copyright ImagEval Consultants, LLC, 2009.

if ieNotDefined('xyz'), errordlg('Scielab requires xyz image'); end
if ieNotDefined('whitePt'), errordlg('Requires a white point'); end
if ieNotDefined('params'), params = scParams; end

% Force input white point to a cell entry
if ~iscell(whitePt)
    tmp{1} = whitePt;
    whitePt = tmp;
end
% figure(1);
result = ClipXYZImage(xyz, whitePt{1});
% figure(1); Y =result(:,:,2); mesh(Y); colormap(jet(255)); mean(Y(:))

% These are the filters for spatial blurring.  They can take a
% while to create (and we should speed that up).
if isempty(params.filters)
    [params.filters, params.support] = scPrepareFilters(params);
    % figure(1);
    % subplot(3,1,1), mesh(params.filters{1})
    % subplot(3,1,2), mesh(params.filters{2})
    % subplot(3,1,3), mesh(params.filters{3})
end

% Filter the image in opponent-colors space starting from lms or xyz.  The
% returned image is in XYZ.
useOldCode = 0;
result = scOpponentFilter(result, params); % figure; imagesc(result(:,:,2))
result = ieXYZ2LAB(result, whitePt{1}, useOldCode);

% figure; imagesc(result(:,:,1));
% figure; imagesc(result(:,:,2)); colormap(gray), axis image
% figure; imagesc(result(:,:,3));
% tmp = getMiddleMatrix(result(:,:,1),[20,20]); histogram(tmp(:),50);
% figure; tmp = result(:,:,1); histogram(tmp(:),40);

return;