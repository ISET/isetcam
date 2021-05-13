function vSNR = xyz2vSNR(roiXYZ, whitePtXYZ, params)
%Calculate visual SNR from an XYZ image
%
%   vSNR = xyz2vSNR(roiXYZ,whitePtXYZ,params)
%
%
% Example:
%  params = scParams;
%
% Copyright ImagEval Consultants, LLC, 2009

if ieNotDefined('roiXYZ'), error('xyz data required'); end
if ieNotDefined('whitePtXYZ'), error('xyz white point required'); end
if ieNotDefined('params'), params = scParams; end

% figure(1); mesh(roiXYZ(:,:,2)); colormap(gray(255)); colormap(jet(255))
% xlabel('Display col'); ylabel('Display row'); zlabel('Luminance')
% figure(1); imagesc(roiXYZ(:,:,2))

% This routine has a sharp roll off at the edge.
% That is not good.  For the deltaE calculation, it might not have hurt us
% too bad because both images had it.  But for a reasonable representation
% of CIELAB, this rolloff is very bad.  It is dominating other factors.
% figure(1); Y=roiXYZ(:,:,2); mesh(Y); mean(Y(:))
sLAB = scComputeSCIELAB(roiXYZ, whitePtXYZ, params);
% xyz  = ieLAB2XYZ(sLAB,whitePtXYZ); % Might not be working right ... BW
% figure(1); L = sLAB(:,:,1); mesh(L); mean(L(:))
% xlabel('Display row'), ylabel('Display col'), zlabel('L*');
% sRGB = xyz2srgb(xyz); mesh(sRGB(:,:,2)); % imagesc(sRGB/255);

% Get the middle of the region to avoid edge artifacts from the S-CIELAB
% process
[r, c, w] = size(sLAB);
mid = round(0.8*[r, c]);
sLAB = getMiddleMatrix(sLAB, mid);
% xyz  = ieLAB2XYZ(sLAB,whitePtXYZ);
% figure(1); mesh(xyz(:,:,2));
% sRGB = xyz2srgb(xyz); figure(1); imagesc(sRGB/255);

m1 = sLAB(:, :, 1);
m2 = sLAB(:, :, 2);
m3 = sLAB(:, :, 3);
% figure(1); imagesc(m1);
% figure(1);
% subplot(3,1,1), histogram(m1(:),30); subplot(3,1,2); hist(m2(:),30)
% subplot(3,1,3);  histogram(m3(:),30)

% Image standard deviations over the uniform region
L = std(m1(:))^2;
A = std(m2(:))^2;
B = std(m3(:))^2;

% Here is the formula from the pixel binning paper
vSNR = 1 / sqrt(A+B+L); % When std <1 SNR > 0

return
