function [subSampledWavelengthSampling, subSampledSPDs] = SubSampleSPDs(originalS, originalSPDs, targetS, lowPassSigma, showFig)
% [subSampledWavelengthSampling, subSampledSPDs] = subSampleSPDs(originalS, originalSPDs, newSamplingInterval, lowPassSigma, showFig)
%
% Method to subsample the SPDs by a given sampling interval (given in nanometers) after first
% low-passing them with a Gaussian kernel with sigma = lowPassSigma (given in nanometers).
% If the showFig flag is set to true a figure showing all
% the intermediate steps of this operation is displayed.
%
% 2/26/2015     npc     Wrote it.
% 3/10/2015     xd      Changed newSamplingInterval input to targetS
%                       This allows targetS to have a different range
%                       that is still contained within orginialS

newSamplingInterval = targetS(2);

% ensure that newSamplingInterval, lowPassSigma are integers
newSamplingInterval = round(newSamplingInterval);
lowPassSigma = round(lowPassSigma);

% interpolate to 1 nm resolution
originalWavelengthSampling = SToWls(originalS);
maxResWavelengthSampling = (originalWavelengthSampling(1):1:originalWavelengthSampling(end))';
newS = WlsToS(maxResWavelengthSampling);
maxResSPDs = SplineSpd(originalS, originalSPDs, newS);

% generate subsampling vector containing the indices of the samples to keep
% find start and end intervals for targetS
targetWavelengthSampling = SToWls(targetS);
startIndex = targetS(1) - originalS(1) + 1;
endIndex = targetWavelengthSampling(end) - originalS(1) + 1;

subSamplingVector = (startIndex:newSamplingInterval:endIndex);
subSampledWavelengthSampling = maxResWavelengthSampling(subSamplingVector);

% preallocate memory for the subsampled SPDs
channelsNum = size(originalSPDs, 2);
subSampledSPDs = zeros(numel(subSampledWavelengthSampling), channelsNum);
lowpassedSPDs = zeros(numel(maxResWavelengthSampling), channelsNum);

% generate the lowpass kernel
lowPassKernel = generateGaussianLowPassKernel(newSamplingInterval, lowPassSigma, maxResWavelengthSampling);

% zero pad lowpass kernel
FFTsize = 1024;
paddedLowPassKernel = zeroPad(lowPassKernel, FFTsize);

if (showFig)
    hFig = figure();
    set(hFig, 'Position', [200, 200, 1731, 1064]);
    clf;
end

for channelIndex = 1:channelsNum
    % zero pad SPD
    paddedSPD = zeroPad(squeeze(maxResSPDs(:, channelIndex)), FFTsize);

    % filter SPD with kernel
    FFTkernel = fft(paddedLowPassKernel);
    FFTspd = fft(paddedSPD);
    tmp = FFTspd .* FFTkernel;

    % back in original domain
    tmp = ifftshift(ifft(tmp));
    lowpassedSPDs(:, channelIndex) = extractSignalFromZeroPaddedSignal(tmp, numel(maxResWavelengthSampling));

    % subsample the lowpassed SPD
    subSampledSPDs(:, channelIndex) = lowpassedSPDs(subSamplingVector, channelIndex);
end

maxY = max([max(subSampledSPDs(:)), max(originalSPDs(:)), max(lowpassedSPDs(:))]);
originalSPDpower = sum(originalSPDs, 1);
subSampledSPDpower = sum(subSampledSPDs, 1);

if (showFig)
    for channelIndex = 1:channelsNum
        % plot results
        subplot(3, 7, [1, 2, 3, 4, 5, 6]+(channelIndex - 1)*7);
        hold on;
        % plot the lowpass kernel as a stem plot
        hStem = stem(maxResWavelengthSampling, maxY/2+lowPassKernel*maxY/3, 'Color', [0.5, 0.5, 0.90], 'LineWidth', 1, 'MarkerFaceColor', [0.7, 0.7, 0.9]);
        hStem.BaseValue = maxY / 2;
        % plot the subSampledSPD in red
        plot(subSampledWavelengthSampling, subSampledSPDs(:, channelIndex), 'ro-', 'MarkerFaceColor', [1.0, 0.7, 0.7], 'MarkerSize', 14);
        % plot the lowpass version of the original SPD in gray
        plot(maxResWavelengthSampling, lowpassedSPDs(:, channelIndex), 'k.-', 'MarkerFaceColor', [0.8, 0.8, 0.8], 'MarkerSize', 8);
        % plot the the original SPD in black
        plot(originalWavelengthSampling, originalSPDs(:, channelIndex), 'ks-', 'MarkerFaceColor', [0.1, 0.1, 0.1], 'MarkerSize', 6);
        hold off;
        set(gca, 'YLim', [0, maxY], 'XLim', [min(maxResWavelengthSampling), max(maxResWavelengthSampling)]);
        h_legend = legend('lowpass kernel', 'subsampled SPD', 'lowpassedSPD', 'originalSPD');
        box on;
        xlabel('wavelength (nm)');
        ylabel('energy');
        title(sprintf('power: %2.4f (original SPD) vs. %2.4f (subsampled SPD)', originalSPDpower(channelIndex), subSampledSPDpower(channelIndex)));
    end
    drawnow;
end % if (showFig)
end

% Method to zero pad a vector to desired size
function paddedF = zeroPad(F, padSize)
ix = floor(numel(F)/2);
paddedF = zeros(1, padSize);
paddedF(padSize/2+(-ix:ix)) = F;
end

% Method to extract a signal from a zero-padded version of it
function F = extractSignalFromZeroPaddedSignal(paddedF, desiredSize)
ix = floor(desiredSize/2);
xo = numel(paddedF) / 2 - 1;
F = paddedF(xo+(-ix:-ix + desiredSize - 1));
end

% Method to generate a Gaussian LowPass kernel
function gaussF = generateGaussianLowPassKernel(newSamplingInterval, sigma, samplingAxis)

samplingAxis = (0:(numel(samplingAxis) - 1)) - (numel(samplingAxis) / 2) + 0.5;

if (newSamplingInterval <= 1)
    gaussF = zeros(size(samplingAxis));
    gaussF(samplingAxis == 0) = 1;
else
    gaussF = exp(-0.5*(samplingAxis / sigma).^2);
    gaussF = gaussF / sum(gaussF);
end
end