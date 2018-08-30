function exrreadchannels( filename )
%EXRREADCHANNELS    Read the raw channel data of an OpenEXR image.
%   M = EXRREADCHANNELS(FILENAME) reads all the channels of the OpenEXR
%   file and returns a containers.Map object on which the keys are
%   strings with the channel names and the values are the actual
%   channel data.
%
%   M = EXRREADCHANNELS(FILENAME,C1,C2,...) reads only the channels named
%   by the strings C1,C2,...,Cn. Also returns a containers.Map object.
%   Note that if there is only a single channel the result is just a
%   matrix with the value of the channel.
%
%   M = EXRREADCHANNELS(FILENAME, CARRAY) behaves as above, but it
%   receives a cell array with the names of the desired channels.
%
%   [M1,...] = EXRREADCHANNELS(FILENAME,C1,...) reads the channels
%   specified by the strings C1,C2,...,Cn and stores the channel data in
%   the corresponding matrices M1,M2,...,Mn.
%
%   [M1,...] = EXRREADCHANNELS(FILENAME, CARRAY) behaves as above, but it
%   receives a cell array with the names of the desired channels.
%
%   For all these methods it is an error to request a channel which does
%   not exist. Use EXRINFO to get a list of the channels available for
%   a given file.
%
%   Note: this implementation uses the ILM IlmImf library version 1.7.
%
%   See also CONTAINERS.MAP,EXRINFO,EXRREAD,TONEMAP

% Edgar Velazquez-Armendariz (eva5@cs.cornell.edu)
%
% (The help system uses this file, but actually doing something with it
% will employ the mex file).
