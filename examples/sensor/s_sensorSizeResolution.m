%% Count pixels for a particular sensor (quarterinch, halfinch)
%
% Count pixel density for different sensor sizes and different pixel sizes.
%
% See also: s_sensorPixelCounting
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
ieInit

%% Here are all the known sensor formats

% Either the pixel count or the size in meters is printed out
sensorFormats

%% Calculate the pixels for a half inch
sSize = sensorFormats('half inch');    % Returns sensor size in meters
pSize = (0.8:0.2:3)*1e-6;             % Pixel size in meters

r = zeros(size(pSize));
c = zeros(size(pSize));
m = zeros(size(pSize));

for ii=1:length(pSize)
    r(ii) =  sSize(1) / pSize(ii);
    c(ii) =  sSize(2) / pSize(ii);
    m(ii) = ieN2MegaPixel(r(ii)*c(ii));
end

%% Plot for half inch
vcNewGraphWin;
plot(pSize*1e6,m,'-o')
grid on
xlabel('Pixel size (um)')
ylabel('Megapixel')

%% Quarter inch
sSize = sensorFormats('quarter inch');    % Returns sensor size in meters
pSize = (0.8:0.2:3)*1e-6;             % Pixel size in meters

r = zeros(size(pSize));
c = zeros(size(pSize));
m = zeros(size(pSize));

for ii=1:length(pSize)
    r(ii) =  sSize(1) / pSize(ii);
    c(ii) =  sSize(2) / pSize(ii);
    m(ii) = ieN2MegaPixel(r(ii)*c(ii));
end

%% Add the quarter inch curve
hold on
plot(pSize*1e6,m,'-o')
legend({'Half inch','Quarter inch'})

%%
