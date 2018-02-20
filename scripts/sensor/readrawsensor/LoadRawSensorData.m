function image = LoadRawSensorData(filename,bpp,byteFormat,row,col)
% Loads sensor data in RAW format
%
%    image = loadRaw(filename, bpp, byteFormat)
%
% byteFormat can be 'little' or 'big'
% data are returned as uint16.  The default byteFormat is 'little'.  We
% list our best guess about big/little in Notes, below.
%
% Example
%  filename = vcSelectDataFile('stayput','r'); 
%  [p,n,e] = fileparts(filename);[n,e]
%  img = LoadRawSensorData(filename,10,'big');  % For Example Device A
%  img = LoadRawSensorData(filename,8);         % For Example Device B
% 
%  img = reshape(img,row,col);
%  imagesc(img); colormap(gray(256));
%  imtool(img)
%
% Notes:
%   DeviceA is 'big endian' and stored as 10 bits
%   Device B is 8 bits and therefore endian doesn't matter.
%   

if ~exist('filename', 'var' ), error( 'Need filename'); end
if ~exist('byteFormat','var'), byteFormat = 'little';  end
if ~exist('bpp','var'), bpp = 8; end

% open the file
fid = fopen( filename, 'r' );

% make sure the file opened properly
if fid<0,  error('Cannot open file %s\n', filename ); end

switch bpp
    case 10
        % Read the data into UINT16.  The top six bits are zero (the data
        % are LSB justified).
        image = uint16 ( fread( fid, 'uint16' ) );
        % This could be handled by the 'ieee-le' flag in fread.
        switch byteFormat
            case 'little'
                image  = swapbytes( image ); % omit this line if the data is big endian
            otherwise
        end
        
    case 8
        image = uint8 ( fread( fid, 'uint8' ) );
        
    otherwise
        error('Bad bpp %.0f.  Must be 8 or 10 bits per pixel.\n',bpp);
end

% close the file
fclose( fid );

return;
