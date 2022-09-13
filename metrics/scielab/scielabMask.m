function [deltaEImage, params, xyz1, xyz2] = scielabMask(image1,image2,whitePt,params)
%Spatial CIELAB (S-CIELAB) difference metric
%
%  [deltaEImage, params, xyz1, xyz2] = scielabMask(image1,image2,whitePt,[params])
%
% The Spatial-CIELAB difference image (error map) compares image1 and
% image2.  This implementation adds an additional processing step that aims
% to account for masking.
%
% EXPLAIN HERE:
%
% N.B. In this implementation, the row/col size of the deltaEImage (error
% image) and input image can differ by one row or col.  The source of this
% difference concerns the even/odd sizes and FFT issues.  This should be
% corrected in the future.  For now, if they do differ, the input images
% were reduced by eliminating the last  row or col prior to the
% calculation.
%
% image1 and image2: 3-D images in XYZ or LMS format.
% whitePt:     a cell  array containing the white points of the two images.
%              XYZ images must between between 0 and the whitePt{ii}
% params:      a structure containing several variables used in the
%              calculation. The entires are updated and can be returned
%              by the routine.
%
%  params.
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
% The routine is divided into three main sub-routines that perform the
% key computations.
%
%   scPrepareFilter     -- Prepare the spatial blurring filters
%   scOpponentFilter    -- Apply the filters in opponent color space
%   scComputeDifference -- Compute the resulting CIELAB differences
%
% See Also:  s_scielabISET, scielabRGB, scComputeSCIELAB
%
% Example:
%   fullName = fullfile(isetRootPath,'data','images','rgb','hats.jpg');
%   image1 = double(imread(fullName));
%   nScale = 10; n = nScale*randn(size(image1));
%   image2 = double(image1) + n; image2 = ieClip(image2,0,255);
%   image1 = image1/255; image2 = image2/255;
%   image1 = srgb2xyz(image1); image2 = srgb2xyz(image2); whitePt = srgb2xyz(ones(1,1,3));
%   scielabMask(image1,image2,whitePt,scParams)
%
%   scielabMask(image1,image2,whitePt,params);  % deltaE 2000 CIELAB version
%
%   params.deltaEversion = '1976';
%   scielabMask(image1,image2,whitePt,params);  % deltaE 1976 CIELAB version
%
%   params.deltaEversion = 'hue';           % Just the hue error
%   scielabMask(image1,image2,whitePt,params);
%   params.deltaEversion = 'chrominance';   % Just the chrominance error
%   scielabMask(image1,image2,whitePt,params);
%
%   params.deltaEversion = '2000';   % Which CIELAB version
%   params.sampPerDeg = sampPerDeg;  % Sets up the viewing distance
%   params.imageFormat = imageformat; %
%   params.filterSize = sampPerDeg;
%   params.filters = [];             % Not precomputed
%   [errorImage,params] = scielab(img1LMS, img2LMS, whitePt, params);
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:  This routine could operate just by calling scComputeSCIELAB twice,
% for each input image, and then returning the difference.  That would keep
% the code in better alignment.

% Initialize parameters

if ieNotDefined('image1'), errordlg('Scielab requires image1'); end
if ieNotDefined('image2'), errordlg('Scielab requires image2'); end
if ieNotDefined('whitePt'), errordlg('Scielab requires a white point or white point cell array'); end
if ieNotDefined('params'),  params = scParams;  end

% The white point used in the CIELAB calculation.  This is expected to be a
% cell array containing a white point for each image.  If it is just a
% vector, then we convert it to a cell array.
if ~iscell(whitePt)
    tmp{1} = whitePt; tmp{2} = whitePt;
    whitePt = tmp;
end

% If the image and data format are in LMS, we convert them to XYZ here.
if strncmp(params.imageFormat,'lms',3)
    % We convert the LMS images and white points to XYZ10 space in here.
    for ii=1:2
        % The lms2xyz matrix is based on the Hunt-Pointer-Estevez method.
        T = colorTransformMatrix('hpe2xyz');
        image1 = imageLinearTransform(image1,T);
        image2 = imageLinearTransform(image2,T);
        
        % Convert the white points
        w = whitePt{1}; whitePt{1} = w(:)'*T;
        w = whitePt{2}; whitePt{2} = w(:)'*T;
        params.imageFormat = 'xyz10';
        
    end
end

% If we are in XYZ, we should call and then scComputeSCIELAB.
% Each dimension is clipped to fall between between 0 and whitePt{ii}. The
% white point is always biggest because XYZ are all positive.
% Perhaps we shouldn't clip ... we should just alert the user?
image1 = ClipXYZImage(image1, whitePt{1});
image2 = ClipXYZImage(image2, whitePt{2});

% These are the filters for spatial blurring.  They can take a
% while to create (and we should speed that up).
if isempty(params.filters)
    [params.filters, params.support] = scPrepareFilters(params);
end
% figure; imagesc(params.filters{2})

% Filter the image in opponent-colors space starting from lms or xyz.  The
% returned image is in XYZ.
xyz1 = scOpponentFilter(image1,params);  % figure; imagesc(xyz1(:,:,2))
xyz2 = scOpponentFilter(image2,params);  % figure; imagesc(xyz2(:,:,2))

% This is the place where we should separate the difference into two parts.
%  One part will just go on to spatial CIELAB as ever.  The other part of
%  the error image will get treated as a masked error.  Because it is
%  subtracted out of the error, the S-CIELAB error should be smaller and
%  the masked error - which will be real but small - will not push the
%  total error back up to the full value.

% % Find the error xyz2 = xyz1 + E;
% [r,c,w] = size(xyz2);
% E = xyz2 - xyz1;
%
% % Break the error into parts.
% % Find the part of the error that looks like the original:
% %  Solve:  E = a*xyz1
% masked    = xyz1(:)\E(:);           %
% unmaskedE = E(:) - masked*xyz1(:);  % Perpendicular (unmasked) error
% unmaskedXYZ2 = xyz1(:) + unmaskedE(:);
% unmaskedXYZ2 = reshape(unmaskedXYZ2,r,c,w);

% I think the following two calls should be an equivalent computation.  But
% it is not.  So I should figure out what's going on.
deltaEImage = scComputeDifference(xyz1,unmaskedXYZ2,whitePt,params.deltaEversion);
% figure; imagesc(deltaEImage); colorbar
% deltaEImage2 = scComputeDifference(xyz1,xyz2,whitePt,params.deltaEversion);
% figure; imagesc(deltaEImage2); colorbar

% Now do something with the masked error


%% End
% There are some differences between below and above.  Sigh.  Why.
%
% d1 = scComputeSCIELAB(xyz1,whitePt{1},params);
% r = size(d1,1); c = size(d1,2);
% d2 = scComputeSCIELAB(xyz2,whitePt{2},params);
% dE = deltaE2000(RGB2XWFormat(d1),RGB2XWFormat(d2));
% figure; plot(dE(:),deltaEImage(:),'.')
% figure; imagesc(reshape(dE,r,c)); colorbar

return;

