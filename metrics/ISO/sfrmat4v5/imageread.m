function [status, dat1, ftype, fpath, fname, mp] = imageread(filename, nlin, npix)
%[status,dat,ftype,fpath,fname, mp] = imageread(fname, nlin, npix) reads tif, jpeg, DICOM,
%  rvg and raw data with file browser if needed. The file extension is used
%  to idntify file format.
% filename = optional file name
% status   = 0 OK
%          = 1 not OK
% dat      = image data array
% ftype    = file extension
% fpath    = path
% fname    = file name
% mp       = 
% Needs: imread, dicomread (image proc. toolbox)
%        Matlab 7.1 or higher for RVG files
% Examples
%>> [status, dat] = imageread;
%>> [status, dat, ftype] = imageread('test.tif');
%
%Peter Burns , 19 June 2021

status = 0;
if nargin< 3
  npix = 0;
end
if nargin< 2
  nlin = 0;
end

if  nargin < 1 || isempty(filename) == 1
        
    [fname, fpath] = uigetimage;
    
    if fname == 0
        status = 1;
        dat1 = 0;
        ftype = 0;
        disp('No file chosen');
        return
    end
     filename = [fpath, fname];
end %  nargin < 1;

ftype = filename(end-2: end);

if strcmp(ftype,'dcm')==1 || strcmp(ftype,'DCM')==1 
   dtest = exist('dicomread');
   if dtest ~= 0
         info = dicominfo(filename);
         dat1 = dicomread(filename);
         ftype = info;
   else
         disp(' ** You do not appear to have the image processing toolbox.');
         disp(' ** DICOMREAD from this library is needed to read DICOM files.');
         beep
     status = 1;
     dat1   = 0;
     ftype  = 0;
     return    
   end

elseif strcmp(ftype,'rvg')==1 || strcmp(ftype,'RVG')==1 || ...
        strcmp(ftype,'stv')==1 || strcmp(ftype,'STV')==1
   ver = version;
%   vernum = str2num(ver(1:3));
    vernum = str2double(ver(1:3));
   if vernum < 7.1
     disp(' **  Unfortunately, you will need Matlab 7.1  **')
     disp(' **  or higher to read RVG files.             **');
     beep
     status = 1;
     dat1   = 0;
     ftype  = 0;
     return    
   else dtest = exist('dicomread');
     if dtest ~= 0
        dat1 = dicomread(filename);
     else
         disp(' ** You do not appear to have the image processing toolbox.');
         disp(' ** DICOMREAD from this library is needed to read DICOM files.');
         beep
         status = 1;
         dat1   = 0;
         ftype  = 0;
         return
     end
   end
elseif strcmp(ftype,'ptw')==1
   
   [dat1] = readptw(filename);
   
else 
   [dat1, mp] = imread(filename);  
end

if exist('mp')~=1
    mp = [0:255
          0:255
          0:255]/255;
      mp = mp';
end



