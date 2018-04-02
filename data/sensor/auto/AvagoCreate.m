%% Avago sensor data
%
% This is really for the AR0132AT
%

%% First, write out the color channels
chdir(fullfile(isetRootPath,'data','sensor','CMOS'));
wave = 400:1:700;

load('Data001.mat');   %W
load('Data002.mat');   %B
load('Data003.mat');   %G
load('Data004.mat');   %R

W = interp1(Data001(:,1),Data001(:,2),wave,'linear','extrap');
vcNewGraphWin; plot(wave,W); grid on
R = interp1(Data004(:,1),Data004(:,2),wave,'linear','extrap');
G = interp1(Data003(:,1),Data003(:,2),wave,'linear','extrap');
B = interp1(Data002(:,1),Data002(:,2),wave,'linear','extrap');

vcNewGraphWin;
avago = [R(:) G(:) B(:) W(:)];
avago = avago/max(avago(:));

plot(wave,avago);

cf.wavelength = wave;
cf.data = avago;
cf.filterNames = {'R','G','B','W'};
cf.comment = 'Grabit from avago image on web.  See 2017 Vehicle folder';
ieSaveColorFilter(cf,fullfile(isetRootPath,'data','sensor','CMOS','Avago.mat'));


%%  Check that we can read it and plot it

[data,filterNames,fileData] = ieReadColorFilter(wave,'Avago.mat');
% plot(wave,data)
filterNames

%%
