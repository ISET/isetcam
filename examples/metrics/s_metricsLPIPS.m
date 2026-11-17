%% Equal MSE, different appearance: blur versus mild global dimming.
% MATLAB R2021a+; toolboxes optional. Official VGG-16 / BAPPS-v0.1 weights.
% First run downloads about 528 MiB; later runs use the local MAT cache.
% Internet and a Java-enabled MATLAB session are needed for the first download.
% The generated lpips_vgg16_weights.mat stays beside this script.
% Reference: https://richzhang.github.io/PerceptualSimilarity/

blurSigma = 1.8;  % Gaussian blur standard deviation, in image pixels.
showLayer = 3;  % 1..5: choose the layer to illustrate in detail.
assert(ismember(showLayer,1:5));
demoDir = fileparts(mfilename('fullpath'));

%% 1. Matched-MSE images
% We make a toy example of more and less perceptually noticeable changes,
% while keeping mean squared error (MSE) the same.
%
% Here we compare blurred and dimmed versions of a reference image.
% These are just examples; other images and distortions can be tested.
imageDir = fullfile(isetRootPath, 'data', 'images', 'rgb');
reference = single(imread(fullfile(imageDir, 'hats.jpg'))) / 255;
% Separable Gaussian, with replicated borders; base MATLAB only.
radius = ceil(3*blurSigma);
g = exp(-(-radius:radius).^2/(2*blurSigma^2)); g = single(g/sum(g));
[h,w,~] = size(reference);
padded = reference([ones(1,radius),1:h,h*ones(1,radius)], ...
    [ones(1,radius),1:w,w*ones(1,radius)],:);
blurred = zeros(size(reference),'single');
for c = 1:3
    blurred(:,:,c) = conv2(g',g,padded(:,:,c),'valid');
end
targetMSE = mean((double(blurred(:))-double(reference(:))).^2);
gain = 1 - sqrt(targetMSE/mean(double(reference(:)).^2));
assert(gain > 0 && gain < 1, 'Choose a milder blur.');
dimmed = gain * reference;  % Display-encoded RGB gain; no clipping needed.
fprintf('Dimming: gain = %.6f (%.2f%% of each original encoded RGB value).\n', ...
    gain,100*gain);
degraded = cat(4,blurred,dimmed);
pixelError = double(degraded) - double(reference);
mseValues = mean(reshape(pixelError.^2,[],2),1).';
assert(abs(diff(mseValues))/targetMSE < 1e-5, 'MSE matching failed.');
distortionNames = {'Blur','Dimming'};

figure('Name','Equal MSE, different appearance', 'Color','w', 'Position',[80 80 1100 370]);
tiledlayout(1,3, 'TileSpacing','compact');
nexttile; image(reference); axis image off; title('Reference: hats.jpg');
nexttile; image(blurred); axis image off;
title({sprintf('Blur: sigma = %.1f px',blurSigma),sprintf('MSE = %.6g',mseValues(1))});
nexttile; image(dimmed); axis image off;
title({sprintf('RGB gain = %.3f (detail preserved)',gain),sprintf('MSE = %.6g',mseValues(2))});
lightFigure(gcf);

%% 2. Extract VGG features using the EXACT backbone used by official LPIPS.
weightsFile = fullfile(demoDir, 'lpips_vgg16_weights.mat');
if ~isfile(weightsFile)
    fprintf('First run: downloading official VGG-16 and BAPPS weights (~528 MiB).\n');
    rebuild_lpips_weights;
end
weights = load(weightsFile);
layerNames = {'relu1_2', 'relu2_2', 'relu3_3', 'relu4_3', 'relu5_3'};
% v0.1 ScalingLayer: [0,1] -> [-1,1] -> channel standardization.
shift = reshape(single([-.030, -.088, -.188]), 1,1,3);
scale = reshape(single([ .458,  .448,  .450]), 1,1,3);
networkInput = (2 * cat(4,reference,degraded) - 1 - shift) ./ scale;
features = cell(1,5);
if exist('vgg16','file') == 2
    net = officialVGG(weights, size(reference));
    [features{:}] = predict(net, dlarray(networkInput, 'SSCB'), 'Outputs', layerNames);
    features = cellfun(@extractdata, features, 'UniformOutput',false);
    fprintf('VGG features: Deep Learning Toolbox, official pretrained weights.\n');
else
    features = baseVGG(networkInput, weights);
    fprintf('VGG features: base MATLAB, official pretrained weights.\n');
end

%% 3. Original LPIPS aggregation: spatial mean in each layer, then SUM layers.
% d = sum_l mean_hw sum_c alpha_lc * (fhat_ref - fhat_test)^2.
% Unweighted: alpha=1. Learned: BAPPS 1x1-conv coefficients, applied ONCE.
unweighted = zeros(2,1); learned = zeros(2,1);
for l = 1:5
    f = features{l};  % H x W x C x 3: reference, blur, dimming.
    unit = f ./ (sqrt(sum(f.^2,3)) + single(1e-10));
    squaredDifference = (unit(:,:,:,1) - unit(:,:,:,2:3)).^2;
    rawMap = sum(squaredDifference,3);
    weightedMap = sum(squaredDifference .* weights.linearWeights{l},3);
    unweighted = unweighted + double(mean(reshape(rawMap,[],2),1)).';
    learned = learned + double(mean(reshape(weightedMap,[],2),1)).';
    if l == showLayer
        % Pick one informative channel; the metric itself uses EVERY channel.
        a = f(:,:,:,1);
        [~,channel] = max(reshape(sum(sum(a.^2,1),2), [],1));
        detail.raw = f(:,:,channel,:);
        detail.unit = unit(:,:,channel,1);
        detail.unweighted = rawMap; detail.learned = weightedMap;
    end
end
% Sum all five layer distances; no channel/layer average or final sqrt.
scores = table(mseValues, unweighted, learned, 'RowNames',distortionNames, ...
    'VariableNames', {'MSE','Unweighted_LPIPS','BAPPS_LPIPS'});
disp(scores);
fprintf('MSE relative mismatch: %.3g. All three distances: smaller is better.\n', ...
    abs(diff(mseValues))/targetMSE);

%% 4. One feature walkthrough: activations -> normalization -> square -> weight.
figure('Name','Inside LPIPS', 'Color','w', 'Position',[100 80 1150 950]);
tiledlayout(3,3, 'TileSpacing','compact');
maps = {detail.raw(:,:,1,1), detail.raw(:,:,1,2), detail.raw(:,:,1,3), ...
    detail.unit, detail.unweighted(:,:,1,1), detail.unweighted(:,:,1,2), ...
    [], detail.learned(:,:,1,1), detail.learned(:,:,1,2)};
labels = {'Reference activation','Blur activation','Dimming activation', ...
    'Reference unit feature','Blur: unweighted error','Dimming: unweighted error', ...
    'BAPPS channel weights','Blur: weighted error','Dimming: weighted error'};
for k = 1:9
    nexttile;
    if k == 7
        bar(reshape(weights.linearWeights{showLayer},[],1)); xlabel('Channel'); ylabel('alpha');
    else
        imagesc(maps{k}); axis image off; colorbar;
        % Each comparison shares limits across distortions.
        if k <= 3, set(gca,'CLim',[0 max(detail.raw(:))]); end
        if ismember(k,[5 6]), set(gca,'CLim',[0 max(detail.unweighted(:))]); end
        if ismember(k,[8 9]), set(gca,'CLim',[0 max(detail.learned(:))]); end
    end
    title(labels{k});
end
colormap(parula);
fprintf('Feature display: %s, channel %d; error maps sum all channels.\n', ...
    layerNames{showLayer},channel);
lightFigure(gcf);

%% 5. Compare the two distortions using the final aggregate distances.
figure('Name','Metric comparison: lower is better', 'Color','w', ...
    'Position',[120 100 1100 380]);
tiledlayout(1,3, 'TileSpacing','compact');
values = [mseValues,unweighted,learned];
metricNames = {'MSE (matched)','Unweighted LPIPS','BAPPS-weighted LPIPS'};
for k = 1:3
    nexttile; bar(values(:,k)); xticks(1:2); xticklabels(distortionNames);
    title(metricNames{k}); ylabel('Distance'); grid on;
end
lightFigure(gcf);

%% Local helpers: built-in VGG, a base-MATLAB fallback, and figure styling.
function net = officialVGG(weights, inputSize)
% Built-in topology; transferred official weights preserve calibration.
% MATLAB's default pretrained vgg16 checkpoint/preprocessing is different.
layers = vgg16('Weights','none');  % No VGG support package required.
last = find(strcmp({layers.Name}, 'relu5_3'), 1);
layers = layers(1:last);  % Remove pool5 and the classification head.
layers(1) = imageInputLayer(inputSize, 'Normalization','none', 'Name',layers(1).Name);
indices = find(arrayfun(@(x) isa(x,'nnet.cnn.layer.Convolution2DLayer'), layers));
assert(numel(indices) == 13);
for j = 1:13
    assert(strcmp(layers(indices(j)).Name, weights.convNames{j}));
    layers(indices(j)).Weights = weights.convWeights{j};
    layers(indices(j)).Bias = weights.convBias{j};
end
net = dlnetwork(layerGraph(layers));
end

function features = baseVGG(x, weights)
% Same VGG-16 convolutions/ReLUs/max-pooling using only base MATLAB.
% Each kernel tap is a matrix multiply over input/output channels.
features = cell(1,5);
depth = [2 2 3 3 3]; j = 0;
for l = 1:5
    for q = 1:depth(l)
        j = j + 1;
        [h,w,cin,batch] = size(x);
        cout = size(weights.convWeights{j},4);
        padded = zeros(h+2,w+2,cin,batch,'single');
        padded(2:h+1,2:w+1,:,:) = x;
        y = zeros(h*w*batch,cout,'single');
        for r = 1:3
            for c = 1:3
                patch = permute(padded(r:r+h-1,c:c+w-1,:,:), [1 2 4 3]);
                kernel = reshape(weights.convWeights{j}(r,c,:,:), cin,cout);
                y = y + reshape(patch,[],cin) * kernel;
            end
        end
        x = max(permute(reshape(y,h,w,batch,cout),[1 2 4 3]) + weights.convBias{j},0);
    end
    features{l} = x;
    if l < 5
        % Unpadded 2x2 max-pool, stride 2; discard incomplete border cells.
        hh = 2*floor(size(x,1)/2); ww = 2*floor(size(x,2)/2);
        x = max(max(x(1:2:hh,1:2:ww,:,:), x(2:2:hh,1:2:ww,:,:)), ...
            max(x(1:2:hh,2:2:ww,:,:), x(2:2:hh,2:2:ww,:,:)));
    end
end
end

function lightFigure(fig)
% Keep exported text readable even when MATLAB itself uses a dark theme.
set(findall(fig,'Type','axes'), 'Color','w', 'XColor','k', 'YColor','k');
set(findall(fig,'Type','text'), 'Color','k');
set(findall(fig,'Type','colorbar'), 'Color','k');
end

function rebuild_lpips_weights
% REBUILD_LPIPS_WEIGHTS Download and cache official weights using MATLAB alone.
% Downloads about 528 MiB on the first run; saves the converted MAT file locally.
% This reads float32 tensors at known offsets in TWO CHECKSUM-PINNED official
% legacy PyTorch checkpoints. It is deliberately not a general pickle reader.
% No Python, PyTorch installation, or model-import add-on is used.
demoDir = fileparts(mfilename('fullpath'));
workDir = tempname;
mkdir(workDir);
cleanup = onCleanup(@() rmdir(workDir,'s')); %#ok<NASGU>
commit = '082bb24f84c091ea94de2867d34c4544f68e0963';
checkpointUrls = { ...
    'https://download.pytorch.org/models/vgg16-397923af.pth', ...
    ['https://raw.githubusercontent.com/richzhang/PerceptualSimilarity/' ...
    commit '/lpips/weights/v0.1/vgg.pth']};
checkpointSha256 = { ...
    '397923af8e79cdbb6a7127f12361acd7a2f83e06b05044ddf496e83de57a5bf0', ...
    'a78928a0af1e5f0fcb1f3b9e8f8c3a2a5a3de244d830ad5c1feddc79b8432868'};
vggFile = fullfile(workDir,'vgg16.pth');
linearFile = fullfile(workDir,'vgg_lpips.pth');
downloadChecked(checkpointUrls{1}, vggFile, 553433881, checkpointSha256{1});
downloadChecked(checkpointUrls{2}, linearFile, 7289, checkpointSha256{2});

% Each row: input channels, output channels, weight offset, bias offset.
% Offsets are zero-based byte positions of little-endian float32 data.
layout = [ ...
      3  64 553426969   446625
     64  64      3457   150921
     64 128    151185   446105
    128 128   2807225  3397057
    128 256   3397577  4577233
    256 256   4578265  6937569
    256 256    446889  2806193
    256 512  16377849 21096449
    512 512  21098505 30535697
    512 512  30537753 39974945
    512 512  39977001 49414193
    512 512   6938601 16375793
    512 512  49416249 58853441];
convNames = {'conv1_1','conv1_2','conv2_1','conv2_2', ...
    'conv3_1','conv3_2','conv3_3','conv4_1','conv4_2','conv4_3', ...
    'conv5_1','conv5_2','conv5_3'};
convWeights = cell(1,13); convBias = cell(1,13);
fid = fopen(vggFile,'r','ieee-le');
assert(fid >= 0); closeVGG = onCleanup(@() fclose(fid));
for j = 1:13
    cin = layout(j,1); cout = layout(j,2);
    values = readFloats(fid, layout(j,3), 3*3*cin*cout);
    % Torch [out,in,y,x] row-major -> MATLAB [y,x,in,out] column-major.
    % Both frameworks perform cross-correlation: no spatial kernel flip.
    convWeights{j} = permute(reshape(values,3,3,cin,cout), [2 1 3 4]);
    convBias{j} = reshape(readFloats(fid,layout(j,4),cout), 1,1,cout);
end
clear closeVGG
channels = [64 128 256 512 512];
offsets = [6001 5481 6265 3425 1369];
linearWeights = cell(1,5);
fid = fopen(linearFile,'r','ieee-le');
assert(fid >= 0); closeLinear = onCleanup(@() fclose(fid));
for l = 1:5
    linearWeights{l} = reshape(readFloats(fid,offsets(l),channels(l)), 1,1,[]);
    assert(all(isfinite(linearWeights{l}(:))) && all(linearWeights{l}(:) >= 0));
end
clear closeLinear
save(fullfile(demoDir,'lpips_vgg16_weights.mat'), 'convNames','convWeights', ...
    'convBias','linearWeights','checkpointUrls','checkpointSha256','commit','-v7');
fprintf('Rebuilt lpips_vgg16_weights.mat from verified official checkpoints.\n');
end

function values = readFloats(fid, offset, count)
assert(fseek(fid,offset,'bof') == 0);
[values,n] = fread(fid,count,'*single');
assert(n == count, 'Unexpected checkpoint tensor length.');
end

function downloadChecked(url, destination, expectedBytes, expectedHash)
fprintf('Downloading %s\n',url);
websave(destination,url,weboptions('Timeout',600));
info = dir(destination);
assert(info.bytes == expectedBytes, 'Unexpected checkpoint file size.');
% Java is bundled with standard desktop MATLAB; stream to bound memory use.
digest = javaMethod('getInstance','java.security.MessageDigest','SHA-256');
fid = fopen(destination,'r');
assert(fid >= 0); closeFile = onCleanup(@() fclose(fid)); %#ok<NASGU>
while ~feof(fid)
    digest.update(fread(fid,1024*1024,'*int8'));
end
actualHash = lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
assert(strcmp(actualHash,expectedHash), 'Checkpoint SHA-256 mismatch.');
end
