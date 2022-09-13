function [vcFname,wavelength,data,comment] = ieXL2ColorFilter(xlFname, vcFname, dType)
% Convert data from an Excel Spread Sheet to an ISET color filter file or a
% spectral file
%
%   [vcFname,wavelength,data,comment] = ieXL2ColorFilter(xlFname, vcFname, dType)
%
%  The color filter file contains data, wavelength, comment and filterNames.
%
%  The spectral file only contains data, wavelength and comment.
%
%  The Excel SpreadSheet data should have N+1 columns worth of data.  The
%  first column should contain the wavelength information and N columns
%  should contain the spectral data.
%
%  If the XL data file describes color filter transmissivities  these
%  values should be in the range [0,1], not percentages.  If the entries
%  exceed 1, this program will assume they are percentages and divide by
%  100. The user is prompted for the names of the color filters.  The data
%  are read from the file.
%
%  If a spectral file, the data are not touched and the user is not
%  prompted for a color filter name for each column.
%
% Example:
%
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('xlFname')
    xlFname = vcSelectDataFile('customer','r');
    if isempty(xlFname), return; end
end
if ieNotDefined('dType'), dType = 'colorfilter'; end

% Read the Excel spread sheet data
[a,comment] = xlsread(xlFname);

wavelength = a(:,1);
l = ~isnan(wavelength);
wavelength = wavelength(l);

% Copy the relevant columns from the spread sheet into the data columns.
% We have cases in which a column of the spreadsheet reads in as all NaNs.
% We don't copy such columns. Maybe we should?
for ii=2:size(a,2)
    tmp = a(:,ii);
    l = ~isnan(tmp);
    if sum(l) > 0
        tmp = tmp(l);
        data(:,ii-1) = tmp(:);
    end
end

% Check for sense
if ~(length(data) == length(wavelength))
    error('Data and wavelength must be the same length.');
end

switch lower(dType)
    case 'colorfilter'
        % In case the data are in percentages, rather than fractions, warn the user
        % that you think they are percentages but scale the data anyway.
        if max(data(:) > 1)
            warndlg('Data exceed out of [0.1] range.  Assuming they are percentages and dividing by 100.');
            data = data/100;
        end
        
        % Color filters need a name.  The first letter of the name must indicate
        % the type of filter (Red,Green,Cyan, etc.)
        nFilters = size(data,2);
        for ii=1:nFilters
            prompt={sprintf('Enter a color filter name (must begin with one of %s)',sensorColorOrder('string'))};
            def={'rFilter'};
            dlgTitle='Input filter name';
            lineNo=1;
            filterNames{ii} = char(inputdlg(prompt,dlgTitle,lineNo,def));
        end
        
        if ieNotDefined('vcFname')
            vcFname = vcSelectDataFile('customer','w');
            if isempty(vcFname), return; end
        end
        
        % vcFname should be a partially qualified path, I think.
        save(vcFname,'data','wavelength','comment','filterNames');
        
    case 'spectraldata'
        
        if ieNotDefined('vcFname')
            vcFname = vcSelectDataFile('customer','w');
            if isempty(vcFname), return; end
        end
        save(vcFname,'data','wavelength','comment');
        
    otherwise
        error('Unknown data type: %s',dType);
end

return;
