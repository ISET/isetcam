function [A, fname] = readptw(fname)
%[A, fname] = readptw(fname) Read FLIR's (e.g, from ALTAIR) ptw, ptm images
% fname = (optional) name of *.ptw or .ptm image file
% A     = output image array
% fname = file name of selected image file
%
% Based on a posted script by Andrew Wade, awade@ligo.caltech.edu
%
%Peter D. Burns 5 Oct. 2020. Written for Hingrid Spirlandeli
%
if nargin<1
[filename, pathname] = uigetfile('*.ptw;*.ptm', 'Choose a ptw image file');
    if isa(filename,'double')
        disp('No file selected')
        A = 0;
        fname = 0;
        return
    else
        fname = [pathname, filename];
    end
end    
% Initialization of the file pointer.
fid = fopen(fname,'r');

% File Header length in Bytes.
LgthFileMainHeader = 3476;
% Image Header length in Bytes.
LgthImHeader = 1016;
% Recover the number of pixels in images:
fseek(fid, 23, 'bof');
NbPixelImage = fread(fid,1,'uint32');
% Recover the total number of images:
fseek(fid, 27, 'bof');
Nbimage = fread(fid,1,'uint32');
% Recover width of images:
fseek(fid, 377, 'bof');
NbColImage = fread(fid,1,'uint16');
% Recover height of images:
fseek(fid, 379, 'bof');
NbRowImage = fread(fid,1,'uint16');
% Set the pointer at the beginning of the image header.
fseek(fid, LgthFileMainHeader, 'bof');
% Initialization of a viedo buffer.
A = zeros(NbRowImage,NbColImage,Nbimage,'uint16');
% h = waitbar(0,[filename ' database importation : ' num2str(0) '/' num2str(Nbimage) ]);
% Main Loop
for i=1:Nbimage 
%     waitbar(i/Nbimage,h,[filename ' database importation : ' num2str(i) '/' num2str(Nbimage) ]); % The file pointer fid is incremented by LgthImHeader.
    fread(fid,LgthImHeader); % The image is extracted from the file.
    B = fread( fid , [NbColImage,NbRowImage] , 'uint16' ); % The image is stored in raw order in the binary file.
    A(:,:,i) = uint16( B' ); % The image is stored in the buffer.
end
