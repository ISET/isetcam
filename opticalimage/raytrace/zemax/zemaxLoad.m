function data = zemaxLoad(fName,psfSize)
%Convert Zemax data into ISET format (requires optics key)
%
%  data = zemaxLoad(fName,psfSize)
%
% fName:   a file name for the Zemax text files with psf data
% psfSize: the number of psfSamples (usually 128).
%
% The text data are read in and then processed on the assumption that the
% zemax macro wrote out the data along the y-axis (not the x-axis).  That
% is how we wrote the macro.
%
% p-Code
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Check that the file exists
if ~exist(fName,'file')
    error('No PSF file named %s\n',fName);
end

%% Read the PSF file. 

% Read the data as a set of uchars.
fid = fopen(fName,'r'); s = fread(fid,'*char'); fclose(fid);

% Eliminate the bad characters (not ascii range)
s = s(s > 0 & s < 129)';

% Pull out the data part.  This is a horrible hack.  I wish we had a better
% way, and we need one soon!
dStart = strfind(s,'normalized.') + length('normalized.') + 2;
data = s(dStart:end);

% This converts the string into a cell.
data = textscan(data,'%f');

% Reshape
data = reshape(data{1},psfSize,psfSize);

% vcNewGraphWin; mesh(data)

%% This is important. 
% We expect the data are written out by the macros if
% they were along the y-axis.  In the image plane where we use the data,
% the positive y-axis runs from the origin down, and the x-axis runs from
% the origin to the left.  So, we rotate the data 90 deg counter-clockwise
% to get the proper PSF.  
%
% I don't think it matters if we do it clockwise or counter-clockwise,
% really, because of our symmetry assumptions.  But I am trying to keep
% everything straight.
data = rot90(data);

return
