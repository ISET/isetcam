function [img, info] = hcReadHyspex(filename, lines, samples, bands)
% Reads an ENVI image.
%
%  [img,info] = hcReadHyspex(filename,lines,samples,bands)
%
%   Reads the ENVI image in filename and returns the image img as well as
%   the header information in the struct info. Matlab's Multibandread is
%   used to read the data.
%
%   [img,info] = hcReadHyspex(filename,lines,samples,bands) reads only
%   the lines, samples and bands specified in the arguments.
%
%   See also MULTIBANDREAD, hcReadHyspexImginfo.
%
% Renamed for use in ISET-4.0.  Taken from read_ENVI_img
% Author: trym.haavardsholm@ffi.no
%
% Example:
%
%   [img,hdr] = hcReadHyspex(filename);
%
% Copyright Imageval, LLC, 2012

% TODO:
%   The uint16 values from the hyspex are not in meaningful energy units
%   (though they are in energy, not photons).  Let's see if we can get the
%   scale factor from them that tells us how to scale the uint16 values to
%   real units.  If we can't, let's do something plausible.

if nargin == 1
    lines = [];
    samples = [];
    bands = [];
elseif nargin == 2
    samples = [];
    bands = [];
elseif nargin == 3
    bands = [];
elseif nargin ~= 4
    error('Wrong number of arguments!');
end

info = hcReadHyspexImginfo(filename);

if isempty(lines) & isempty(samples) & isempty(bands)
    img = multibandread(filename, ...
        [info.lines, info.samples, info.bands], ...
        info.data_type, ...
        info.header_offset, ...
        info.interleave, ...
        info.byte_order);

elseif ~isempty(lines) & isempty(samples) & isempty(bands)
    img = multibandread(filename, ...
        [info.lines, info.samples, info.bands], ...
        info.data_type, ...
        info.header_offset, ...
        info.interleave, ...
        info.byte_order, ...
        {'Row', 'Direct', lines});

else
    if isempty(lines)
        lines = 1:info.lines;
    end
    if isempty(samples)
        samples = 1:info.samples;
    end
    if isempty(bands)
        bands = 1:info.bands;
    elseif strcmpi(bands, 'default')
        bands = info.default_bands;
    end

    img = multibandread(filename, ...
        [info.lines, info.samples, info.bands], ...
        info.data_type, ...
        info.header_offset, ...
        info.interleave, ...
        info.byte_order, ...
        {'Row', 'Direct', lines}, ...
        {'Column', 'Direct', samples}, ...
        {'Band', 'Direct', bands});
end