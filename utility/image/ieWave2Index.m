function [idx1,idx2] = ieWave2Index(waveList,wave)
%Convert a wavelength to an index into the wave list.
%
%    [idx1,idx2] = ieWave2Index(waveList,wave)
%
% If only one return argument is requested, then the index closest to the
% specified wavelength. If two indices are requested, these are the indices
% whose wavelength values bound the input wave value.  These are always
% ordered (idx1 < idx2).
%
% Example
%   waveList = sceneGet(scene,'wave');
%   idx = ieWave2Index(waveList,503)
%   [idx1,idx2] = ieWave2Index(waveList,487)
%
% See also: ieFieldHeight2Index()
%
% Copyright ImagEval Consultants, LLC, 2005.

% Programming Note:  We could return weights that might be used for
% interpolation such as idx1 wgt1 idx2 wgt2 if requested.

[v,idx1] = min(abs(waveList - wave));

% Determine two indices that bound the wavelength value.
if nargout == 2
    if waveList(idx1) > wave
        % Send back the index below.  Order everything properly
        idx2 = max(1,idx1 - 1);
        tmp = idx1; idx1 = idx2; idx2 = tmp;
    elseif waveList(idx1) < wave
        % Send back the index above.  No need to order
        idx2 = min(length(waveList),idx1 + 1);
    else
        idx2 = idx1;
    end
end


return;