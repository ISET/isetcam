function [fname, fpath] = uigetimage(def,titl)
%[filename, fpath] = UIGETIMAGE(def,titl)  
% Use of UIGETFILE tailored for selection of image file(s) with formats
% supported by IMREAD. A dialog box is displayed for the user to fill in,
% and returns the filename and path strings.
%
% You can choose a single file, or several using the Shift and Ctrl keys
% in the usual way supported by the operating system.
%
% def   = [optional] default folder in which to select image file(s)
%       = [] (empty) use current folder (default)
% titl  = [optional] title or request, e.g., 'Please select first image'
%       = [] (empty) use default image selection tile
%
% fname = file name, char variable for single file, or
%         cell array of file names if several are chosen.
% fpath = [optional] file path (directory of folder) for chosen file(s)
%         if fpath is not asked for, then fname contains the full path
%         for each file chosen.
%
% NEEDS: UIGETFILE
%
% Example usage:
%  Returns full file path to selected file(s) in current folder
%>  fn = uigetimage([],'Pick a picture file')
%
% Returns names and path for file(s) selcted with default title
%>  [fn, fpath] = uigetimage;
%
% Initial selection is from the specified location (pp) with default title
%> pp = 'C:\Users\Pete\'
%> [fn, fpath] = uigetimage(pp);
%
% Peter Burns, 22 April 2011
%              18 Nov.  2015 Added arguement def to specify the folder
%              1  Dec.  2015 Added support for JPEG 2000 files
%              19 Oct.  2020 ptm and ptw files

fflag = 0;
if nargin<1
    titl = 'Select input image file (tif, jpg, bmp, gif, png... )';
    def = pwd;
end
if nargin==1
    titl = 'Select input image file (tif, jpg, bmp, gif, png... )';
  
end
if isempty(def) 
    def = pwd;
end

% Folder specified
if nargin==2 && isempty(def)~=1
    hom = pwd;
    def = fileparts(def);
%     cd(def); % jump
    fflag = 1;
end

sup =['*tif;*TIF;*.tiff;*.TIFF;*.jpg;*.jpeg;*.JPG;*.JPEG;', ...
      '*.gif;*.GIF;*.bmp;*.BMP;*.png;*PNG;*.jp2;*.JP2;*.jpf;*.JPF;', ...
      '*.ptw;*.PTW;*.ptm;*.PTM']; 
  ftype =  {sup,  'Supported: jpg, tif, bmp, gif, png ...'; ...     
           '*.jpg;*.jpeg;*.JPG;*.JPEG',  'JPEG'; ...
           '*.jp2;*.JP2;*.jpf;*.JPF;'    'JPEG 2000'; ...
           '*.tif;*.TIF;*.tiff;*.TIFF',  'TIF'; ... 
           '*.gif;*.GIF;',               'GIF'; ...
           '*.bmp;*.BMP;',               'BMP'; ...
           '*.png;*.PNG;',               'PNG'; ...
           '*.ptw;*.PTW;',               'PTW'; ...
           '*.ptm;*.PTM;',               'PTM'; ...
           '*.*',                        'All Files (*.*)'};
     
 [fname, fpath] = uigetfile(ftype, titl, 'MultiSelect', 'on');
    
 %  To restrict selection to a single file, uncomment the next line, and
 %  delete the previous one above
 %  [fname, fpath] = uigetfile(ftype, titl);
if fflag~=0
    cd(hom); % jump back
end
    if isa(fname,'numeric')
        disp('No file chosen');
        return      
  % If output argument, fpath, is not asked for, fname contains full path
    elseif nargout<2
        if iscell(fname) ~=1
            fname = [fpath,fname];
        else
            for ii=1:length(fname)
                fname{ii}= [fpath,fname{ii}];
            end
        end
    end
