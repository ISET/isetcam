function [T_quantalAbsorptionsNormalized,T_quantalAbsorptions,T_quantalIsomerizations,adjIndDiffParams] = ComputeRawConeFundamentals(params,staticParams)
% [T_quantalAbsorptionsNormalized,T_quantalAbsorptions,T_quantalIsomerizations,adjIndDiffParams] = ComputeRawConeFundamentals(params,staticParams)
%
% Function to compute normalized cone quantal sensitivities from underlying
% pieces and parameters.
%
% Note that this routine returns quantal sensitivities.  You may want
% energy sensitivities.  In that case, use EnergyToQuanta to convert
%   T_energy = EnergyToQuanta(S,T_quantal')'
% and then renormalize.  (You call EnergyToQuanta because you're converting
% sensitivities, which go the opposite direction from spectra.)
%
% The routine also returns two types of quantal sensitivity functions.  The
% first gives the probability that a photon will be absorbed.  These are
% returned in variable T_quantalAbsorptionsNormalized adn
% T_quantalAbsoprions, with the first being normalized. The second is the
% probability that the photon will cause a photopigment isomerization. This
% is returned in T_quantalIsomerizations.
%
% It is T_quantalIsomerizations that you want to use to compute
% isomerization rates from retinal illuminance. See note at the end of
% function FillInPhotoreceptors for some information about conventions.  In
% particular, this routine takes pre-retinal absorption into account in its
% computation of probability of absorptions and isomerizations, so that the
% relevant retinal illuminance is one computed without accounting for those
% factors.  This routine does not account for light attenuation due to the
% pupil, however.  The only use of pupil size here is becuase of its slight
% effect on lens density as accounted for in the CIE standard.  Nor does it
% account for the collecting area of a photoreceptor, for cones the inner
% segment diameter.
%
% In the passed params structure, you can either pass the lambdaMax values
% for the photopigment, in which case the absorbance is computed from the
% specified nomogram, or you can pass the absorbance values directly in
% T_xxx format.  A typical choice in this case would be
% 10.^T_log10coneabsorbance_ss for the Stockman-Sharpe/CIE estimates.
%
% The typical use of this function is to be called by
% ComputeCIEConeFundamentals, which sets up the passed structures acording
% to the CIE standard. This routine, however, could in principle be used
% with a wide variety of choices of the component pieces.
%
% The other place this function is used is in attempts to fit a set of cone
% fundamentals by doing parameter search over the pieces.  It is this
% second use that led to the parameters being split over two separate
% structures, one that is held static during the fit and the other which
% contains the parameters that could be searched over by a calling routine.
% For examples, see:
%   FitConeFundamentalsWithNomogram, FitConeFundamentalsTest.
% Looking around today (8/10/13), I (DHB) don't see any examples where this
% routine is called directly.  Rather, it is a subfunction called by
% ComputeCIEConeFundamentals.  The search routines above use
% ComputeCIEConeFundamentals, and only search over lambdaMax values.  I
% think I wrote this with the thought that I might one day search over more
% parameters, but lost motivation to carry it throught.
%
% The computations done here are very similar to those done in routine
% FillInPhotoreceptors.  I (DHB) think that I forgot about what
% FillInPhotoreceptors could do when I wrote this, which has led to some
% redundancy. FillInPhotoreceptors returns a field called
% effectiveAbsorptance, which are the actual quantal efficiencies (not
% normalized) referred to the cornea.  FillInPhotoceptors also computes a
% field isomerizationAbsorptance, which takes the quantal efficiency of
% isomerizations (probability of an isomerization given an absorption into
% acount.
%
% It would probably be clever to unify the two sets of routines a little
% more, but we may never get to it.  The routine ComputeCIEConeFundamentals
% does contain a check that this routine and what is returned by
% FillInPhotoreceptors agree with each other, for cases where the
% parameters match.
%
% See ComputeCIEConeFundamentals for the breakdown of how the Asano et al.
% (2016) individual differences model is specified in params.indDiffParams.
%
% See ComputeCIEConeFundamentals for documentation of the adjIndDiffParams
% output argument.
%
% See also: ComputeCIEConeFundamentals, CIEConeFundamentalsTest,
% FitConeFundamentalsWithNomogram,
%           FitConeFundamentalsTest, DefaultPhotoreceptors,
%           FillInPhotoreceptors.
%
% 8/12/11  dhb  Starting to make this actually work.
% 8/14/11  dhb  Change name, expand comments.
% 8/10/13  dhb  Expand comments.  Return unscaled quantal efficiencies too.
% 2/26/16  dhb, ms  Add in Asano et al. (2016) individual observer adjustments
% 3/30/17  ms   Added output argument returning adjusted ind differences

% Handle bad value
index = find(params.axialDensity <= 0.0001);
if (~isempty(index))
    params.axialDensity(index) = 0.0001;
end

% Figure out how many receptor classes we're handling
if (isfield(params,'absorbance'))
    nReceptorTypes = size(params.absorbance,1);
else
    nReceptorTypes = length(params.lambdaMax);
end

% Fill in null individual differences parameters if they are not passed
if isempty(params.indDiffParams)
    params.indDiffParams.lambdaMaxShift = zeros(nReceptorTypes,1);
    params.indDiffParams.shiftType = 'linear';
    params.indDiffParams.dlens = 0;
    params.indDiffParams.dmac = 0;
    params.indDiffParams.dphotopigment = zeros(nReceptorTypes,1);
end

% Handle optional values for lens and macular pigment density
% in the parameters structure.  There are two mutually exclusive
% ways to do this.  For historical reasons, we can pass an additive
% density adjustment.  More recently we implemented the Asano et al. (2016)
% parameterization.  We don't allow both to happen at once.
%
% The logic here is a little hairy, because the way that we used to
% adjust lens and mac density was additive, but Asano et al. (2016) do
% it in a multipilcative fashion, so we need a flag to keep track of what
% we're going to do with the numbers down below.
if (~isfield(params,'extraLens'))
    params.extraLens = 0;
end
if (~isfield(params,'extraMac'))
    params.extraMac = 0;
end
if (params.extraLens ~= 0 & params.indDiffParams.dlens ~= 0)
    error('Cannot specify lens density adjustment two ways');
end
if (params.extraMac ~= 0 & params.indDiffParams.dmac ~= 0)
    error('Cannot specify macular pigment density adjustment two ways');
end
OLDLENSWAY = true;
if (params.extraLens == 0)
    OLDLENSWAY = false;
    params.extraLens = params.indDiffParams.dlens/100;
end
OLDMACWAY = true;
if (params.extraMac == 0)
    OLDMACWAY = false;
    params.extraMac = params.indDiffParams.dmac/100;
end

% Prereceptor transmittance.  Check that passed parameters are not so weird
% as to lead to transmittances greater than 1, and throw error if so.
if (OLDLENSWAY)
    fprintf('Using old way of adjusting lens density.  Consider switching to newer implementation via the params.indDiffParams field\n');
    lens = 10.^-(-log10(staticParams.lensTransmittance)+params.extraLens);
else
    lens = 10.^-(-log10(staticParams.lensTransmittance) * (1 + params.extraLens));
end
if (any(lens > 1))
    error('You have passed parameters that make lens transmittance greater than 1');
end
%lens(lens > 1) = 1;
adjIndDiffParams.lens = lens;

if (OLDMACWAY)
    fprintf('Using old way of adjusting macular pigment density.  Consider switching to newer implementation via the params.indDiffParams field\n');
    mac = 10.^-(-log10(staticParams.macularTransmittance)+params.extraMac);
else
    mac = 10.^-(-log10(staticParams.macularTransmittance) * (1 + params.extraMac));
end
if (any(mac > 1))
    error('You have passed parameters that make macular pigment transmittance greater than 1');
end
adjIndDiffParams.mac = mac;
%mac(mac > 1) = 1;

% Compute nomogram if absorbance wasn't passed directly.  We detect
% a direct pass by the existance of params.absorbance.
if (isfield(params,'absorbance'))
    absorbance = params.absorbance;
else
    absorbance = PhotopigmentNomogram(staticParams.S,params.lambdaMax,staticParams.whichNomogram);
end

% Shift absorbance, if desired
if (~isempty(params.indDiffParams.lambdaMaxShift))
    if (length(params.indDiffParams.lambdaMaxShift) ~= size(absorbance,1))
        error('Length of passed lambdaMaxShift does not match number of absorbances available to shift');
    end
    
    absorbance = ShiftPhotopigmentAbsorbance(staticParams.S,absorbance,params.indDiffParams.lambdaMaxShift,params.indDiffParams.shiftType);
end

% Compute absorptance
%
% Handle special case where we deal with ser/ala polymorphism for L cone
%
% We've put in the Asano et al. (2016) multiplicative adjustment.  Since we
% weren't adjusting photopigment density previously (except for
% self-screening), we don't have to deal with two threads here.
%
% Note that density can also get adjusted according to light level to
% account for photopigment bleaching.  That happens in
% FillInPhotoreceptors, which would typically be called before we get here.
% We think this is OK, because both the Asano et al. and the fraction
% bleaching adjustment are multiplicative adjustments of axial density, and
% multiplication commutes so it doesn't matter what order we do things in.
if (size(absorbance,1) == 4)
    if (any(params.indDiffParams.dphotopigment ~= 0))
        error('Cannot use Asano et al. individual cone model with our weird 4 cone calling mode');
    end
    absorptance = AbsorbanceToAbsorptance(absorbance,staticParams.S,...
        [params.axialDensity(1) ; params.axialDensity(1) ; ...
        params.axialDensity(2) ; params.axialDensity(3)]);
elseif (size(absorbance,1) == 3)
    if (length(params.indDiffParams.dphotopigment) ~= 3)
        error('Density adjustment parameter length not right for cones');
    end
    LDensity = params.axialDensity(1) * (1 + params.indDiffParams.dphotopigment(1)/100);
    MDensity = params.axialDensity(2) * (1 + params.indDiffParams.dphotopigment(2)/100);
    SDensity = params.axialDensity(3) * (1 + params.indDiffParams.dphotopigment(3)/100);
    absorptance = AbsorbanceToAbsorptance(absorbance,staticParams.S,[LDensity ; MDensity ; SDensity]);
    adjIndDiffParams.dphotopigment = [LDensity MDensity SDensity];
elseif (size(absorbance,1) == 1 && params.DORODS)
    if (length(params.indDiffParams.dphotopigment) ~= 1)
        error('Density adjustment parameter length not right for rods');
    end
    RodDensity = params.axialDensity(1) + params.indDiffParams.dphotopigment(1)/100;
    absorptance = AbsorbanceToAbsorptance(absorbance,staticParams.S,RodDensity);
    adjIndDiffParams.dphotopigment = RodDensity;
else
    error('Unexpected number of photopigment lambda max values passed');
end

%% Put together pre-receptor and receptor parts
for i = 1:size(absorptance,1)
    absorptance(i,:) = absorptance(i,:) .* lens .* mac;
end

%% Put it into the right form
if (size(absorptance,1) == 4)
    T_quantalAbsorptions = zeros(3,staticParams.S(3));
    T_quantalAbsorptions(1,:) = staticParams.LserWeight*absorptance(1,:) + ...
        (1-staticParams.LserWeight)*absorptance(2,:);
    T_quantalAbsorptions(2,:) = absorptance(3,:);
    T_quantalAbsorptions(3,:) = absorptance(4,:);
elseif (size(absorptance,1) == 3)
    T_quantalAbsorptions = zeros(3,staticParams.S(3));
    T_quantalAbsorptions(1,:) = absorptance(1,:);
    T_quantalAbsorptions(2,:) = absorptance(2,:);
    T_quantalAbsorptions(3,:) = absorptance(3,:);
elseif (size(absorptance,1) == 1 && params.DORODS)
    T_quantalAbsorptions = zeros(1,staticParams.S(3));
    T_quantalAbsorptions(1,:) = absorptance(1,:);
else
    error('Unexpected number of photopigment lambda max values passed');
end

%% Normalize to max of one for each receptor, and also compute isomerization quantal efficiency.
for i = 1:size(T_quantalAbsorptions,1)
    T_quantalIsomerizations = T_quantalAbsorptions*staticParams.quantalEfficiency(i);
    T_quantalAbsorptionsNormalized(i,:) = T_quantalAbsorptions(i,:)/max(T_quantalAbsorptions(i,:));
end
