function [snr,luxsec,SNRshot,SNRread,antiluxsec] = pixelSNRluxsec(sensor)
%Graph or calculate sensor SNR (dB) as a function of  illuminance (lux-sec)
%
%     [snr,luxsec,SNRshot, SNRread]  = pixelSNRluxsec(sensor)
%
% If there are no output arguments, this routine produces a graph of pixel
% SNR as a function of lux-sec incident at the pixel.  The legend indicates
% the saturation level of each pixel in lux-sec.  The color of the curves
% correspond to the color of the pixel (roughly).
%
% If there are output arguments, the calculated values, but no graph, are
% returned.
%
% This routine uses pixelSNR.  It differs only by calculating the
% illuminance level (lux-sec) required to produce the specific voltage.
% The key routine for calculating that relationship is pixelVperLuxSec (see
% below).  The spectral power distribution of the illuminant for the
% lux-sec calculation is assumed to be Equal Energy.
%
% See also: sensorSNR, pixelSNR, pixelVperLuxSec
%
% Example:
%    pixelSNRluxsec(vcGetObject('sensor'));
%    [snr,luxsec] = pixelSNRluxsec(vcGetObject('sensor'));
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sensor'), sensor = vcGetObject('ISA'); end
if isempty(sensor)
    errordlg('No image sensor array sent in or defined.');
    return;
end

% Compute the snr as a function of volts.
[snr,volts,SNRshot,SNRread] = pixelSNR(sensor);

% Compute the relationship between volts and lux-sec for a uniform light
% source.
[voltsPerLuxSec,~,~,voltsPerAntiLuxSec] = ...
    pixelVperLuxSec(sensor);

% The anti-luxseconds is a strange little construct from MP that measures
% something about the non-visible intensity, say IR, components of the
% light.
nColors = sensorGet(sensor,'ncolors');
luxsec = zeros(length(volts),nColors);
antiluxsec = zeros(length(volts),nColors);
for ii=1:nColors
    luxsec(:,ii) = volts(:) / voltsPerLuxSec(ii);
    antiluxsec(:,ii) = volts(:) / voltsPerAntiLuxSec(ii);
end
LuxSecAtSaturation = pixelGet(sensorGet(sensor,'pixel'),'voltageswing') ./ voltsPerLuxSec;

% If the user didn't ask for any data back, produce this plot and put
% the data in the userdata section of the plot.
if nargout == 0
    
    % Make the lux-sec version of the plot
    vcNewGraphWin;
    % filterNames = sensorGet(sensor,'filterNames');
    
    % Used to be in separate panels.  Let's put them all in one panel and
    % not put in the additional lines.
    letters = sensorGet(sensor,'filterColorLetters');
    for ii=1:nColors
        if strcmp(letters(ii),'w'), letters(ii) = 'k'; end
        p = semilogx(luxsec(:,ii),snr,[letters(ii),'-']);
        set(p,'linewidth',2);
        hold on
    end
    
    % We could put this one in just for the 1st pixel, for example.
    %     [v,ii] = min(luxsec(1,:));
    %     p = semilogx(luxsec(:,ii),SNRshot,'k--',luxsec(:,ii),SNRread,'k:');
    %     set(p,'linewidth',1);
    %     legend('Total','Shot noise','Read noise');
    
    title('Pixel SNR as a function of lux-seconds (EE light)')
    xlabel('lux-sec'); ylabel('SNR (db)');
    grid on, hold off
    
    % Create a legend showing saturation level (lux-sec)
    leg = cell(1,nColors);
    for ii=1:nColors
        leg{ii} = sprintf('Sat %.2f (lux-sec)',LuxSecAtSaturation(ii));
    end
    %     leg{nColors+1} = 'shot noise';
    %     leg{nColors+2} = 'read noise';
    legend(leg,'Location','northwest');
    
    udata.luxsec = luxsec;
    udata.snr = snr;
    set(gcf,'userdata',udata);
end

return;

