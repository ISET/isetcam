% s_ovtColorfilters
%
% There is a large and a small pixel with different color filters.
% Notice that these color filters extend beyond the usual 400-700.
% For our simulations, we will mostly be ignoring those wavelengths.
%
% These are from the paper
%
%{

Solhusvik, Johannes, Trygve Willassen, Sindre Mikkelsen, Mathias
Wilhelmsen, Sohei Manabe, Duli Mao, Zhaoyu He, Keiji Mabuchi, and
Takuma Hasegawa. n.d. “A 1280x960 2.8μm HDR CIS with DCG and
Split-Pixel Combined.” Accessed June 26, 2024.
https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.    
​
%}

%% Interpolation
wave = 300:1:1100;

%% Large pixel

load('LargeBlue.mat','LargeBlue');
% ieNewGraphWin; plot(LargeBlue(:,1),LargeBlue(:,2));

lblue = interp1(LargeBlue(:,1),LargeBlue(:,2),wave,"spline");
tmp = sgolayfilt(lblue, 6, 31);
lblue = max(tmp,0);
% ieNewGraphWin; plot(wave,lblue);
% ieNewGraphWin; plot(wave,tmp,'--',wave,lblue,'o');

load('LargeGreen.mat','LargeGreen');
lgreen = interp1(LargeGreen(:,1),LargeGreen(:,2),wave,"spline");
lgreen = max(lgreen,0);
% ieNewGraphWin; plot(wave,lgreen);

load('LargeRed.mat','LargeRed');
lred = interp1(LargeRed(:,1),LargeRed(:,2),wave,"spline");
lred = max(lred,0);
% ieNewGraphWin; plot(wave,lred);

d.wavelength = wave;
d.data = [lred(:),lgreen(:),lblue(:)];
d.filterNames = {'r','g','b'};
d.comment = 'Grabit from Solhusvik paper from Omnvision.  A 1280x960 2.8 um ...';

fname = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-large.mat');
ieSaveColorFilter(d,fname);

%%
fname = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-large.mat');
cf = ieReadColorFilter(wave,fname);
ieNewGraphWin; plot(wave,cf); set(gca,'ylim',[0 1]); grid on

%% Small

load('SmallBlue.mat','SmallBlue');
sblue = interp1(SmallBlue(:,1),SmallBlue(:,2),wave,"spline");
sblue = max(sblue,0);
% ieNewGraphWin; plot(wave,sblue);

load('SmallGreen.mat','SmallGreen');
sgreen = interp1(SmallGreen(:,1),SmallGreen(:,2),wave,"spline");
sgreen = max(sgreen,0);
% ieNewGraphWin; plot(wave,sgreen);

load('SmallRed.mat','SmallRed');
sred = interp1(SmallRed(:,1),SmallRed(:,2),wave,"spline");
sred = max(sred,0);
% ieNewGraphWin; plot(wave,sred);

d.wavelength = wave;
d.data = [sred(:),sgreen(:),sblue(:)];
d.filterNames = {'r','g','b'};
d.comment = 'Grabit from Solhusvik paper from Omnvision.  A 1280x960 2.8 um ...';
fname = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-small.mat');
ieSaveColorFilter(d,fname);

%%
fname = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-small.mat');
cf = ieReadColorFilter(wave,fname);
ieNewGraphWin; plot(wave,cf);

%% End
