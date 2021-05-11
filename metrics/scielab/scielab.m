function [deltaEImage, params, xyz1, xyz2] = scielab(image1, image2, whitePt, params)
%Spatial CIELAB (S-CIELAB) difference metric
%
%  [deltaEImage, params, xyz1, xyz2] = scielab(image1,image2,whitePt,[params])
%
% Spatial CIELAB was developed by Xuemei Zhang and Brian Wandell in the
% mid-90s.
%
% The Spatial-CIELAB deltaE image (error map) describes the estimated
% visibility of differences between image1 and image2.  The metric is
% designed to reduce to the CIELAB value over those portions of the image
% that are spatially uniformm (constant). The metric adds spatial blurring
% consistent with measurements of human space-color sensitivity (Poirson
% and Wandell, 90s) to account for the visibility of spatial pattern
% contrast in different color channels.
%
% image1 and image2: 3-D images in XYZ or LMS format.
% whitePt:     a cell  array containing the white points of the two images.
%              XYZ images must between between 0 and the whitePt{ii}
% params:      a structure containing several variables used in the
%              calculation. The entries are updated and can be returned
%              by this routine.
%
%  params.<var>
%       sampPerDeg = How many samples per degree of visual angle in the image.
%                    If the image is, say, 5 deg, and contains 128 samples,
%                    then this parameter is 512/2.
%                    The default is 224 for historical reasons.  In
%                    general, the code should be improved to work well at
%                    low sample rates.
%       filters    = filters used in spatial blurring of opponent channels.
%                    If these are present, then the filters are used.
%                    Otherwise, new filters are created. They will be
%                    returned in params to save time in the next call.
%       filterSize = usually equal to sampPerDeg.
%       imageFormat= Data format of the input image.
%             'xyz2', 'xyz10', 'lms2', 'lms10';
%       deltaEversion  = which version of CIELAB.  (Default is 2000)
%              Earlier options permit '1976', '1994' and '2000'.
%              Added for special ISET analyses, we allow a request for
%              CIELAB 2000 'chroma','hue', or 'luminance' component errors.
%              These are always calculated using CIELAB 2000.
%
% See Also:  s_scielabISET, scielabRGB, scComputeSCIELAB
%   This routine is divided into three main sub-routines that perform the
%   key computations.
%
%   scPrepareFilter     -- Prepare the spatial blurring filters
%   scOpponentFilter    -- Apply the filters in opponent color space
%   scComputeDifference -- Compute the resulting CIELAB differences
%
%
% Example:
%   See s_scielabExample.m for a full description
%
%   scielab(image1,image2,whitePt,params);  % deltaE 2000 CIELAB version
%
%   params.deltaEversion = '1976';
%   scielab(image1,image2,whitePt,params);  % deltaE 1976 CIELAB version
%
%   params.deltaEversion = 'hue';           % Just the hue error
%   scielab(image1,image2,whitePt,params);
%   params.deltaEversion = 'chrominance';   % Just the chrominance error
%   scielab(image1,image2,whitePt,params);
%
%   params.deltaEversion = '2000';   % Which CIELAB version
%   params.sampPerDeg = sampPerDeg;  % Sets up the viewing distance
%   params.imageFormat = imageformat; %
%   params.filterSize = sampPerDeg;
%   params.filters = [];             % Not precomputed
%   [errorImage,params] = scielab(img1LMS, img2LMS, whitePt, params);
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:
%
% N.B. In this implementation, the row/col size of the deltaEImage (error
% image) and input image can differ by one row or col.  The source of this
% difference concerns the even/odd sizes and FFT issues.  This should be
% corrected in the future.  For now, if they do differ, the input images
% were reduced by eliminating the last  row or col prior to the
% calculation.
%
% This routine could operate just by calling scComputeSCIELAB twice, for
% each input image, and then returning the difference.  That would keep the
% code in better alignment.
%
% The original algorithm is based on the Hunt-Pointer-Estevez estimates of
% XYZ to cone coordinates.  Those are incorrect.  But the original code was
% designed to be consistent with that transformation and the
% Poirson/Wandell data. So until we update the data, we use that older
% conversion matrix.
%

%% Initialize parameters

if ieNotDefined('image1'), errordlg('Scielab requires image1'); end
if ieNotDefined('image2'), errordlg('Scielab requires image2'); end
if ieNotDefined('whitePt'), errordlg('Scielab requires a white point or white point cell array'); end
if ieNotDefined('params'), params = scParams; end

% The white point used in the CIELAB calculation.  This is expected to be a
% cell array containing a white point for each image.  If it is just a
% vector, then we convert it to a cell array.
if ~iscell(whitePt)
    tmp{1} = whitePt;
    tmp{2} = whitePt;
    whitePt = tmp;
end

% If the image and data format are in LMS, we convert them to XYZ here.
if strncmp(params.imageFormat, 'lms', 3)
    % We convert the LMS images and white points to XYZ10 space in here.
    for ii = 1:2
        % The lms2xyz matrix is based on the Hunt-Pointer-Estevez method.
        % The rest of ISET uses the Stockman fundamentals.  But the HPE
        % method was chosen in the mid-90s, and we retain it here for
        % backwards compatibility.  It is worth trying to understand
        % whether we should update this calculation.
        T = colorTransformMatrix('hpe2xyz');
        image1 = imageLinearTransform(image1, T);
        image2 = imageLinearTransform(image2, T);

        % Convert the white points
        w = whitePt{1};
        whitePt{1} = w(:)' * T;
        w = whitePt{2};
        whitePt{2} = w(:)' * T;
        params.imageFormat = 'xyz10';

    end
end

%% Clipping.  Oy vey.
% Took out clipping May 3 2012.
% image1 = ClipXYZImage(image1, whitePt{1});
% image2 = ClipXYZImage(image2, whitePt{2});

% Now, we set an error for negative values and a warning when the image
% value exceeds the white point.
%
% If we are in XYZ, we should call and then scComputeSCIELAB. Each
% dimension is clipped to fall between between 0 and whitePt{ii}. The white
% point is always biggest because XYZ are all positive.
if min(image1(:)) < 0, error('Negative XYZ values image 1'); end
if min(image2(:)) < 0, error('Negative XYZ values image 2'); end
%
% The white point and max image, sigh.  THere should be some check for
% reasonable relationship, but I don't have one yet.
%
% wTolerance = 1.05;
% for ii=1:3
%     tmp = image1(:,:,ii);
%     if max(tmp(:)) > whitePt{1}(ii)*wTolerance
%         warning('ISET:scielabWPV2','Suspicious image 1 white point (%d): %.2f, %2f',...
%             ii,max(tmp(:)),whitePt{1}(ii));
%     end
%     tmp = image2(:,:,ii);
%     if max(tmp(:)) > whitePt{2}(ii)*wTolerance
%         warning('ISET:scielabWPV2','image 2 white point violation (%d): %.2f, %2f', ...
%             ii,max(tmp(:)),whitePt{1}(ii));
%     end
% end

%% Prepare filters for spatial blurring.
% They can take a while to create (and we should speed that up).
if isempty(params.filters)
    % We should check here whether the filter parameters for the size are
    % close to the image size.  If they are close, we should probably
    % simply make the filter support equal to the size of the image.
    [params.filters, params.support] = scPrepareFilters(params);
end
% figure; imagesc(params.filters{2})

%%
% Filter the image in opponent-colors space starting from lms or xyz.  The
% returned image is in XYZ.
xyz1 = scOpponentFilter(image1, params); % figure; imagesc(xyz1(:,:,2))
xyz2 = scOpponentFilter(image2, params); % figure; imagesc(xyz1(:,:,2))

% I think the following two calls should be an equivalent computation.  But
% it is not.  So I should figure out what's going on.
deltaEImage = scComputeDifference(xyz1, xyz2, whitePt, params.deltaEversion);
% figure; imagesc(deltaEImage); colorbar

% There are some differences between below and above.  Sigh.  Why.
%
% d1 = scComputeSCIELAB(xyz1,whitePt{1},params);
% r = size(d1,1); c = size(d1,2);
% d2 = scComputeSCIELAB(xyz2,whitePt{2},params);
% dE = deltaE2000(RGB2XWFormat(d1),RGB2XWFormat(d2));
% figure; plot(dE(:),deltaEImage(:),'.')
% figure; imagesc(reshape(dE,r,c)); colorbar

return;
