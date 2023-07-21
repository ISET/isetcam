function [cData,mn,mx] = ieCompressData(data,bitDepth,mn,mx)
% Compress the image data stored in SCENE and OPTICALIMAGE.
%
%  [cData,mn,mx]  = ieCompressData(data,bitDepth,[mn=min(data(:)],[mx=max(data(:)])
%
%   The data are quantized to uint32  (or uint16) spread over the original
%   range of the data.  The range of the data is recorded and stored as
%   well.  The rounding (compression, uint32) formula is generally
%
%      cData =  uint32 (mxCompress * (data - mn)/(mx - mn));
%      where mxCompress = 2^bitDepth - 1
%
%   The user can either specify the min/max or allow the data min and max
%   to be used.
%
%   If mn > mx, an error is returned.
%   If mn == mx, cData =  uint32 (mxCompress * (data - mn));
%      When using the data to determine mn,mx and mn==mx, this means that
%      the return is all zeros.
%
%   This compression is inverted in the program ieUncompressData.
%
% See sceneGet, sceneSet for examples of the usage.
%
% Copyright ImagEval Consultants, LLC, 2005.

%% To save time, not much checking of input arguments.
warning('Deprecated.');

if ~exist('mn','var'), mn = min(data(:)); end
if ~exist('mx','var'), mx = max(data(:)); end

%% bitDepth should be 16 or 32.
% The case of 32 becomes single precision, which has a 32 bit range (with a
% sign bit).  The case of 16 becomes uint16, which is what we used for many
% years.
mxCompress = (2^bitDepth) - 1;

if mn > mx,      error('Min/Max error.');
elseif mn == mx, s = mx;        % This case is potential trouble.
else             s = (mx - mn);
end


%% We handle large arrays wavelength by wavelength to save some space.
[r,c,w] = size(data);

switch bitDepth
    case {32}
        % 32 bit is one part in 4,294,967,295.  The modern age.
        % Enough precision, we think.
        if w > 31
            % One waveband at a time
            cData = zeros(r,c,w,'uint32');
            for ii=1:w
                cData(:,:,ii) = uint32(round(mxCompress*(data(:,:,ii) - mn)/(s)));
            end
        else
            % All at once.
            cData = uint32(round(mxCompress * (data - mn)/(s)));
        end
    case 16
        % uint16 precision - the old days.
        if w > 31
            % One wavelength at a time
            cData = zeros(r,c,w,'uint16');
            for ii=1:w
                cData(:,:,ii) = uint16(round(mxCompress*(data(:,:,ii) - mn)/(s)));
            end
        else
            % Do it all at once.
            cData = uint16(round(mxCompress * (data - mn)/(s)));
        end
        
    otherwise
        error('Unknown bit depth.');
end

end

