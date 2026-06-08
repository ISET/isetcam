%% s_scielabFilters
% Illustrate the properties of S-CIELAB filters
%
% See scPrepareFilters for more notes on the filters
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit;

%% The filters are prepared with respect to real physical units.
%
scP = scParams;
% For experiments
scP.sampPerDeg    = 101;  % Odd is easier for centering
scP.filterSize    = 101;
[filters,~,scP] = scPrepareFilters(scP);

% Channel names
cName = {'Lum','R/G','B/Y'};

%% Here are the returned filter point spreads, plotted as meshes
%
x = (1:scP.filterSize)/scP.sampPerDeg;
y = (1:scP.filterSize)/scP.sampPerDeg;
x = x - mean(x(:));
y = y - mean(y(:));

zMax = max(filters{1}(:))*1.2;

vcNewGraphWin; mesh(x,y,filters{1}); set(gca,'zlim',[0 zMax])
xlabel('Pos (deg)');ylabel('Pos (deg)');
vcNewGraphWin; mesh(x,y,filters{2});set(gca,'zlim',[0 zMax])
xlabel('Pos (deg)');ylabel('Pos (deg)');
vcNewGraphWin; mesh(x,y,filters{3});set(gca,'zlim',[0 zMax])
xlabel('Pos (deg)');ylabel('Pos (deg)');

%% The filter point spreads as an image

cMap = gray(256)*0.7 + repmat([.3 .3 .3],256,1);
fSize = 18;

vcNewGraphWin; imagesc(x,y,filters{1}); axis image; grid on
colormap(cMap); % colorbar
set(gca,'xtick',[-0.2:.2:.2],'ytick',[-0.2:.2:.2])
set(gca,'fontSize',fSize); axis off
title(cName{1});xlabel('deg')

vcNewGraphWin; imagesc(x,y,filters{2}); axis image; grid on
colormap(cMap); % colorbar
set(gca,'xtick',[-0.2:.2:.2],'ytick',[-0.2:.2:.2])
set(gca,'fontSize',fSize); axis off
title(cName{2});

vcNewGraphWin; imagesc(x,y,filters{3}); axis image; grid on
colormap(cMap); % colorbar
set(gca,'xtick',[-0.2:.2:.2],'ytick',[-0.2:.2:.2])
set(gca,'fontSize',fSize); axis off
title(cName{3});xlabel('Deg')

%% The filter MTFs.  These are invariant with support/sampPerDeg
%
N = 512; % Try different sampe rates: 64, 128, 256, 512
scP.sampPerDeg    = N;
scP.filterSize    = N;
[filters,tmp,scParams] = scPrepareFilters(scP);
imgDeg  = scP.filterSize/scP.sampPerDeg;         % samp/(samp/deg) = deg
freq    = (1:scP.filterSize) - scP.filterSize/2; % Center around 0
freqDeg = freq/imgDeg;                           % First cycle is cycles/imgDeg.

tFilter = cell(1,3);
for ii=1:3
    ps = fftshift(filters{ii});   % The center should be at ps(1,1)
    tFilter{ii} = fftshift(abs(fft2(ps)));
    vcNewGraphWin; imagesc(freqDeg,freqDeg,tFilter{ii}); axis image;
    set(gca,'xlim',[-20 20],'ylim',[-20 20]); truesize
    grid on; colormap(gray(256)); title(cName{ii});
end

%% Changing the Gaussian filter parameters

% We can compare two different sets of Gaussian parameters in the
% distribution.  Three are currently defined.  We will probably add new
% ones for further experiments.
scP.sampPerDeg    = 350;
scP.filterSize    = 200;

% Choose one of these.  Then run the code below.  You will see the MTF
% change in response.
scP.filterversion = 'distribution';   % From the Matlab 1996 distribution
% scP.filterversion = 'original';       % From the table in the paper
% scP.filterversion = 'hires';          % Hi-res version made in 2007

[filters,support,scParams] = scPrepareFilters(scParams);
imgDeg = scP.filterSize/scP.sampPerDeg;       % samp/(samp/deg) = deg
freq = (1:scP.filterSize) - scP.filterSize/2; % Center around 0
freqDeg = freq/imgDeg;                                  % First cycle is cycles/imgDeg.

tFilters = cell(1,3);
vcNewGraphWin;
for ii=1:3
    ps = fftshift(filters{ii});                  % The center should be at ps(1,1)
    tFilters{ii} = fftshift(abs(fft2(ps)));      % plot(support,ps(1,:))
    subplot(1,3,ii),
    imagesc(freqDeg,freqDeg,tFilters{ii});       % spec = fftshift(tFilters{3});
    axis image;                                  % figure(3); loglog(freqDeg,fftshift(spec(:,1)));
    set(gca,'xlim',[-20 20],'ylim',[-20 20])     % grid on
    grid on;
    set(gcf,'Name',sprintf('FFT %s',scP.filterversion));
end

vcNewGraphWin([],'wide'); lst = {'lum','r/g','b/y'};
for ii=1:3
    subplot(1,3,ii), imagesc(support,support,filters{ii}); axis image;
    set(gca,'xlim',[-.2 .2],'ylim',[-.2 .2])
    grid on
    title(sprintf('PS %s',lst{ii}));
    xlabel('deg')
    colorbar
end


%% END

