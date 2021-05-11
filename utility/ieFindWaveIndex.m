function idx = ieFindWaveIndex(wave, waveVal, perfect)
% Returns a (0/1) vector of indices s.t. wave(idx) matches a waveVal entry.
%
%  idx  = ieFindWaveIndex(wave,waveVal,[perfect=1])
%
% We want to address only some wavebands in a radiance data set (e.g.,
% photons) we find the relevant indices in wave by this call.
%
% If perfect = 1, this routine uses the Matlab function ismember().
%
% If perfect = 0, we accept a closest match, say we want the closest value.
% In this case run, the same wave valuel may match two waveVal entries, and
% there will be different vector lengths returned. We announce this
% mis-match condition.
%
% Example:
%    wave = sceneGet(scene,'wave');
%    waveVal = [500, 600];
%    idx = ieFindWaveIndex(wave,waveVal);
%    foo(:,idx) = val
%
% Copyright ImagEval Consultants, LLC, 2005.

if ~exist('wave', 'var') || isempty(wave), error('Must define list of all wavelengths'); end
if ~exist('waveVal', 'var') || isempty(waveVal), error('Must define wavelength values'); end
if ~exist('perfect', 'var') || isempty(perfect), perfect = 1; end

if perfect
    % Find only perfect matches
    idx = logical(ismember(wave, waveVal));
else
    idx = false(1, length(wave)); % Assume not a member
    % For each waveVal, find the index in wave that is closest.
    for ii = 1:length(waveVal)
        [tmp, entry] = min(abs(wave - waveVal(ii)));
        idx(entry) = 1;
    end
    % Check how we whether the same idx matched two waveVal entries
    nFound = sum(idx);
    if nFound ~= length(waveVal)
        warning('Problems matching wavelengths. Could be out of range.')
    end
end


return;