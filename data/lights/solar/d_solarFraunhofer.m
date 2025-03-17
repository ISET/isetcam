%% Convert the solar csv files into mat-files
%
% The sun is a blackbody radiator with a temperature close to 5700 degrees
% Kelvin.  There are absorption bands for multiple substances in the
% surface of the sun that absorb, as well as some oxygen bands in the
% atmosphere.
%
%  See the fise_daylight scripts for some plots and calculations.

%%
chdir(fullfile(isetRootPath,'data','lights','solar'));

%% Read the CSV BW downloaded

solarSpectrum  = readmatrix('solar_spectrum_fraunhofer.csv');

% I read these lines, but then added some more
% fraunhoferLines = readmatrix('fraunhofer_lines.csv');
% 
% Not all of them are very strongly absorbing. I selected some that align
% with the daylight notches we measured and that are in the CIE standard in
% the daylight directory.
fSelectSolar = [1 3, 4, 5, 6, 8];
fSelectEarth = [11 12 13 14 15 16];
fraunhoferLines = {...
    'Calcium','Ca K',398.3;
    'Calcium','Ca H',396.8;
    'Iron and Calcium','G band (Fe, Ca)',430.8;
    'Hydrogen','Hβ',486.1;
    'Magnesium','Mg b_{1,4}',518.4; %5
    'Sodium','Na D1',589.6;
    'Sodium','Na D2',589.0;
    'Hydrogen','Hα',656.3;
    'Iron (Fe I)','C1',667.8;
    'Iron Fe I','C2',677.0;    % 10
    'oxygen earth','O2 B',686.7;
    'Water vapor','Z1',718;
    'oxygen earth','O2 A',759.4;
    'Silicon Si I','S1',771.1;  
    'Iron Fe I','S2',793.2;    % 15
    'oxygen earth','O2 C',822.7;
    'Water vapor','Y',898.8;
    'Water vapor','Y',912.8;
    'Water vapor','Y',960.8;    % 20
    'Water vapor','X',993.5;
    'Water vapor','Y',1130;};

comment = {'Downloaded from chatgpt.  Close to blackbody 5775',...
    'https://chatgpt.com/share/679ebc49-5a7c-8002-a282-598e7f1bbb30',...
    'fSelectSolar = [3, 4, 5, 6, 8]; fSelectEarth = [11 12 15 16 17];', ...
    fraunhoferLines,fSelectSolar, fSelectEarth};
disp(comment)

fname = fullfile(isetRootPath,'data','lights','solar','solarSpectrum.mat');

%% Only save when you are ready
ieSaveSpectralFile(solarSpectrum(:,1),solarSpectrum(:,2),comment,fname);

%% Read the solar spectrum and various lines

[spd,wave,comment] = ieReadSpectra(fname);

ieFigure;
plot(wave,spd);

%% These comments contain multiple Fraunhofer and Earth atmosphere lines.  

% I think I should save them as a separate file, but for now they are
% here.
allLines = comment{4};

% These are some examples for plotting.
fSelectSolar = comment{5};
fSelectEarth = comment{6};

solarLines = allLines(fSelectSolar(:),:);
solarLines = cell2mat(solarLines(:,3))';

earthLines = allLines(fSelectEarth(:),:);
earthLines = cell2mat(earthLines(:,3))';

hold on;
ylim = get(gca,'ylim');
x = earthLines;
for ii=1:numel(x)
    line([x(ii),x(ii)],[ylim(1),ylim(1)+0.1],'Color','b');    
end

x = solarLines;
for ii=1:numel(x)
    line([x(ii),x(ii)],[ylim(1),ylim(1)+0.1],'Color','r');    
end

grid on; xlabel('Wavelength (nm)'); ylabel('Relative energy');

%%
