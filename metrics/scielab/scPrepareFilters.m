function [filters,support,params] = scPrepareFilters(params)
% Prepare the spatial filters for S-CIELAB opponent blurring
%
%   [filters,support,params]  = scPrepareFilters(params)
%
% Create three pattern-color separable filters according to the Poirson &
% Wandell 1993 fitted spatial response. The filters are each weighted
% sum of 2 or 3 gaussians.  They are in the cell array, filters.
%
% The params structure defines several properties of the features.
% The two important slots are
%
% sampPerDeg -- filter resolution in samples per degree of visual angle.
% Minimum sample rate is recommended as 224 samples per degree of visual
% angle.  Code issues a warning of the sample rate is smaller than 100.
%
% dimension:  Specifies whether the created filters should be 1-D or 2-D.
% These are obscure conditions (normally 2 is used) and we need to improve
% the comments here.
%
%   dimension = 1: generate the linespread of the filters;
%	This is useful for 1-d image calculations, say for theoretical
%	work.
%
%   dimension = 2: generate the pointspread of the filters;
%	This is useful if you just want to create an image of the filters
%
%   dimension = 3: generate the pointspread in the form that can be used by
% 	separableConv.  The result is a set of 1-d filters that can be applied
%	to the rows and cols of the image (separably).  This is not used in
%	ISET, but it may be used elsewhere.
%
% The filters are a cell array.  The support defines the spatial support in
% terms of degrees of visual angle.
%
% Example:
%   params.deltaEversion = '2000';
%   params.sampPerDeg    = 145;
%   params.imageFormat   = 'LMS';
%   params.filterSize    = 145;
%   params.dimension     = 2;
%   [filters,support]    = scPrepareFilters(params);
%
%   figure;   % Units are degrees of visual angle
%   subplot(1,3,1), mesh(support,support,filters{1}); colormap(hsv(256));
%   subplot(1,3,2), mesh(support,support,filters{2}); colormap(hsv(256));
%   subplot(1,3,3), mesh(support,support,filters{3}); colormap(hsv(256));
%
% In 1996, Xuemei Zhang used this routine
%   [k1, k2, k3] = separableFilters(params.sampPerDeg,2);
%   figure(1); clf
%   subplot(1,2,1), mesh(support,support,filters{3})
%   subplot(1,2,2), mesh(support,support,k1)
%
% The values are the same
%   figure(1); clf, mesh(support,support,k1-filters{1})
%   figure(1); clf, mesh(support,support,k2-filters{2})
%   figure(1); clf, mesh(support,support,k3-filters{3})
%
% Copyright ImagEval Consultants, LLC, 2003.

% Check parameters
if ieNotDefined('params'), error('Params required.'); end
if ~checkfields(params,'sampPerDeg'), params.sampPerDeg = 224; end
if ~checkfields(params,'dimension'),  params.dimension = 2; end

sampPerDeg = params.sampPerDeg;
dimension  = params.dimension;
filters = cell(1,3);

% We would like to have enough samples to support at least 30 cy/deg or
% more.  So we create the filters with 100 samp/deg at a minimum.  If the
% image is sampled at a lower value than that, we will linearly interpolate
% the data.  Perhaps that isn't quite right, but it is a plan.
minSAMPPERDEG = 100;
%
% Maybe this warning should be on ... we should do more testing
%
% if ((sampPerDeg < minSAMPPERDEG) && dimension==2)
%   warning('sampPerDeg (%.0f) smaller than recommended (%.0f)\n',...
%       sampPerDeg,minSAMPPERDEG);
% end

% Verify the user supplied filter support.  If it is missing, we make sure
% set the support to 0.5 deg.
if ~checkfields(params,'filterSize')
    params.filterSize = (params.sampPerDeg/2);
end

% We allow sampPerDeg to be non-integer.  For the support, we need to make
% it an integer.  So we adjust filterSize upward.
params.filterSize = ceil(params.filterSize);
filterSize = params.filterSize;

% For the support to be an odd number of points so that the gaussians are
% symmetric
if isodd(filterSize),support = filterSize;
else,                support = filterSize - 1; params.filterSize = support;
end

% Retrieve the parameters will be used to create the Gaussian filters that
% make up the SCIELAB filters.
[x1, x2, x3] = scGaussianParameters(sampPerDeg,params);

% Generate the filters
if (dimension == 1 || dimension == 2)
    
    % This is the most common case (dimension == 2) for handling an image
    % I think.
    filters{1} = sumGauss([support x1], dimension);
    filters{2} = sumGauss([support x2], dimension);
    filters{3} = sumGauss([support x3], dimension);
    
elseif dimension == 3
    % Compute the individual Gaussians rather than the sums of Gaussians.
    % These Gaussians are used in the row and col separable convolutions.
    disp('1D solution returned.')
    
    % The three 1-d kernels that are used by the light/dark system
    filters{1} = [gauss(x1(1), support) * sqrt(abs(x1(2))) * sign(x1(2)); ...
        gauss(x1(3), support) * sqrt(abs(x1(4))) * sign(x1(4)); ...
        gauss(x1(5), support) * sqrt(abs(x1(6))) * sign(x1(6))];
    
    % The two 1-d kernels used by red/green
    filters{2} = [gauss(x2(1), support) * sqrt(abs(x2(2))) * sign(x2(2)); ...
        gauss(x2(3), support) * sqrt(abs(x2(4))) * sign(x2(4))];
    
    % The two 1-d kernels used by blue/yellow
    filters{3} = [gauss(x3(1), support) * sqrt(abs(x3(2))) * sign(x3(2)); ...
        gauss(x3(3), support) * sqrt(abs(x3(4))) * sign(x3(4))];
end

% Adjust the sampling rate higher in certain cases.  I don't understand
% this or when it is used.
if ( (sampPerDeg < minSAMPPERDEG) && (dimension ~= 2) )
    uprate = ceil(minSAMPPERDEG/sampPerDeg);
    sampPerDeg = sampPerDeg * uprate;
    % filterSize = filterSize * uprate;
else,  uprate = 1;
end

% upsample and downsample
if ( ((dimension==1) || (dimension==3)) && (uprate>1) )
    disp('Upsampling and down sampling.')
    upcol = [1:uprate (uprate-1):(-1):1]/uprate;

    % Mike Vrhel caught this as an error, saying we should not apply
    % the commented out code to change upcol.  See his comments in the
    % patch below. 
    %   s = length(upcol);
    %   upcol = resize(upcol, [1 s+support-1]);
    up1 = conv2(filters{1}, upcol, 'same');
    up2 = conv2(filters{2}, upcol, 'same');
    up3 = conv2(filters{3}, upcol, 'same');

    s = size(up1, 2);
    mid = ceil(s/2);
    downs = [fliplr((mid:(-uprate):1)) (mid+uprate):uprate:size(up1,2)];
    filters{1} = up1(:, downs);
    filters{2} = up2(:, downs);
    filters{3} = up3(:, downs);
end

% Set up the spatial support for the return; support is specified in
% degrees of visual angle.
support = (1:support);
support = support - mean(support(:));
support = support/sampPerDeg;

return;

%{
From b73f0794f177591abae67cac347c0182d33d6f41 Mon Sep 17 00:00:00 2001
From: Michael Vrhel <michael@mvrhel.com>
Date: Tue, 27 Feb 2024 21:07:16 -0800
Subject: [PATCH] sCIELAB filter creation fix

In the case when the filters are interpolated and subsampled, keep
the interpolation kernel centered prior to the convolution.
---
 metrics/scielab/scPrepareFilters.m | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/metrics/scielab/scPrepareFilters.m b/metrics/scielab/scPrepareFilters.m
index 0d5a1b90..2c7fb7a9 100644
--- a/metrics/scielab/scPrepareFilters.m
+++ b/metrics/scielab/scPrepareFilters.m
@@ -143,8 +143,15 @@ end
 if ( ((dimension==1) || (dimension==3)) && (uprate>1) )
     disp('Upsampling and down sampling.')
     upcol = [1:uprate (uprate-1):(-1):1]/uprate;
-    s = length(upcol);
-    upcol = resize(upcol, [1 s+support-1]);
+
+    % Note that the use of 'same' in the convolution works as intended here
+    % if the interpolation kernel and the filter are each centered in 
+    % their support. Padding the interpolator with zeros to the right and using
+    % 'same' in the convolution will end up giving you back a filter that
+    % is half the support that you want, not to mention shifted to the
+    % left.
+    %s = length(upcol);
+    %upcol = resize(upcol, [1 s+support-1]);
     up1 = conv2(filters{1}, upcol, 'same');
     up2 = conv2(filters{2}, upcol, 'same');
     up3 = conv2(filters{3}, upcol, 'same');
-- 
2.39.0.windows.2
%}
