% v_ISET
%
% This has now been replaced by ieRunValidateAll.m.  We keep it here for
% the old-timers who are used to seeing this one instead.
%
% Run a subset of the tutorial and validation scripts to check a wide
% variety of functions. We used to run these whenever there are significant
% changes to ISET and prior to checking in the new code.  It has not been
% replaced by the ieRunValidateAll function, which runs all of the
% validation scripts automatically.
%
% We plan to add further assert() checks and functionality to the v_*
% scripts.
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Initialize
ieInit

setpref('ISET', 'benchmarkstart', cputime); % if I just put it in a variable it gets cleared:(
tic

%% Scene tests
h = msgbox('Scene','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_scene

%% Optics tests
h = msgbox('Optics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_oi
v_diffuser
v_opticsSI
v_opticsWVF

%% Sensor tests
h = msgbox('Sensor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_sensor

%% Pixel tests
h = msgbox('Pixel ','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_pixel

%% Human visual system tests
h = msgbox('Human PSF','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_human

%% Image processing 
h = msgbox('Image Processor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_imageProcessor

%% Metrics tests
h = msgbox('Metrics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_metrics

%% Display window
h = msgbox('Display','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
t_displayIntroduction;

%% End

afterTime = cputime;
beforeTime = getpref('ISET', 'benchmarkstart', 0);
strcat("v_ISET ran in: ", string(afterTime - beforeTime), " seconds of CPU time.")
toc
