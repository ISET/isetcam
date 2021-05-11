%% These illuminant data from the Gretag lightbox
%
% Illuminant data collected at different times (years).
%
% I moved them into this common sub-directory of lights and made this
% script to be able to compare them.  I think I caught all the software
% references to the files and updated them.  The files used to be named
% Horizon_Gretag, CWF_Gretag and such which meant they did not group in the
% lights directory.  Now their common origin and dates are clearer.
%
% Scripts that manage data are starting to get renamed to s_data<*>.
% BW

%%
[illA1, wave] = ieReadSpectra('illA-20180220');
[illA2] = ieReadSpectra('illA-20201023', wave);
illA1 = ieScale(illA1, 1);
illA2 = ieScale(illA2, 1);
plotRadiance(wave, [illA1(:), illA2(:)]);

%%
[illCWF1, wave] = ieReadSpectra('illCWF-20180220');
[illCWF2] = ieReadSpectra('illCWF-20201023', wave);
illCWF1 = ieScale(illCWF1, 1);
illCWF2 = ieScale(illCWF2, 1);
plotRadiance(wave, [illCWF1(:), illCWF2(:)]);

%%
illDay = ieReadSpectra('illDay-20201023', wave);
illDay = ieScale(illDay, 1);
plotRadiance(wave, illDay);

%%
illHor = ieReadSpectra('illHorizon-20180220', wave);
illHor = ieScale(illHor, 1);
plotRadiance(wave, illHor);

%%
plotRadiance(wave, [illHor(:), illA1(:)])
legend({'Horizon', 'ill A'});

plotRadiance(wave, [illCWF1(:), illDay(:)])
legend({'CWF', 'Day'});

%% END