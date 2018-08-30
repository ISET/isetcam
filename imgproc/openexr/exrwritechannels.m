function exrwritechannels( filename )
%EXRWRITECHANNELS    Write a multichannel OpenEXR image.
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, PIXELTYPE, ATTRIBS, CHANNELS, DATA)
%   writes an OpenEXR using the specified compression, storing pixels using the
%   given pixel type for the designated channels and their corresponding data.
%
%   COMPRESSION is a case sensitive string. It is one of:
%     none  - no compression.
%     rle   - run length encoding.
%     zips  - zlib compression, one scan line at a time.
%     zip   - zlib compression, in blocks of 16 scan lines.
%     piz   - piz-based wavelet compression.
%     pxr24 - lossy 24-bit float compression.
%     b44   - lossy 4-by-4 pixel block compression, fixed compression rate.
%     b44a  - lossy 4-by-4 pixel block compression, improved flat fields rate.
%
%   PIXELTYPE is a case sensitive string. It is one of:
%     half   - use half precision (16-bit) floating point numbers.
%     single - use single precision (32-bit) floating point numbers.
%     float  - the same as 'single'.
%
%   ATTRIBS is a containers.Map object whose keys are the attribute's names
%   and the value correspond to the attribute values. The names have to be
%   254 characters long or less, and names longer than 31 characters are
%   only compatible with OpenEXR 1.7 or newer. Using standard OpenEXR
%   attribute names with unexpected values has undefined results.
%   The types for values are limited to string, double, single or int32.
%
%   CHANNELS is either a string (when saving a single-channel image) or a
%   cell vector with the name of each channel. Channel names have to be
%   254 characters long or less, and names longer than 31 characters are
%   only compatible with OpenEXR 1.7 or newer.
%
%   DATA is either one real matrix (when saving a single-channel image) or
%   cell vector of real matrices corresponding to each channel. The image
%   data for CHANNELS{i} is DATA{i}. All matrices in DATA must be the
%   same size.
%
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, PIXELTYPE, CHANNELS, DATA)
%   behaves as above, assuming an empty set of attributes.
%
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, CHANNELS, DATA) behaves as
%   above, assuming PIXELTYPE is 'half'.
%
%   EXRWRITECHANNELS(FILENAME, CHANNELS, DATA) behaves as above, assuming
%   COMPRESSION is 'zip' and PIXELTYPE is 'half'.
%
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, PIXELTYPE, ATTRIBS, CHANNELSMAP)
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, PIXELTYPE, CHANNELSMAP)
%   EXRWRITECHANNELS(FILENAME, COMPRESSION, CHANNELSMAP)
%   EXRWRITECHANNELS(FILENAME, CHANNELSMAP)
%
%   These versions take a CONTAINERS.MAP object whose keys are the channel
%   names and the values the channel data. Note that these functions
%   are less efficient than those which take directly cell arrays for the
%   channel names and data.
%
%   Note: this implementation uses the ILM IlmImf library version 1.7
%
%   See also EXRREADCHANNELS,EXRINFO,CONTAINERS.MAP

% Edgar Velazquez-Armendariz (eva5@cs.cornell.edu)
%
% (The help system uses this file, but actually doing something with it
% will employ the mex file).
