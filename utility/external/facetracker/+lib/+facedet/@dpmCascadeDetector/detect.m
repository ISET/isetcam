function dets = detect(obj,im)

dets = [];

pyra = obj.featpyramid(double(im));

% gather PCA root filters for convolution
numrootfilters = length(obj.csc_model.rootfilters);
rootfilters = cell(numrootfilters, 1);
for i = 1:numrootfilters
  rootfilters{i} = obj.csc_model.rootfilters{i}.wpca;
end

% compute PCA projection of the feature pyramid
projpyra = obj.project_pyramid(pyra);

% stage 0: convolution with PCA root filters is done densely
% before any pruning can be applied

% Precompute location/scale scores
loc_f      = obj.loc_feat(pyra.num_levels);
loc_scores = cell(obj.csc_model.numcomponents, 1);
for c = 1:obj.csc_model.numcomponents
  loc_w         = obj.csc_model.loc{c}.w;
  loc_scores{c} = loc_w * loc_f;
end
pyra.loc_scores = loc_scores;

numrootlocs = 0;
nlevels = size(pyra.feat,1);
rootscores = cell(obj.csc_model.numcomponents, nlevels);
s = 0;  % will hold the amount of temp storage needed by cascade()
for i = 1:pyra.num_levels
  s = s + size(pyra.feat{i},1)*size(pyra.feat{i},2);
  if i > obj.csc_model.interval
    scores = obj.fconv_var_dim(projpyra.feat{i}, rootfilters, 1, numrootfilters);
    for c = 1:obj.csc_model.numcomponents
      u = obj.csc_model.components{c}.rootindex;
      v = obj.csc_model.components{c}.offsetindex;
      rootscores{c,i} = scores{u} + obj.csc_model.offsets{v}.w + loc_scores{c}(i);
      numrootlocs = numrootlocs + numel(scores{u});
    end
  end
end
s = s*length(obj.csc_model.partfilters);
obj.csc_model.thresh = obj.thresh;
% run remaining cascade stages and collect object hypotheses
coords = obj.cascade(obj.csc_model, pyra, projpyra, rootscores, numrootlocs, s);

boxes = coords';
dets = boxes(:,[1:4 end-1 end]);
if(~isempty(dets))
    [dets, boxes, I] = obj.clipboxes(im, dets, boxes);
    I = obj.nms(dets,0.2); % 0.2
    dets = dets(I,:)';
end

end