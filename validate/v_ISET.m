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
setpref('ISET', 'tStart', tic);

%% Scene tests
h = msgbox('Scene','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvsceneStart', tic);
v_scene
setpref('ISET', 'tvsceneTime', toc(getpref('ISET', 'tvsceneStart', 0)));
%% Optics tests
h = msgbox('Optics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));

setpref('ISET', 'tvopticsStart', tic);
v_oi
v_diffuser
v_opticsSI
v_opticsWVF
setpref('ISET', 'tvopticsTime', toc(getpref('ISET', 'tvopticsStart')));

%% Sensor tests
h = msgbox('Sensor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvsensorStart', tic);
v_sensor
setpref('ISET', 'tvsensorTime', toc(getpref('ISET', 'tvsensorStart')));

%% Pixel tests
h = msgbox('Pixel ','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvpixelStart', tic);
v_pixel
setpref('ISET', 'tvpixelTime', toc(getpref('ISET', 'tvpixelStart')));

%% Human visual system tests
h = msgbox('Human PSF','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvhumanStart', tic);
v_human
setpref('ISET', 'tvhumanTime', toc(getpref('ISET', 'tvhumanStart')));

%% Image processing 
h = msgbox('Image Processor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvipStart', tic);
v_imageProcessor
setpref('ISET', 'tvipTime', toc(getpref('ISET', 'tvipStart')));

%% Metrics tests
h = msgbox('Metrics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvmetricsStart', tic);
v_metrics
setpref('ISET', 'tvmetricsTime', toc(getpref('ISET', 'tvmetricsStart')));

%% Computational Imaging tests
h = msgbox('CI','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvciStart', tic);
v_cp  
setpref('ISET', 'tvciTime', toc(getpref('ISET', 'tvciStart')));

%% Display window
h = msgbox('Display','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
setpref('ISET', 'tvdisplayStart', tic);
t_displayIntroduction;
setpref('ISET', 'tvdisplayTime', toc(getpref('ISET', 'tvdisplayStart')));

%% End
tTotal = toc(getpref('ISET','tStart'));
afterTime = cputime;
beforeTime = getpref('ISET', 'benchmarkstart', 0);
glData = opengl('data');
disp(strcat("v_ISET ran  on: ", glData.Vendor, " ", glData.Renderer, "with driver version: ", glData.Version)); 
disp(strcat("v_ISET ran  in: ", string(afterTime - beforeTime), " seconds of CPU time."));
disp(strcat("v_ISET ran  in: ", string(tTotal), " total seconds."));
fprintf("Scenes  ran in: %5.1f seconds.\n", getpref('ISET','tvsceneTime'));
fprintf("Optics  ran in: %5.1f seconds.\n", getpref('ISET','tvopticsTime'));
fprintf("Sensor  ran in: %5.1f seconds.\n", getpref('ISET','tvsensorTime'));
fprintf("IP      ran in: %5.1f seconds.\n", getpref('ISET','tvipTime'));
fprintf("Display ran in: %5.1f seconds.\n", getpref('ISET','tvdisplayTime'));
fprintf("Metrics ran in: %5.1f seconds.\n", getpref('ISET','tvmetricsTime'));
fprintf("CI      ran in: %5.1f seconds.\n", getpref('ISET','tvciTime'));
fprintf("Human   ran in: %5.1f seconds.\n", getpref('ISET','tvhumanTime'));
