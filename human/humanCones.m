function [cones, macularCorrection, wave] = humanCones(fileName, wave, macularDensity, includedDensity)
%Return human cone data corrected for macular pigment density.
%
%     *********** INTEGRATE WITH HIROSHI'S FUNCTIONS
%     ************ THOSE ARE PROBABLY RIGHT.
%     ************ WE DEFINITELY NEED TO DEAL WITH QUANTA/ENERGY ISSUE
%
%  [cones, macularCorrection, wave] =
%        humanCones(fileName,wave,macularDensity,includedDensity)
%
% The human cone data are read from an existing file, fileName.   We adjust
% the implicit macular density to correct for visual field position.
%
% The original human cones are built with a presumed density of 0.35. We
% strip this off and return a macular pigment free estimate (see below). Or
% we can strip off some other amount of pigment density.
%
% The macular density assumed in the foveal functions can be specified in
% includedDensity.  For the Stockman fundamentals, this value is 0.35.  I
% am not sure what it is (yet) for the Smith-Pokorny fundamentals.  So I
% will assume it is also 0.35 for now.
%
% Examples:
%   To return the cone fundamentals for a macular pigment free region, use:
%
%    [cones,macularCorrection,wave] = humanCones('stockmanAbs',370:730,0,0.35);
%
%    This returns the cones because we strip off 0.35 and then put it back.
%    [cones,macularCorrection,wave] = humanCones('stockmanAbs',370:730,0.35,0.35);
%
%    This is the cones, too
%    [cones,macularCorrection,wave] = humanCones('stockmanAbs',370:730);
%    plot(wave,macularCorrection)
%    plot(wave,cones);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('fileName'), fileName = 'stockmanAbs';
    includedDensity = 0.35;
end
if ieNotDefined('wave'), wave = 370:1:730; end

% Do not adjust for macular if it is not sent in.  If it is sent in, but
% the includedDensity is not, we assume the cones are set to include a 0.35
% macular pigment density.
if ieNotDefined('macularDensity'), macularDensity = []; end
if ieNotDefined('includedDensity'), includedDensity = 0.35; end

cones = ieReadSpectra(fileName, wave);

% If macularDensity is empty, the user simply accepts the cones.
if isempty(macularDensity)
    macularCorrection = ones(size(cones(:, 1)));
    return;
else
    % If macularDensity has a value, then we strip off the included density
    % and include a new density corresponding to the included value.
    t = macular(includedDensity, wave);
    macularCorrection = 10.^-(t.unitDensity * (macularDensity - includedDensity));
    cones = diag(macularCorrection) * cones;
end

end
