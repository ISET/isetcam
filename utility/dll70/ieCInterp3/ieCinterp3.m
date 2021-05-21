% interpVolume = ieCinterp3(volumeData, sliceDim, numSlices, samp, badval)
%
% A replacement for Matlab's (notoriously memory-eating) interp3.
%
% volumeData: 3d array of the volume data of size [sliceDim(1), sliceDim(2), nslices].
% sliceDim:   in-plane dimensions [size(volumeData,1) size(volumeData,2)]
% numSlices:  number of slices [size(volumeData,3)]
% samp:       data points to interpolate with size prod(sliceDim)x3
% badval:     value to put into voxels outside the original array (defaults to 0.0).
%
% returns the interpolated volume data.
%
% HISTORY:
%  2002.08.21 RFD (bob@white.stanford.edu) wrote this help file, based on
%             Oscar's code.  Subsequently adjusted and brought here by BW.
%             More comments are needed.
