%% d_blood
%
% Creating ISETCam data files for blood absorbance and molarExtinction
%
% From a website by Prahl
% https://omlc.org/spectra/hemoglobin/summary.html
% Data are in the txt file.
%
% Tabulated Molar Extinction Coefficient for Hemoglobin in Water
% These values for the molar extinction coefficient e in [cm-1/(moles/liter)] were compiled by Scott Prahl using data from
% 
% W. B. Gratzer, Med. Res. Council Labs, Holly Hill, London
% N. Kollias, Wellman Laboratories, Harvard Medical School, Boston
% To convert this data to absorbance A, multiply by the molar concentration
% and the pathlength. For example, if x is the number of grams per liter
% and a 1 cm cuvette is being used, then the absorbance is given by   
% 
%         (e) [(1/cm)/(moles/liter)] (x) [g/liter] (1) [cm]
%   A =  ---------------------------------------------------
%                           64,500 [g/mole]
%
% using 64,500 as the gram molecular weight of hemoglobin.
% To convert this data to absorption coefficient in (cm-1), multiply by the molar concentration and 2.303,
% 
% µa = (2.303) e (x g/liter)/(64,500 g Hb/mole)
% where x is the number of grams per liter. A typical value of x for whole blood is x=150 g Hb/liter.
%
% See also
%

%% Read in the txt file

filename = 'prahl_oxy_deoxy_molarextinction.txt'; % Replace with your file name
T = readtable(filename);
fileContent = T{:,:};
disp(fileContent);
size(fileContent)

% Set the variables and save
wave = fileContent(:,1);
oxy = fileContent(:,2);
deoxy = fileContent(:,3);
ieNewGraphWin;
plot(wave,oxy,'r-',wave,deoxy,'b-');

% Use ieSaveSpectralFile to store these out.

%% Checking the data files

[deoxy, wave] = ieReadSpectra('deoxy_molarExtinctionCoefficient.mat');
ieNewGraphWin;
plot(wave,deoxy,'b-');
hold on;

[oxy, wave] = ieReadSpectra('oxy_molarExtinctionCoefficient.mat');
plot(wave,oxy,'r-');   

legend({'deoxy','oxy'})

%%  These are a scalar away from the absorbance
%
% We don't know the right values for the dental application
%

wave = 400:2:700;
deoxy = medium('deoxy_molarExtinctionCoefficient.mat','wave',wave);
deoxy.plot('transmittance','line','b-');

oxy = medium('oxy_molarExtinctionCoefficient.mat','wave',wave);
hold on;
oxy.plot('transmittance','newfigure',false,'line','r-');

%%

deoxyblood = medium('deoxy_molarExtinctionCoefficient.mat','wave',400:700);
deoxyblood.comment
odValues = logspace(-2,1,10);
deoxyblood.opticalDensity = od(1);
deoxyblood.plot('transmittance','line','b-');
for od = odValues(2:end)
    deoxyblood.opticalDensity = od;
    deoxyblood.plot('transmittance','new figure',false,'line','b-');
    hold on;
end

%%
oxyblood = medium('oxy_molarExtinctionCoefficient.mat','wave',400:700);
oxyblood.comment
odValues = logspace(-2,1,10);
oxyblood.opticalDensity = od(1);
oxyblood.plot('transmittance','line','r-');
for od = odValues(2:end)
    oxyblood.opticalDensity = od;
    oxyblood.plot('transmittance','new figure',false,'line','r-');
    hold on;
end

%%
