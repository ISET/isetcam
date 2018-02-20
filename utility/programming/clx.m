% Script to clear many things:
% clear mex
% clear all
% close all
% close hidden
% clear fun
% ARW 061903

clear mex
clear all
% Important to close windows prior to clearing variables
% (sometimes the closerequestfunction on a window
% is set to something funny -- want to force it
% to close:)
figs = get(0,'Children');
set(figs,'CloseRequestFcn','closereq');
close all
if exist('hidden', 'var')
    close hidden
end

clear all

clear fun

return;
