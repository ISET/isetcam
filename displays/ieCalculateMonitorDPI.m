function [dpi, dotPitch] = ieCalculateMonitorDPI(monitorSizeX, monitorSizeY, numPixelsX, numPixelsY);
% Compute the monitor DPI based on its dimensions in cm and dot resolution.
%
% function dpi=ieCalculateMonitorDPI(monitorSizeX, monitorSizeY,
% numPixelsX, numPixelsY);
% Inputs:
%           monitorSizeX, monitorSizeY: in cm
%           numPixelsX, numPixelsY: in number of samples
% Outputs:
%           dpi : a vector containing the dpi on x and y directions.

fPixelSizeXInMm = monitorSizeX * 10 / numPixelsX;
dpiX = iePixelSizeInMm2PixelResolutionInPPI(fPixelSizeXInMm);
fPixelSizeYInMm = monitorSizeY * 10 / numPixelsY;
dpiY = iePixelSizeInMm2PixelResolutionInPPI(fPixelSizeYInMm);
dotPitch = [fPixelSizeXInMm, fPixelSizeYInMm];
dpi = [dpiX, dpiY];
return;
