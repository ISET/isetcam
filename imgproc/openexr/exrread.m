function hdr = exrread( filename )
%EXRREAD    Read OpenEXR high dynamic range (HDR) image.
% HDR = EXRREAD(FILENAME) reads the high dynamic range image HDR from
% FILENAME, which points to an OpenEXR .exr file. HDR is an m-by-n-by-3 RGB
% array in the range (-65504,65504), plus Inf and NaN, and has type single. 
% For scene-referred datasets, these values usually are scene illumination 
% in radians units. To display these images, use an appropriate 
% tone-mapping operator.
% 
% Class Support
% -------------
% The output image HDR is an m-by-n-by-3 image with type single.
%
% Example
% -------
%     hdr = exrread('office.hdr');
%     rgb = tonemap(hdr);
%     imshow(rgb);
%
% Note: this implementation uses the ILM IlmImf library version 1.6.1.
%
% Reference: 
% Florian Kainz et. al. "The OpenEXR Image File Format". GPU Gems, 2004.
% (http://developer.download.nvidia.com/books/HTML/gpugems/gpugems_ch26.html)
% Industrial Light & Magic OpenEXR website and documentation
% (http://www.openexr.com)
%
% See also EXRWRITE,TONEMAP

% Edgar Velazquez-Armendariz (eva5@cs.cornell.edu)
% Based on the originals by Jinwei Gu (jwgu@cs.columbia.edu)
%
% (The help system uses this file, but actually doing something with it
% will employ the mex file).
