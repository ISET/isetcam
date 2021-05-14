%JPGWRITE Write a JPEG file to disk.
%
%	jpgwrite('filename',R,G,B,quality) writes the specified file
%	using the Red, Green, and Blue intensity matrices, at the given quality.
%
%	If specified, quality should be in the range 1-100 and will default to
%	75 if not specified.  100 is best quality, 1 is best compression.
%
%       If quality is not a scalar number but a matrix of size 64xN, then
%       it is taken as quantization matrices to be used in the JPEG compression.
%       Each column of the matrix represents one quantization table,
%       in row order (as in C), not zigzag-ed. The first column is
%       the q-table for luminance channel, the second and third columns
%       are for chrominance channels. If only one q-table is provided
%       the default q-table will be used (at quality factor 50) for
%       the chromanance channels; if only two q-tables are provided
%       the second q-table will be used for both chromanance channels.
%
%	See also JPGREAD

%	jpgwrite is a mex file, based on jpgread by Drea Thomas and the
%	examples in the IJG distribution.

%	Tristram Scott  t.scott@mang.canterbury.ac.nz
%	6/10/95
%
%       Modified by Xuemei Zhang, Brian Wandell (added q-table arguments)
%       11/12/96
