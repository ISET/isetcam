function [ls, xSec] = westheimerLSF(xSec)
%Westheimer line spread function
%
%  [ls, xSec] = westheimerLSF(xSec)
%
% Spatial position is x in secs of arc of visual angle.
%
% Westheimer calculated that the linespread function of the human
% eye, specified in terms of minutes of arc and using a 3mm
% pupil, should be approximated using the following formula
%
% LineSpread = 0.47*exp(-3.3 *(x.^2)) + 0.53*exp(-0.93*abs(x));
%
% Example:
%  vcNewGraphWin; 
%  xSec = -300:300; % Open window and set spatial samples
%  plot(xSec,westheimerLSF(xSec)); grid on % Plot the line spread
%  xlabel('Position (arc sec)'); ylabel('Relative intensity');
%
%  xSec = -300:300; westheimerOTF = abs(fft(westheimerLSF(xSec)));
%  (One cycle spans 10 min of arc, so freq=1 is 6 cyc/deg)
%  freq = [0:11]*6;
%  vcNewGraphWin; semilogy(freq,westheimerOTF([1:12])); grid on;
%  xlabel('Freq (cpd)'); ylabel('Relative contrast');
%  set(gca,'ylim',[-.1 1.1])
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('xSec'), xSec = -300:1:300;	 end

xMin = xSec/60;
ls = 0.47*exp(-3.3 *(xMin.^2)) + 0.53*exp(-0.93*abs(xMin));
ls = ls / sum(ls);

end