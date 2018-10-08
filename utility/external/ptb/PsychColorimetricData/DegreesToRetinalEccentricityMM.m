function eccMm = DegreesToRetinalEccentricityMM(eccDegrees,species,method,eyeLengthMm)
% eccMm = DegreesToRetinalEccentricityMM(eccDegrees,[species],[method],[eyeLengthMm])
%
% Convert eccentricity in degrees to retinal eccentricity in mm.   By
% default, this takes into account a simple model eye, rather than just
% relying on a linear small angle approximation.
%
% Input:
%   eccDegrees -- retinal eccentricity in degrees
%   species -- what species
%     'Human'  -- Human eye [default]
%     'Rhesus' -- Rhesus monkey
%   method -- what method
%     'DaceyPeterson'  -- formulae from Dacey & Peterson (1992) [default]
%     'Linear' -- linear, based on small angle approx
%  eyeLengthMm -- Eye length to assume for linear calculation, should be
%      the posterior nodal distance. Defaults to the default values returned
%      by function EyeLength for the chosen species.
%
% The Dacey and Peterson formulae are based on digitizing and fitting
% curves published by
%    1) Drasdo and Fowler, 1974 (British J. Opthth, 58,pp. 709 ff., Figure 2,
%    for human.
%    2) Perry and Cowey (1985, Vision Reserch, 25, pp. 1795-1810, Figure 4,
%    for rhesus monkey.
% These curves, I think, were produced by ray tracing or otherwise solving
% model eyes.  The eyeLengthMm parameter does not affect what this method
% does.
% 
% The default eye length returned by EyeLength for Human is currently the Rodiek value of
% 16.1 mm.  Drasdo and Fowler formulae are based on a length of about this, 
% so the linear and DaceyPeterson methods are roughly consistent for small
% angles.  Similarly with the Rhesus default.  Using other EyeLength's will
% make the two methods inconsistent.
%
% The Dacey and Peterson equations don't go through (0,0), but rather
% produce a visual angle of 0.1 degree for an eccentricity of 0.  This
% seems bad to me. I modified the formulae so that they use the linear
% approximation for small angles, producing a result that does go through
% (0,0).  This may be related to the fact that there is some ambiguity in
% the papers between whether the center should be thought of as the fovea
% or the center of the optical axis.  But I think this difference is small
% enough that the same formulae would apply across such a shift in origin.
%
% I digitized Drasdo and Fowler Figure 2 and compared it to what this
% routine produces.  I'd call agreement so-so, but considerably better than
% what the linear approximation produces.  One could probably do better,
% but my intuition is that the deviations are small compared to eye to eye
% differences and differences that would be produced by different model
% eyes, so that juice isn't worth the squeeze.  I pasted my digitization at
% the end of DegreesToRetinalEccentricity if anyone wants to fuss with
% this.  But probably if you're going to do that, you should do the whole
% ray tracing thing with our best current model eye.
%
% I have not checked the fit to the Perrry and Cowey curve for Rhesus
% against a digitization of that figure.
%
% See also: EyeLength, RetinalEccentricityMMToDegrees, DegreesToRetinalMM, RetinalMMToDegrees
%
% 6/30/2015  dhb  Wrote it.

%% Set defaults
if (nargin < 2 || isempty(species))
    species = 'Human';
end
if (nargin < 3 || isempty(method))
    method = 'DaceyPeterson';
end
if (nargin < 4 || isempty(eyeLengthMm))
    switch (species)
        case 'Human'
            eyeLengthMm = EyeLength(species,'Rodieck');
        case 'Rhesus'
            eyeLengthMm = EyeLength(species,'PerryCowey');
        otherwise
            error('Unknown species specified');
    end
end

%% Checks
if (any(eccDegrees < 0))
    error('Can only convert non-negative eccentricities');
end

%% Do the method dependent thing
switch (method)
    case 'DaceyPeterson'
        % Out of paranoia, make sure we use the right eye length parameters
        % for this method, so that the low angle linear approximation that
        % we tag on comes out right.
        switch (species)
            case 'Human'
                eyeLengthMm = EyeLength(species,'Rodieck');
            case 'Rhesus'
                eyeLengthMm = EyeLength(species,'PerryCowey');
            otherwise
                error('Unknown species specified');
        end
    
        % Set quadratic parameters
        switch (species)
            case 'Human'
                a = 0.035; b = 3.4; c1 = 0.1; 
            case 'Rhesus'
                a = 0.038; b = 4.21; c1 = 0.1;
            otherwise 
                error('Unknown species passed');
        end
        
        % Invert the quadratic
        c = c1-eccDegrees;
        eccMm = (-b + sqrt((b^2) - 4*a*c))/(2*a);
        
        % Don't return negative numbers
        eccMm(eccMm < 0) = 0;
        
        % Replace small angles by the linear approximation
        degreeThreshold = 0.2;
        index = find(eccDegrees < degreeThreshold);
        if (~isempty(index))
            eccMM(index) = DegreesToRetinalMM(eccDegrees(index),eyeLengthMm,false);
        end

    case 'Linear'
        eccMm = DegreesToRetinalMM(eccDegrees,eyeLengthMm,false);
        
    otherwise
        error('Unknown method passed')
end
end

%% Drasdo and Fowler Figure 2
%
% This is ellipsoid model data, digitized from their figure.  It is not
% clear to me which curve (ellipsoid or sphere) Dacey and Peterson
% digitized and fit.  First column is degrees, second is mm.
% drasdoFowlerData = ...
%     [1.429393919263E0	4.001594366571E-1
%     3.492105671073E0	9.230850993158E-1
%     6.034234593326E0	1.662020859629E0
%     1.000354303683E1	2.739148342523E0
%     1.571668991785E1	4.215850660998E0
%     2.381363626298E1	6.400797183286E0
%     3.286388095396E1	8.862844615691E0
%     4.016364401337E1	1.073941407028E1
%     4.572178303328E1	1.227837640337E1
%     4.794503864125E1	1.289396133661E1
%     4.984831373591E1	1.335521158573E1
%     5.254323612126E1	1.396991961735E1
%     5.523705130760E1	1.455364379194E1
%     6.126021391085E1	1.590582608118E1
%     6.632675657123E1	1.688795588919E1
%     7.012555636750E1	1.759356938816E1
%     7.503155517173E1	1.848303992560E1
%     8.135698310414E1	1.949381518634E1
%     8.689076374588E1	2.035113266459E1
%     9.321065568325E1	2.120698864014E1
%     9.921278150535E1	2.197047764565E1];