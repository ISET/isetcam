function wvfOut = wvfComputeOptimizedConePSF(wvfIn)
% Optimize the PSF by the cones with sensitivities, weighting, & criterion
%
% Syntax:
%   wvfParams = wvfComputeOptimizedConePSF(wvfParams)
%
% Description:
%    Optimize the PSF seen by the cones, given the cone sensitivities, a
%    weighting spectral power distribution, and a criterion. Optimization
%    is performed on the defocus parameter. 
%
% Inputs:
%    wvfIn - The wavefront object
%
% Outputs:
%    wvfOut - The modified wavefront object
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [NOTE: DHB - This function is under development. The idea is that
%       the amount of defocus that produces the best PSF, as seen by a
%       particular cone class, is not determined trivially and is best
%       found via numerical optimization. We may never need this, and
%       certainly don't need it right now. I am moving to an
%       "underDevelopment_wavefront" directory and putting in an error
%       message at the top so that people don't think it might work.]
%    * [NOTE: JNM - The example is broken, but at least 'semi-present' now]
%    * From Jenn's notes when she worked on this in November 2017.
%      wvfComputeOptimizedConePSF:
%       - Note: Was the input/output parameter intended to be non-private?
%           I think I found the problem. wvfParams is not passed into the
%           function directly, but is called regardless.
%       - Note: How should the inlineMinFunction be addressed?
%       - Note: Example is not working! (Trying, but still struggling)
%       - Please check that all of my commentary inside the inline function
%         is accurate. I am only like 50% certain of most of it. I have
%         also neglected to include an example.
%    * [Note: JNM - defocusFound is created but not used?]
%

% History:
%    08/26/11  dhb  Wrote it.
%    08/29/11  dhb  Don't need to center or circularly average here.
%              dhb  Print warning if optimal value is at search bound.
%    09/07/11  dhb  Rename. Use wvfParams for i/o.
%	 11/14/17  jnm  Comments & formatting
%    01/18/18  jnm  Formatting update to match Wiki, move notes from my
%                    last check-in to the notes section.

% Examples:
%{
    % Compute cone weighted PSFs using default parameters for conePsfInfo.
    wvf = wvfCreate('wave',400:10:700);
    wvf = wvfComputePSF(wvf);

    % Criterion fraction
    criterionFraction = 0.5;
%}

% Set up fmincon options
options = optimset('fmincon');
options = optimset(options, 'Diagnostics', 'off', 'Display', 'off', ...
    'LargeScale', 'off', 'Algorithm', 'active-set');
%options = optimset(options, 'TypicalX', 0.1, 'DiffMinChange', 1e-3);

% Initial defocus and bounds (diopters)
diopterBound = 4;
defocusStart = 0;
vlb = -diopterBound;
vub = -vlb;

% Optimize focus
defocusFound = fmincon(@(defocus) InlineMinFunction(defocus,wvfIn,criterionFraction), defocusStart, [], [], [], [], vlb, vub, [], options);
if (abs(x) >= diopterBound)
    fprintf(['WARNING: defocus found in wvfComputeOptimizedConePSF is '...
        'at search limit of %0.1f diopters\n'], diopterBound)
end
[~, wvfOut] = InlineMinFunction(x,wvfIn);


end

%% Error function. 
%
% This returns the quantity to be minimized in the search over defocus.
function f = SearchErrorFunction(defocusDiopters,wvf,criterionFraction)

f = wvfComputeConeAverageCriterionRadius(wvf,defocusDiopters,criterionFraction);

end
