%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef dpmCascadeDetector < handle
    
    
    properties
        csc_model
        padx
        pady
        p
        thresh
    end

    methods

      function obj = dpmCascadeDetector(modelPath)
            obj.thresh = 0; % -0.2;
            temp = load(modelPath);
            obj.csc_model = temp.csc_model;
            
            obj.padx = ceil(obj.csc_model.maxsize(2));
            obj.pady = ceil(obj.csc_model.maxsize(1));
            obj.p =  [10  9  8  7  6  5  4  3  2 ... % 1st set of contrast sensitive features
              1 18 17 16 15 14 13 12 11 ... % 2nd set of contrast sensitive features
              19 27 26 25 24 23 22 21 20 ... % Contrast insensitive features
              30 31 28 29 ...                % Gradient/texture energy features
              32];                           % Boundary truncation feature
      end
      
      function p = project(obj,f, coeff)
            
            % p = project(f, coeff)
            %
            % project filter f onto PCA eigenvectors (columns of) coeff
            
            sz = size(f);
            p = reshape(f, [sz(1)*sz(2) sz(3)]);
            p = p * coeff;
            sz(3) = size(coeff, 2);
            p = reshape(p, sz);
            
      end  
      
      function pyra = project_pyramid(obj,pyra)
          
          % pyra = project_pyramid(model, pyra)
          %
          % Project feature pyramid pyra onto PCA eigenvectors stored
          % in model.coeff.
          
          for i = 1:pyra.num_levels
              pyra.feat{i} = obj.project(pyra.feat{i}, obj.csc_model.pca_coeff);
          end
      end
      
      function f = loc_feat(obj,num_levels)
          % Location and scale features.
          %   f = loc_feat(model, num_levels)
          %
          %   Compute a feature indicating if level i is in the first octave of
          %   the feature pyramid, the second octave, or above. This could be
          %   generalized to a "location feature" instead of just a scale feature.
          %
          % Return value
          %   f = [f_1, ..., f_i, ..., f_num_levels],
          %   where f_i is the 3x1 vector =
          %     [1; 0; 0] if 1 <= i <= model.interval
          %     [0; 1; 0] if model.interval+1 <= i <= 2*model.interval
          %     [0; 0; 1] if 2*model.interval+1 <= i <= num_levels
          %
          % Arguments
          %   model       Model used for detection
          %   num_levels  Number of levels in the feature pyramid
          
          f = zeros(3, num_levels);
          
          b = 1;
          e = min(num_levels, obj.csc_model.interval);
          f(1, b:e) = 1;
          
          b = e+1;
          e = min(num_levels, 2*e);
          f(2, b:e) = 1;
          
          b = e+1;
          f(3, b:end) = 1;
      end
      
      
      function im = color(obj,input)
          % Convert input image to color.
          %   im = color(input)
          
          if size(input, 3) == 1
              im(:,:,1) = input;
              im(:,:,2) = input;
              im(:,:,3) = input;
          else
              im = input;
          end
      end
      
      
      function f = flipfeat(obj,f)
          % Horizontally flip HOG features (or filters).
          %   f = flipfeat(f)
          %
          %   Used for learning models with mirrored filters.
          %
          % Return value
          %   f   Output, flipped features
          %
          % Arguments
          %   f   Input features
          
          % flip permutation

          f = f(:,end:-1:1,obj.p);

      end
      
      function [ds, bs, I] = clipboxes(obj,im, ds, bs)
          % Clip detection windows to image the boundary.
          %   [ds, bs, I] = clipboxes(im, ds, bs)
          %
          %   Any detection that is entirely outside of the image (i.e., it is entirely
          %   inside the padded region of the feature pyramid) is removed.
          %
          % Return values
          %   ds      Set of detection bounding boxes after clipping
          %           and (possibly) pruning
          %   bs      Set of filter bounding boxes after clipping and
          %           (possibly) pruning
          %   I       Indicies of pruned entries in the original ds and bs
          %
          % Arguments
          %   im      Input image
          %   ds      Detection bounding boxes (see pascal_test.m)
          %   bs      Filter bounding boxes (see pascal_test.m)
          
          if nargin < 3
              bs = [];
          end
          
          if ~isempty(ds)
              ds(:,1) = max(ds(:,1), 1);
              ds(:,2) = max(ds(:,2), 1);
              ds(:,3) = min(ds(:,3), size(im, 2));
              ds(:,4) = min(ds(:,4), size(im, 1));
              
              % remove invalid detections
              w = ds(:,3)-ds(:,1)+1;
              h = ds(:,4)-ds(:,2)+1;
              I = find((w <= 0) | (h <= 0));
              ds(I,:) = [];
              if ~isempty(bs)
                  bs(I,:) = [];
              end
          end
      end
      
      function pick = nms(obj,boxes, overlap)
          % Non-maximum suppression.
          %   pick = nms(boxes, overlap)
          %
          %   Greedily select high-scoring detections and skip detections that are
          %   significantly covered by a previously selected detection.
          %
          % Return value
          %   pick      Indices of locally maximal detections
          %
          % Arguments
          %   boxes     Detection bounding boxes (see pascal_test.m)
          %   overlap   Overlap threshold for suppression
          %             For a selected box Bi, all boxes Bj that are covered by
          %             more than overlap are suppressed. Note that 'covered' is
          %             is |Bi \cap Bj| / |Bj|, not the PASCAL intersection over
          %             union measure.
          
          if isempty(boxes)
              pick = [];
          else
              x1 = boxes(:,1);
              y1 = boxes(:,2);
              x2 = boxes(:,3);
              y2 = boxes(:,4);
              s = boxes(:,end);
              area = (x2-x1+1) .* (y2-y1+1);
              
              [vals, I] = sort(s);
              pick = [];
              while ~isempty(I)
                  last = length(I);
                  i = I(last);
                  pick = [pick; i];
                  suppress = [last];
                  for pos = 1:last-1
                      j = I(pos);
                      xx1 = max(x1(i), x1(j));
                      yy1 = max(y1(i), y1(j));
                      xx2 = min(x2(i), x2(j));
                      yy2 = min(y2(i), y2(j));
                      w = xx2-xx1+1;
                      h = yy2-yy1+1;
                      if w > 0 && h > 0
                          % compute overlap
                          o = w * h / area(j);
                          if o > overlap
                              suppress = [suppress; pos];
                          end
                      end
                  end
                  I(suppress) = [];
              end
          end
      end

      C = fconv_var_dim(obj, A, B, star_val, end_val);
      im = resize(obj,img,scale);
      det = detect(obj,img);
      pyra = featpyramid(obj,im);  
      hog = features(obj,img,cellsize);
      coords = cascade(obj,model, pyra, projpyra, rootscores, numrootlocs, s);  


    end

end
