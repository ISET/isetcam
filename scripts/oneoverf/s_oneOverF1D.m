% s_synthesizeOneOverF
%
% Testing two ideas:
%
%   (1) The spectrum of (some) images depends on the crop in the spatial
%       domain, (smaller crops => more power in the high frequencies)
%
%   (2) this pattern can be produced by a generative process in which an
%       image is built as the sum of many components at various scales
%       (e.g., Wavelets or Gaussians)
%
% To make life easier, we do the simulation in 1D, and for bookkeeping, we
% will give the signal units of time (seconds).
%
% See also 
%   s_CroppingSpectrum, s_oneFsimulate, sceneDeadLeaves
%
% Jon and Brian: Thinking about 1/f.

%%
% *************************************
% ******* Synthesis *******************
% *************************************


% Time
%   (1) Time goes from dt:1. (If it went from 0 to 1, we wind up with 
%       slightly more than an integer number of cycles when we generate
%       harmonics.
%   (2) The number of time points is a power of 2 because at the end of the
%       script, we will crop the time series into various fragments of
%       length 2^(-n) * signal length, n = [0:5]
sz    = 2^12;
dt    = 1/sz;
t     = dt:dt:1; % 1 second of signal
crops = 2.^(-(2:7));

% Signal
% To get a better understanding of the generative process and its effects
% on the image spectra, we construct 3 signals corresponding to the three
% parts of the wavelet: harmonic only, gaussian only, or the product.
H  = zeros(1,sz); % harmonic
G  = zeros(1,sz); % gaussian
W  = zeros(1,sz); % wavelet
O  = zeros(1,sz); % occluder

% Frequency
% For the carriers] frequncies, we consider what the shortest time series
% will be after cropping the signal at the end of the script. This is len =
% sz * min(crops). The number of frequency components in this cropped time
% series will be len / 2 + 1 (dc to nyquist limit).
fmax    = sz / 2;
carrier = linspace(0, fmax, sz * min(crops)/2 + 1);
% carrier = 0:fmax/2;


% Choose the bandwidth for Gaussians and Wavelets. We assume one cycle per
% sigma (so within +/-2 sd, there are 4 bumps)
sigma   = 1./carrier;


% We will plot the signal as it is generated, updating at each scale
figHandle = ieNewGraphWin;

% loop across scales, adding in local elements
for ii = 1:length(carrier)
    
    % How many elements to add in at each scale?
    %   should the number be proportional to the carrier frequency?
    %       for n = 1:1+round(carrier(ii));
    %   or should we just add one element per scale for simplicity?
    %       for n = 1
    %   or should we add a constant number of elements at all scales?
    %       for n = 1:round(max(carrier));
    for n = 1:1+round(carrier(ii))
        
        % Create a gaussian with a randomized center position. Note that we
        % randomize over a distance greater than signal ([-.5 1.5]) so that
        % the center position can be outside the signal. Otherwise we get
        % annoying edge effects.
        pos = (rand*2)-.5;
        
        % As a sanity check, we might want to NOT randomize the position.
        % If we do not randomize the gaussian position, the spectrum of the
        % harmoic signal should be exactly uniform.
        % pos = 0;                      
        g = exp(-(t - pos).^2/(2*sigma(ii)^2));
        
        % create an occlude of random size and intensity
        o = g > .5*max(g); 
                
        % harmonic with phase at the peak of the gaussian
        if carrier(ii) == 0, h = ones(size(t))/2;   % DC signal
        else h = cos(carrier(ii)*2*pi*(t+pos)); end 
        
        % add in the local elements
        H = H + h;    % harmonic
        G = G + g;    % gaussian
        W = W + h.*g; % wavelet
        O(o) = rand;  % for the occluder, we replace (we don't add)
    end
    
    
    % watch it go for fun, or comment this out to speed up
    ieFigure(figHandle)
    subplot(4,1,1); plot(t, H, carrier(ii)/sz, 0, 'rx'); title('Harmonics', 'FontSize', 16)
    subplot(4,1,2); plot(t, G); title('Gaussians', 'FontSize', 16)
    subplot(4,1,3); plot(t, W); title('Wavelets', 'FontSize', 16)
    subplot(4,1,4); plot(t, O); title('Occluders', 'FontSize', 16)
    drawnow
    
    % to visualize the local elements being added ...
    % ieFigure; plot(t, h, t, g, t, g.*h);
end


%%
% *************************************
% ******* Analysis ********************
% *************************************
%% Calculate spectrum of truncated images


ieNewGraphWin;

% different markers for the different lines
markers = '+o*.xsd^v><ph';
nplots = 4;
% loop over H, G, W
for imType = 1:nplots
    subplot(2,nplots,imType)
    set(gca, 'ColorOrder', jet(length(crops))); hold all
    subplot(2,nplots,imType+nplots)
    set(gca, 'ColorOrder', jet(length(crops))); hold all
    
    switch imType
        case 1, S0 = H; title('Harmonics', 'FontSize', 16)
        case 2, S0 = G; title('Gaussians', 'FontSize', 16)
        case 3, S0 = W; title('Wavelets',  'FontSize', 16)
        case 4, S0 = O; title('Occluders', 'FontSize', 16)
    end
    
    
    % loop over the crop sizes, from the full signal to a small fraction
    for ii = 1:length(crops)
        
        n = 1/crops(ii);
        spd = zeros(n, sz/n);
        
        % for a give crop size, we calculate the spectrum a number of
        % times. if we crop the signal to 1/16 its size, then we crop 16
        % times into non-overlapping regions, in case any one region is not
        % representative of the whole image. we then calculate the spectrum
        % for each cropped region and average the spectrum.
        for jj = 1:n
            % crop
            inds = (1:sz/n) + (jj-1)*sz/n;
            s = S0(inds);
            
            % we scale the signal intensity by the inverse of the length in
            % order to preserve the DC
            s = s / length(s);
            
            % spectrum,
            tmp = abs(fft2(s));
            spd(jj,:) = tmp;
        end
        spd = fftshift(mean(spd,1));
        
        % frequencies, expressed in cycles per s
        f_cps = linspace(-.5, .5, length(s)+1)*sz; f_cps = f_cps(1:end-1);
        
        % find just those frequncies that were used to generate the signal.
        % otherwise we  get a lot of zeros in the spd.
        [c ia ib] = intersect(carrier, f_cps);
        
        % plot it
        subplot(2,nplots,imType)
        plot(f_cps(ib), spd(ib), sprintf('%s-', markers(ii)));
        
        subplot(2,nplots,imType+nplots)
        % frequencies, expressed in cycles per s
        f_cpi = f_cps * length(s) * dt ;        
        %plot( spd(length(spd)/2:end), sprintf('%s-', markers(ii)));
        plot(f_cpi(ib), spd(ib), sprintf('%s-', markers(ii)));
    end
    
    
    
    subplot(2,nplots,imType)
    set(gca,'YScale', 'log',  'XScale', 'log');
    
    % put the signal duration in the legend
    % if imType == 1, legend(cellstr(num2str(crops'))'); end
    
    xlabel('cycles / second', 'FontSize', 12)
    ylabel('amplitude')
    
    subplot(2,nplots,imType+nplots)
    set(gca,'YScale', 'log',  'XScale', 'log');
    
    % put the signal duration in the legend
    % if imType == 1, legend(cellstr(num2str(crops'))'); end
    
    xlabel('cycles / image', 'FontSize', 12)
    ylabel('amplitude')
    
end





%% convolve with gabors
ieFigure
for ii = 2:length(carrier)
    f = carrier(ii);
    s = sigma(ii);
    tt = dt:dt:4*s;
    kernelS =  exp(-(tt-2*s).^2/(2*s^2)).*sin(f*tt*2*pi);  
    kernelC =  exp(-(tt-2*s).^2/(2*s^2)).*cos(f*tt*2*pi);  
    subbandS = conv(O, kernelS, 'same')/length(kernelS);
    subbandC = conv(O, kernelC, 'same')/length(kernelS);
    subplot(4,4,ii-1)
    hist(sqrt(subbandS.^2 + subbandC.^2), linspace(0,.2,101))
    %hist(sqrt(subbandS.^2 + subbandC.^2), linspace(0,2,101))
    title(sprintf('Center Frequency: %03.0f Hz', carrier(ii)))    
    xlim([0 0.2])
end
