function exrinfo( filename )
%EXRINFO    Read metadata from the header of an OpenEXR image.
%   INFO = EXRINFO(FILENAME) reads the header of the given OpenEXR
%   file and returns a struct with the following fields:
%     channels - a cell array with the names of the image channels.
%     size     - Matlab-style size of the image: it is an 1x2 matrix
%                equivalent to [height, width].
%     attributes - a containters.Map object with the full, raw
%                attributes from the file. Note that it will
%                only contain those attributes for which a Matlab
%                conversion is avaiable.
%
% Note: this implementation uses the ILM IlmImf library version 1.7.
%
% See also CONTAINERS.MAP,EXRREAD,EXRREADCHANNELS

% Edgar Velazquez-Armendariz (eva5@cs.cornell.edu)
%
% (The help system uses this file, but actually doing something with it
% will employ the mex file).
