function tests = test_extHistcn
 tests = functiontests(localfunctions);
end

function testKnownBinCounts(testCase)
% Analytic counts include repeated samples and the rightmost bin edge.
X = [0 0; 0 0; 0 1; 1 0; 1 1; 2 2];
[N,~,mid] = histcn(X,[-0.5 0.5 1.5 2.5],[-0.5 0.5 1.5 2.5]);
testCase.verifyEqual(N,[2 1 0; 1 1 0; 0 0 1]);
testCase.verifyEqual(sum(N,'all'),size(X,1));
testCase.verifyEqual(mid,{[0 1 2],[0 1 2]});
end

function testHistogramImage(testCase)
img = imread(fullfile(isetRootPath,'data','images','rgb','hats.jpg'));
img = img(1:15:end,1:15:end,:);
X = double(reshape(img(:,:,1:2),[],2));
[data,xy,~,fig] = ieHistImage(X,'hist type','histcn','plot flag',false);
expected = histcn(X,32,32);
testCase.verifyEqual(data,expected);
testCase.verifyEqual(sum(data,'all'),size(X,1));
testCase.verifyEqual(numel(xy),2);
testCase.verifyEmpty(fig);
end

function testScatterDensityWithoutGraphics(testCase)
% The scatplot backend used to create axes even with plot flag false.
before = findall(groot,'Type','figure');
img = imread(fullfile(isetRootPath,'data','images','rgb','hats.jpg'));
img = img(1:15:end,1:15:end,:);
X = unique(double(reshape(img(:,:,1:2),[],2)),'rows');
[data,xy,cmap,fig] = ieHistImage(X,'hist type','scatplot','plot flag',false);
testCase.verifySize(data,[100 100]);
testCase.verifyTrue(all(isfinite(data(:))));
testCase.verifyGreaterThanOrEqual(data,0);
testCase.verifyGreaterThan(max(data(:)),0);
testCase.verifyEqual(numel(xy),2);
testCase.verifySize(cmap,[256 3]);
testCase.verifyEmpty(fig);
testCase.verifyEqual(findall(groot,'Type','figure'),before);
end
