function [snr,luxsec] = sensorSNRluxsec(ISA)
%Plot or calculate sensor SNR (dB) as a function of  illuminance (lux-sec)
%
%      [snr,luxsec] = sensorSNRluxsec(ISA)
%
%  If no arguments are returned, this routine produces a graphical output
%  of the SNR for each of the different color types.  The snr and luxsec
%  data are stored in get(gcf,'userdata').  If there are output arguments,
%  no graph is produced.
%
%  This routine calculates SNR assuming a spatially uniform, spectrally D65
%  scene and optical image with no cos4th fall-off.  This uniform scene is
%  processed with the current sensor parameters at a variety of integration
%  times.  The resulting SNR as a function produces a plot of SNR vs.
%  lux-sec.
%
%  The SNR formula is described in sensorSNR.  This routine uses the
%  relationship between pixel volts and illumination, calculated by
%  pixelVperLuxSec, to represent the SNR in terms of lux-sec.
%
%  Unlike sensorSNR, this routine does not return the limits imposed by the
%  various types of noise terms.
%
%  See also:  sensorSNR, pixelVperLuxSec
%
% Example:
%    sensorSNRluxsec(vcGetObject('sensor'));
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('ISA'), ISA = vcGetObject('ISA'); end

% Compute the snr as a function of volts.
[snr,volts] = sensorSNR(ISA);

% Compute the relationship between volts and lux-sec for a D65 light
% source.
voltsPerLuxSec = pixelVperLuxSec(ISA);
nColors = sensorGet(ISA,'ncolors');

for ii=1:nColors, luxsec(:,ii) = volts(:) / voltsPerLuxSec(ii); end

if nargout == 0
    % Make the lux-sec version of the plot in plotSensorSNR
    
    vcNewGraphWin;
    letters = sensorGet(ISA,'filterColorLetters');
    
    for ii=1:length(letters)
        if strcmp(letters(ii),'w'), letters(ii) = 'k'; end
        p = semilogx(luxsec(:,ii),snr,[letters(ii),'-']);
        set(p,'linewidth',2);
        hold on
    end
    hold off
    
    % Compute some quantities for the user data
    % Saturation level
    LuxSecAtSaturation = pixelGet(sensorGet(ISA,'pixel'),'voltageswing') ./ voltsPerLuxSec;
    
    % Minimum photometric exposure for 30dB noise level
    thirtyDBLevel = interp1(snr,luxsec,30);
    
    xlabel('lux-sec'); ylabel('SNR (db)');grid on
    title('Sensor SNR vs. Lux-sec (EE light)');
    leg = cell(1,nColors);
    for ii=1:nColors
        leg{ii} = sprintf('Sat %.2f (lux-sec)',LuxSecAtSaturation(ii));
    end
    legend(leg,'Location','northwest');
    
    udata.luxsec = luxsec;
    udata.snr = snr;
    udata.mpe30 = thirtyDBLevel;
    udata.voltsPerLuxSec = voltsPerLuxSec;
    set(gcf,'userdata',udata);
end

disp('Additional analyses attached to figure - Use get(gcf,''userdata'')')

return;
