function [filteredXYZ,filteredOpp] = scOpponentFilter(image, params)
% scOpponentFilter - spatial cielab spatial filter in opponent colors space
%
%   [filteredXYZ, filteredOpp] = scOpponentFilter(image, params)
%
% Spatial CIELAB calculation spatially filters the image data in
% opponent-colors space. This routine takes in input image in xyz or lms
% space, converts it to opponent color space, and applies the spatial
% filtering required by S-CIELAB.
%
% The returned image, filteredIm, is converted into CIE-XYZ space.
%
% Example
%  See the script s_scExperiments for examples. They are a bit long for
%  here.  This function is normally called from SCIELAB functions.
%
% Copyright ImagEval Consultants, LLC, 2009.

if (size(image,1)>1 && size(image,2)>3),  dimension = 2;
else                                      dimension = 1;
end

% Convert XYZ or LMS representation to Poirson & Wandell opponent
% representation.
if strncmp(params.imageFormat,'xyz10',5) || ...
        strncmp(params.imageFormat,'lms10',5),
    xyztype = 10;
else xyztype = 2;
end

% Convert the images into opponent space, and if necessary convert the
% white points into XYZ space.
switch lower(params.imageFormat(1:3))
    case 'lms'
        opp = imageLinearTransform(image,colorTransformMatrix('lms2opp'));
        % opp2 = changeColorSpace(image, cmatrix('lms2opp'));
        % figure(1); imagescRGB(opp);
    case 'xyz'
        opp = imageLinearTransform(image,colorTransformMatrix('xyz2opp', xyztype));
        % opp2 = changeColorSpace(image, cmatrix('xyz2opp', xyztype));
        % plot(opp(:),opp2(:),'.')
    otherwise
        error('Bad image format.');
end

% figure; imagescRGB(opp);


%%  Spatial Filtering
% Apply the filters to the images.
% Look at the image before filtering:
% figure(1); Y = opp(:,:,1); mesh(Y); colormap(jet(255)); mean(Y(:))
% The first opponent dimension is not precisely Y and thus doesn't have
% luminance units.
filteredOpp = scApplyFilters(opp, params.filters, dimension);
% figure; mesh(filteredOpp(:,:,1)); imagescRGB(filteredOpp);

filteredXYZ = imageLinearTransform(filteredOpp,colorTransformMatrix('opp2xyz', xyztype));
% Look at the Y image, which is all positive
% figure; mesh(filteredXYZ(:,:,2)); imagescRGB(filteredXYZ(:,:,2));

return;