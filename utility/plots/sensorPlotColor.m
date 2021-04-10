function sensorPlotColor(sensor,type)
% Plot sensor cross-correlations 
%
% Synopsis
%  sensorColorPlot(sa,[type=RB'])
%
% Description
%  This routine analyzes the scene color properties, usually color
%  balancing. The routine produces a graph that includes the
%  cross-corrrelation and indicates the expected distribution assuming
%  various different color temperatures of the ambient illumination.
%
% Example:
%   sensor = vcGetObject('ISA');
%   sensorPlotColor(sensor,'rg')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sa'),   sensor = ieGetObject('sensor'); end
if ieNotDefined('type'), type = 'rg'; end

labels = {'Red sensor','Green sensor','Blue sensor'};

% Demosiac the (R,B) values. 
wave       = sensorGet(sensor,'wave');
spectralQE = sensorGet(sensor,'spectral QE');

% We need a default, target display to do the demosaic'ing
ip = ipCreate;
ip = ipSet(ip,'input',sensorGet(sensor,'volts'));
demosaicedImage = Demosaic(ip,sensor); 

figNum =  ieNewGraphWin;

switch lower(type)
    case 'rg'
        dList = [1,2];
    case 'rb'
        dList = [1,3];
    otherwise
        error('Unknown plot type.');
end

% Make the escatter plot after demosaicing the sensor data
d1 = demosaicedImage(:,:,dList(1));
d2 = demosaicedImage(:,:,dList(2));
d = sqrt(d1.^2 + d2.^2);
d = max(d(:));

% We should probably check to see that d1,d2 aren't too big.  If they are
% randomly sample.
plot(d1(:),d2(:),'.'); axis equal
xlabel(labels{dList(1)}); ylabel(labels{dList(2)});

% Estimate the slope for white surfaces at these color temperatures 
cTemp = [2500,3000,3500,4000,4500,5500,6500,8000,10500];

for ii=1:length(cTemp)
    spec = Energy2Quanta(wave,blackbody(wave, cTemp(ii) ));
    rgb = spectralQE'*spec;
    rgb = 0.9*d*(rgb/sqrt(sum(rgb(dList).^2)));
    txt = sprintf('%.1fK',round(cTemp(ii)/100)/10);
    hold on; plot(rgb(dList(1)),rgb(dList(2)),'k.');
    text(rgb(dList(1))+0.02,rgb(dList(2)),txt)
end
hold off

set(gca,'xlim',[0 d], 'ylim', [0,d])
title('Sensor Color Balance');
grid on; 

uData.name = 'sensorColorPlot';
uData.d1 = d1;
uData.d2 = d2;
uData.rgb = rgb;
set(gcf,'userdata',uData);

end