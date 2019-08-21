%% s_safetyHazardFunctions.m
%
% These safety standard data were taken from the EN65471 standard for
% Photobiological safety of lamps and lamp systems.  The PDF is in the
% google drive under Papers, Medicine, Oral Cancer Screening, UVdamage,
% Lighting Standards.
%
% The data copied from the PDF are stored below and written out.  The
% examples at the time illustrate how to get the data from the files, which
% are in data/human/safetyStandards
%
% JEF, BW, 2019

% Examples:
%{
fname = which('Actinic.mat');
wave = 200:10:400;
data = ieReadSpectra(fname,wave);
ieNewGraphWin;
plot(wave,data);
grid on; xlabel('Wave (nm)'); ylabel('Weight');
%}
%{
fname = which('Actinic.mat');
wave = 200:10:400;
data = ieReadSpectra(fname,wave);
ieNewGraphWin;
plot(wave,data);
grid on; xlabel('Wave (nm)'); ylabel('Weight');
%}
%{
fname = which('blueLightHazard.mat');
wave = 300:10:800;
data = ieReadSpectra(fname,wave);
ieNewGraphWin;
plot(wave,data);
grid on; xlabel('Wave (nm)'); ylabel('Weight');
%}
%{
fname = which('burnHazard.mat');
wave = 300:10:800;
data = ieReadSpectra(fname,wave);
ieNewGraphWin;
plot(wave,data);
grid on; xlabel('Wave (nm)'); ylabel('Weight');
%}


%%
ActinicUVHazardFunction = ...
    [200 0.030
    205 0.051
    210 0.075
    215 0.095
    220 0.120
    225 0.150
    230 0.190
    235 0.240
    240 0.300
    245 0.360
    250 0.430
    254 0.500
    255 0.520
    260 0.650
    265 0.810
    270 1.000
    275 0.960
    280 0.880
    285 0.770
    290 0.640
    295 0.540
    297 0.460
    300 0.300
    303 0.120
    305 0.060
    308 0.026
    310 0.015
    313 0.006
    315 0.003
    316 0.0024
    317 0.0020
    318 0.0016
    319 0.0012
    320 0.0010
    322 0.00067
    323 0.00054
    325 0.00050
    328 0.00044
    330 0.00041
    333 0.00037
    335 0.00034
    340 0.00028
    345 0.00024
    350 0.00020
    355 0.00016
    360 0.00013
    365 0.00011
    370 0.000093
    375 0.000077
    380 0.000064
    385 0.000053
    390 0.000044
    395 0.000036
    400 0.000030];
%%
figure; plot(ActinicUVHazardFunction(:,1), log10(ActinicUVHazardFunction(:,2)));
%% Save the data
fname = fullfile(isetRootPath,'data','human','safetyStandards','Actinic');
comment = 'Actinic UV Hazard function.  Official definition from EN62471. Oral Cancer project, UVDamage, Lighting Standards.';
ieSaveSpectralFile(ActinicUVHazardFunction(:,1),ActinicUVHazardFunction(:,2),comment,fname);
%%
BlueLightHazardFunction = ...
    [300 0.01
    305 0.01
    310 0.01
    315 0.01
    320 0.01
    325 0.01
    330 0.01
    335 0.01
    340 0.01
    345 0.01
    350 0.01
    355 0.01
    360 0.01
    365 0.01
    370 0.01
    375 0.01
    380 0.01
    385 0.013
    390 0.025
    395 0.05
    400 0.10
    405 0.20
    410 0.40
    415 0.80
    420 0.90
    425 0.95
    430 0.98
    435 1.00
    440 1.00
    445 0.97
    450 0.94
    455 0.90
    460 0.80
    465 0.70
    470 0.62
    475 0.55
    480 0.45
    485 0.40
    490 0.22
    495 0.16
    500 0.1000
    505 0.0794
    510 0.0631
    515 0.0501
    520 0.0398
    525 0.0316
    530 0.0251
    535 0.0200
    540 0.0158
    545 0.0126
    550 0.0100
    555 0.0079
    560 0.0063
    565 0.0050
    570 0.0040
    575 0.0032
    580 0.0025
    585 0.0020
    590 0.0016
    595 0.0013
    600 0.001
    605 0.001
    610 0.001
    615 0.001
    620 0.001
    625 0.001
    630 0.001
    635 0.001
    640 0.001
    645 0.001
    650 0.001
    655 0.001
    660 0.001
    665 0.001
    670 0.001
    675 0.001
    680 0.001
    685 0.001
    690 0.001
    695 0.001
    700 0.001];
%%
figure; plot(BlueLightHazardFunction(:,1), log10(BlueLightHazardFunction(:,2)));

%% Save the data
fname = fullfile(isetRootPath,'data','human','safetyStandards','blueLightHazard');
comment = 'Blue light Hazard.  Official definition from EN62471. Oral Cancer project, UVDamage, Lighting Standards.';
ieSaveSpectralFile(BlueLightHazardFunction(:,1),BlueLightHazardFunction(:,2),comment,fname);

%%
BurnHazardFunction = ...
    [380  0.1
    385  0.13
    390  0.25
    395  0.5
    400  1.0
    405  2.0
    410  4.0
    415  8.0
    420  9.0
    425  9.5
    430  9.8
    435  10.0
    440  10.0
    445  9.7
    450  9.4
    455  9.0
    460  8.0
    465  7.0
    470  6.2
    475  5.5
    480  4.5
    485  4.0
    490  2.2
    495  1.6
    500    1.0
    505   1.0
    510   1.0
    515   1.0
    520   1.0
    525   1.0
    530   1.0
    535   1.0
    540   1.0
    545   1.0
    550   1.0
    555   1.0
    560   1.0
    565   1.0
    570    1.0
    575    1.0
    580   1.0
    585   1.0
    590   1.0
    595   1.0
    600 1.0
    605  1.0
    610  1.0
    615  1.0
    620  1.0
    625  1.0
    630  1.0
    635  1.0
    640  1.0
    645  1.0
    650  1.0
    655  1.0
    660  1.0
    665 1.0
    670  1.0
    675  1.0
    680  1.0
    685  1.0
    690  1.0
    695  1.0
    700                         1
    705         0.977237220955811
    710         0.954992586021436
    715         0.933254300796991
    720          0.91201083935591
    725         0.891250938133746
    730         0.870963589956081
    735         0.851138038202376
    740         0.831763771102671
    745         0.812830516164099
    750         0.794328234724281
    755         0.776247116628692
    760         0.758577575029184
    765         0.741310241300917
    770          0.72443596007499
    775         0.707945784384138
    780         0.691830970918937
    785         0.676082975391982
    790         0.660693448007596
    795         0.645654229034656
    800         0.630957344480193
    805         0.616595001861482
    810         0.602559586074358
    815         0.588843655355589
    820         0.575439937337157
    825         0.562341325190349
    830         0.549540873857625
    835         0.537031796370253
    840         0.524807460249773
    845         0.512861383991365
    850         0.501187233627272
    855         0.489778819368446
    860         0.478630092322638
    865         0.467735141287198
    870         0.457088189614875
    875         0.446683592150963
    880         0.436515832240166
    885         0.426579518801593
    890         0.416869383470335
    895         0.407380277804113
    900         0.398107170553497
    905         0.389045144994281
    910         0.380189396320561
    915         0.371535229097173
    920         0.363078054770101
    925         0.354813389233575
    930         0.346736850452532
    935         0.338844156139203
    940         0.331131121482591
    945         0.323593656929628
    950         0.316227766016838
    955         0.309029543251359
    960         0.301995172040202
    965         0.295120922666639
    970         0.288403150312661
    975         0.281838293126445
    980         0.275422870333817
    985         0.269153480392692
    990         0.263026799189538
    995         0.257039578276886
    1000         0.251188643150958
    1005         0.245470891568503
    1010         0.239883291901949
    1015         0.234422881531992
    1020         0.229086765276777
    1025         0.223872113856834
    1030         0.218776162394955
    1035         0.213796208950223
    1040         0.208929613085404
    1045         0.204173794466953
    1050         0.2
    1055                       0.2
    1060                       0.2
    1065                       0.2
    1070                       0.2
    1075                       0.2
    1080                       0.2
    1085                       0.2
    1090                       0.2
    1095                       0.2
    1100                       0.2
    1105                       0.2
    1110                       0.2
    1115                       0.2
    1120                       0.2
    1125                       0.2
    1130                       0.2
    1135                       0.2
    1140                       0.2
    1145                       0.2
    1150                       0.2
    1155         0.158865646944856
    1160         0.126191468896039
    1165         0.100237446725454
    1170        0.0796214341106994
    1175        0.0632455532033676
    1180        0.0502377286301916
    1185        0.0399052462993776
    1190        0.0316978638492223
    1195        0.0251785082358833
    1200                      0.02
    1205                      0.02
    1210                      0.02
    1215                      0.02
    1220                      0.02
    1225                      0.02
    1230                      0.02
    1235                      0.02
    1240                      0.02
    1245                      0.02
    1250                      0.02
    1255                      0.02
    1260                      0.02
    1265                      0.02
    1270                      0.02
    1275                      0.02
    1280                      0.02
    1285                      0.02
    1290                      0.02
    1295                      0.02
    1300                      0.02
    1305                      0.02
    1310                      0.02
    1315                      0.02
    1320                      0.02
    1325                      0.02
    1330                      0.02
    1335                      0.02
    1340                      0.02
    1345                      0.02
    1350                      0.02
    1355                      0.02
    1360                      0.02
    1365                      0.02
    1370                      0.02
    1375                      0.02
    1380                      0.02
    1385                      0.02
    1390                      0.02
    1395                      0.02
    1400                      0.02];
%%
figure; plot(BurnHazardFunction(:,1), log10(BurnHazardFunction(:,2))); hold on;
plot(BlueLightHazardFunction(:,1), log10(BlueLightHazardFunction(:,2)));

%% Save the data
fname = fullfile(isetRootPath,'data','human','safetyStandards','burnHazard');
comment = 'Burn Hazard.  Official definition from EN62471. Oral Cancer project, UVDamage, Lighting Standards.';
ieSaveSpectralFile(BurnHazardFunction(:,1),BurnHazardFunction(:,2),comment,fname);

%% END
