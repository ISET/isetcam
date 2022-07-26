%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef kltTracker < handle
    
    
    properties
        tc
    end

    methods

      function obj = kltTracker()
          obj.tc.nfeats=1000;       % max number of features
          obj.tc.winsize=3;        % window (feature) size is 2*x+1
          obj.tc.mindist=5;        % minimum distance between selected features
          
          obj.tc.mineigval=1/(255^6);   % minimum 2nd eigenvalue of slected features (must be >0)
          % NB: birchfield equivalent is 1/(255^2)
          
          obj.tc.maxresidual=10/255; % maximum residual (mean abs error) of tracked feature
          
          obj.tc.smooth_sigma_factor=0.1; % smooth image with sigma x*(2*winsize+1)
          obj.tc.grad_sigma=1;            % smooth with sigma for gradients
          
          obj.tc.pyramid_levels=2;    % number of pyramid levels (subsampled by 2)
          obj.tc.pyramid_sigma=1.8;   % smooth with sigma before subsampling
          
          obj.tc.maxiters=10;     % maximum iterations of newton method
          
          obj.tc.mindet=1e-2/(255^4);     % minimum determinant for position update
          
          obj.tc.mindisp=0.5;     % minimum change in position (pixels) before terminating
          
          % status codes
          
          obj.tc.klt_tracked=0;       % tracked
          obj.tc.klt_notfound=-1;     % no feature selected
          obj.tc.klt_smalldet=-2;     % fail: small determinant
          obj.tc.klt_maxiters=-3;     % fail: maximum iterations exceeded
          obj.tc.klt_oob=-4;          % fail: out of image/mask
          obj.tc.klt_largeresid=-5;   % fail: large residual
      end
      
      function M = detsToMask(obj,dets, frame, im, klt_mask)
          M = false(size(im, 1) , size(im, 2));
          v = find([dets.frame] == frame);
          for i = v
              bb = floor(dets(i).rect);
              bb([1,3]) = max(min(bb([1,3]), size(im, 2)), 1);
              bb([2,4]) = max(min(bb([2,4]), size(im, 1)), 1);
              if isempty(klt_mask)
                  M(bb(2):bb(4), bb(1):bb(3)) = true;
              else
                  boxsize = [bb(4) - bb(2) + 1, bb(3) - bb(1) + 1];
                  thismask = imresize(klt_mask, boxsize);
                  M(bb(2):bb(4), bb(1):bb(3)) = (thismask > 0);
              end
          end
      end
      
      
      % MRE_GAUSSIAN_FILTER   Gaussian filter
      %   J = mre_gaussian_filter(I,sigma,varargin) computes the convolution of I
      %   with a 2-D unit integral Gaussian filter of given sigma. Additional
      %   arguments are passed to imfilter() e.g. boundary settings.
      
      function J = gaussianFilter(obj,I,sigma,varargin)
          if sigma>0
              kw=ceil(3*sigma);
              k=exp(-(-kw:kw).^2/(2*sigma^2));
              k=k/sum(k);
              J=imfilter(imfilter(I,k,varargin{:}),k',varargin{:});
          else
              J=I;
          end
      end
      
      % MRE_GAUSSIAN_DERIV_FILTER   Gaussian derivative filter
      %   [DX,DY] = mre_gaussian_deriv_filter(I,sigma,varargin) computes the
      %   convolution of I with X and Y Gaussian derivatives of given sigma
      %   (equivalent Gaussian has unit integral). Additional
      %   arguments are passed to imfilter() e.g. boundary settings.
      
      function [DX,DY] = gaussianDerivFilter(obj,I,sigma,varargin)
          
          kw=ceil(3*sigma);
          x=-kw:kw;
          kg=exp(-x.*x/(2*sigma^2))/sqrt(2*pi*sigma^2);
          kd=kg.*x;
          DX=imfilter(imfilter(I,kg',varargin{:}),kd,varargin{:});
          DY=imfilter(imfilter(I,kg,varargin{:}),kd',varargin{:});

      end
      
      function pyr = kltPyramid(obj,tc,I)
          
          ww=2*tc.winsize+1;
          I=obj.gaussianFilter(I,tc.smooth_sigma_factor*ww,'replicate');
          
          pyr=cell(tc.pyramid_levels,1);
          for i=1:tc.pyramid_levels
              pyr{i}.I=I;
              [pyr{i}.GX,pyr{i}.GY]=obj.gaussianDerivFilter(I,tc.grad_sigma,'replicate');
              if i+1<=tc.pyramid_levels
                  I=obj.gaussianFilter(I,tc.pyramid_sigma,'replicate');
                  I=I(1:2:size(I,1),1:2:size(I,2));
              end
          end
      end
      
      % KLT_PARSE_SPARSE  Parse output of KLT tracker
      % [TX,TY,v] = klt_parse_sparse(P) parses the output of the KLT tracker into
      % distinct tracks. P is a 3 x nfeats x nframes array formed by
      % concatenating the per-frame output of KLT_SELFEATS and KLT_TRACK. TX and
      % TY are nframes x nfeats sparse matrices containing x and y coordinates
      % respectively. v is a vector of ntracks elements containing the 'goodness'
      % i.e. smaller eigenvalue of the feature in the first frame in which it
      % appears.
      %
      % See also KLT_INIT, KLT_SELFEATS, KLT_TRACK.
      
      function [TX,TY,v] = kltParseSparse(obj,P)
          
          nf=size(P,2);
          ni=size(P,3);
          nt=sum(sum(P(3,:,:)>0));
          
          TX=sparse(ni,nt);
          TY=sparse(ni,nt);
          v=zeros(nt,1);
          
          %tic;
          k=0;
          for i=1:nf
%               if toc>1
%                   fprintf('klt_parse_sparse: %d/%d\n',i,nf);
%                   tic;
%               end
              for j=1:ni
                  if P(3,i,j)>0
                      k=k+1;
                      v(k)=P(3,i,j);
                  end
                  if P(3,i,j)>=0
                      TX(j,k)=P(1,i,j);
                      TY(j,k)=P(2,i,j);
                  end
              end
          end
          
      end
      
      function tracks = updateTracksLen(obj,tracks)
          if ~isfield(tracks, 'track')
              return
          end
          ids = cat(1, tracks(:).track);
          uids = unique(ids);
          for i = 1:length(uids)
              ind = find(ids == uids(i));
              for j = 1:length(ind)
                  tracks(ind(j)).tracklength = length(ind);
              end
          end
      end
      
      function tracks = updateTracksConf(obj,tracks)
          if ~isfield(tracks, 'track')
              return
          end
          ids = cat(1, tracks(:).track);
          uids = unique(ids);
          for i = 1:length(uids)
              ind = find(ids == uids(i));
              conf = cat(1, tracks(ind).conf);
              trackconf = mean(conf(~isinf(conf)));
              if isnan(trackconf) trackconf = -inf; end
              for j = 1:length(ind)
                  tracks(ind(j)).trackconf = trackconf;
              end
          end
      end

      [dets,nc] = trackInShots(obj,video,dets, s1, s2, klt_mask,nc)
      [tc,P] = kltSelfeats(obj,tc,I,M,P);
      eG = boxFilter(obj,G,boxHeight,boxWidth);
      EV = kltGoodFeats(obj,M,GXX,GYY,GXY,mineigval);
      [m,mi]=maxElem(obj,EV);
      [tc,P] = kltTrack(obj,tc,P,I,M,Pp);
      P = kltMexTrack(obj,tc,oldpyr,P,Pp,M);
      clus = aggClust(obj,C, th);
      dets = track(obj,video,shots,dets,outPath);
    end

end
