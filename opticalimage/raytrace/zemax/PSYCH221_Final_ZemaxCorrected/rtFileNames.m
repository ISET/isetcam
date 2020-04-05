function [diName, riName, psfNameList, craName] = rtFileNames(lensFile,wave,imgHeight)
% Generate ray trace file names produced by Zemax or Code V
%
%   [diName, riName, psfNameList, craName] = rtFileNames(lensFile,wave,imgHeight)
%
% Create the names of the data files used for converting ray trace data
% into ISET format. 
%
%   The riName is the relative illumination file.
%   The diName is the distortion file.
%   The craName is the chief ray angle file.
%
%   The psfNameList is a cell array of point spread function names
%
% See also: rtImportData, zemaxLoad
%
% Copyright ImagEval Consultants, LLC, 2005.

diName = sprintf('%s_DI_.dat',lensFile);
riName = sprintf('%s_RI_.dat',lensFile);
craName = sprintf('%s_CRA_.dat',lensFile);

% PSF file names
nWave = length(wave);
nHeight = length(imgHeight);
psfNameList = cell(nHeight,nWave);
for ii=1:nHeight
    for jj=1:nWave
        psfNameList{ii,jj} = sprintf('%s_2D_PSF_Fld%.0f_Wave%.0f.dat',lensFile,ii,jj);
        rtCheckPSFFile(psfNameList{ii,jj});
    end
end


return;


function  ok = rtCheckPSFFile(psfFileName)
%
% Verify file length, maybe some other properties, of the psfFile
% This is needed because Zemax doesn't always produce PSF files that are
% correct - we get sample density errors, for example.
%
% When the files contain errors, they are usually text files and less than
% 1K.  So we test for that.

ok = 1;

if ~exist(psfFileName,'file')
    error('No file named %s\n',psfFileName);
else
    test = dir(psfFileName);
    if test.bytes < 1025;
        errordlg(sprintf('Bad PSF file: %s\n',psfFileName));
        ok = 0;
    end
end

return

