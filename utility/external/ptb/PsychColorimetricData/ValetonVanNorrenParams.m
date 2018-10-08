function [params] = ValetonVanNorrenParams(logIsoRate,photoreceptors,trolandType,LMRatio)
% [params] = ValetonVanNorrenParams(logIsoRate,[photoreceptors],[trolandType],[LMRatio])
%
% Return a structure containting the parameters of the
% Valeton and VanNorren model of cone adaptation
% as a function of the number of isomerizations per cone per
% second.  The structure also contains the table of trolands
% and corresponding isomerization rates used to spline the
% published numbers.
%
% Valeton and Van Norren (1983, Vision Research, pp. 1539-1547)
% provide their parameters as a function of the number of trolands
% incident on their monkey retina.  We convert this to isomerizations
% per cone, so that we can work in more interesting physical units.
%
% The conversion involves making assumptions about a lot of constants.
% The assumptions are encapsulated by the photoreceptors structure
% and the passed eye length source and troland type.
%
%   photoreceptors - structure interpreted by RetIrradianceToIsoRecSec.
%   eyeLengthSource - string or value interpreted by EyeLength.
%   trolandType - string interpreted by TrolandsToRetIrradiance.
%   LMRatio - value of L to M cone ratio to assume for original measurements (Default 2).
% 
% The parameters are provided in Table 1 of the paper, for a range
% of troland values.  The model parameters are sigmaL and gamma.
% and gamma.
%
% See also: TrolandsToRetIrradiance, RetIrradianceToIsoRecSec, EyeLength,
%   DefaultPhotoreceptors, FillInPhotoreceptors.
%
% 7/18/03  dhb  Started writing it.

% Fill in default
if (nargin < 2 || isempty(photoreceptors))
	photoreceptors = DefaultPhotoreceptors('LivingHumanFovea');
	photoreceptors.macularPigmentDensity.source = 'None';	
	photoreceptors = FillInPhotoreceptors(photoreceptors);
end
if (nargin < 3 || isempty(trolandType))
	trolandType = 'Photopic';
end
if (nargin < 4 || isempty(LMRatio))
	LMRatio = 2;
end

% Fill in the values for the photoreceptors structure
S = photoreceptors.nomogram.S;

% Type in what we need of Table 1.  Take the lowest
% level as 1 log td.
logBackgroundTd = [1 2 3 4 5 6];
logSigmaAlpha = [3.2 3.5 3.9 4.4 5.2 6.3];
gamma = [1 0.93 0.82 0.68 0.59 0.62];

% Load in the arc lamp spectrum used in the experiments
load spd_xenonArc

% Convert trolands used in the experiment to quanta per
% cone per second.  Valeton and Van Norren use human trolands,
% even though they are studying monkey.
for i = 1:length(logBackgroundTd)
	trolands = 10^logBackgroundTd(i);
    if (strcmp(photoreceptors.eyeLengthMM.source,'Value provided directly'))
        irradianceWatts = TrolandsToRetIrradiance(spd_xenonArc,S_xenonArc,trolands, ...
            trolandType,photoreceptors.species,photoreceptors.eyeLengthMM.value);
    else
        irradianceWatts = TrolandsToRetIrradiance(spd_xenonArc,S_xenonArc,trolands, ...
            trolandType,photoreceptors.species,photoreceptors.eyeLengthMM.source);
    end
	irradianceWatts = SplineSpd(S_xenonArc,irradianceWatts,S);
	[isoPerConeSec] = RetIrradianceToIsoRecSec(irradianceWatts,S,photoreceptors);
	averageRate = (LMRatio/(LMRatio+1))*isoPerConeSec(1) + (1/(LMRatio+1))*isoPerConeSec(2);
	logBackgroundIsoRate(i) = log10(averageRate);
end

% Now get actual parameters by splining
if (logIsoRate < logBackgroundIsoRate(1))
	params.logSigmaAlpha = logSigmaAlpha(1);
	params.gamma = gamma(1);
elseif (logIsoRate > logBackgroundIsoRate(end))
	params.logSigmaAlpha = logSigmaAlpha(end);
	params.gamma = gamma(end);
else
	params.logSigmaAlpha = interp1(logBackgroundIsoRate,logSigmaAlpha,logIsoRate,'linear');
	params.gamma = interp1(logBackgroundIsoRate,gamma,logIsoRate,'linear');
end
params.logBackgroundTds = logBackgroundTd;
params.logBackgroundIsoRates = logBackgroundIsoRate;

