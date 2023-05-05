function [psfSpacing, psfArea] = zemaxReadHeader(fname)
%Read header information from a Zemax output file
%
%      [psfSpacing, psfArea] = zemaxReadHeader(fname)
%
%  We extract the sample spacing and the data area from the Zemax file
%  header.  We can get additional information, following this method.
%
%  We should be alert to changes in the Zemax output file format. It sure
%  would have been nice of Zemax to put some version information in their
%  text file.
%
%Example:
% fname = 'COOKE_6mm_PSF_11_3.dat';
% [psfSpacing, psfArea] = zemaxReadHeader(fname);
% nSamples = psfArea/psfSpacing
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Argument
if ieNotDefined('fname'), error('File name required.'); end

%% We read the header as a cell array of strings
% nStrings = 70;
fid = fopen(fname,'r');
str = fread(fid,'*char');
fclose(fid);
str = str( (str<128) & (str > 0))';

%% Find the strings
thisString = 'spacing is ';
p = strfind(str,thisString) + length(thisString);
e = strfind(str(p:p+10),' ') - 2;  % Why two?
psfSpacing = str2double(str(p:(p+e)));

thisString = 'area is ';
p = strfind(str,thisString) + length(thisString);
e = strfind(str(p:p+10),' ') - 2;  % Why two?
psfArea = str2double(str(p:(p+e)));

end
