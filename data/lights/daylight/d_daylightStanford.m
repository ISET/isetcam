%% Saving the DiCarlo daylight spectra data
%
% There is some value in having the time stamps along with the spectra.
%
% The data are on Wandell's Google Drive, Data/ and also on his local
% harddrive inside of Data/Daylights.  The SunSpectra file is 9 MB, and I
% am not inclined to add it to ISETCam.
%
% I will keep this script here for a while.  Probably, i will put the
% SunSpectra file up on the digital repository (Stanford) and use ieWebGet
% to permit people to download to local/web inside of ISETCam if they want
% the Table and/or the data.
%
% This is just in preparation for that.


% The 10,756 SPDs, along with their time stamps, are now in a table.
tmp = load('SunSpectra_DiCarlo.mat');
dt = datetime(tmp.Time');
wave = tmp.Wavelength;

varNames =     {'file','date',  'hour',  'minute', 'spd'};
varTypes = {'string', 'string','double','double','double'};

dayDatabase = table('Size', [size(tmp.SunSpectra,2), length(varNames)], ...
    'VariableNames', varNames, ...
    'VariableTypes',varTypes);


dateStr   = string(dt, 'yyyy-M-dd'); % Extract date as string
hourDbl   = str2double(string(dt, 'HH'));         % Extract hour as string
minuteDbl = str2double(string(dt, 'mm'));       % Extract minute as string

dayDatabase.file = repmat('SunSpectra_DiCarlo.mat', height(dayDatabase), 1);
dayDatabase.date = dateStr;
dayDatabase.hour = hourDbl;
dayDatabase.minute = minuteDbl;
dayDatabase.spd = tmp.SunSpectra';

%% Get the table rows for some hour at and minute

% This averages across days.
hdl = ieFigure;
for hh = 1:max(hourDbl)
    [~,T] = ieTableGet(dayDatabase,'hour',hh,'minute',5);    
    if ~isempty(T)
        plotRadiance(wave,mean(T.spd),'Color','k','hdl',hdl); hold on;
        set(gca,'yscale','log');
        title(sprintf('Hour %.0f',hh));
        pause(1);
    end
end

%% We should check day by day.

%%
