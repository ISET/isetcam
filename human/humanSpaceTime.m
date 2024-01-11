function [sens, fs, ft] = humanSpaceTime(model, fs, ft)
% Gateway routine to various human space-time sensitivity curves
%
% Syntax:
%   [sens, spaceSamples, timeSamples] = ...
%       humanSpaceTime(model, spaceVariable, timeVariable)
%
% Description:
%    The gateway routine to the various human space-time sensitivity
%    curves, which include the following current calculations.
%
%      * Kelly's 1979 space time surface
%      * Watson's temporal impulse response
%      * Poirson/Wandell spatial color models
%
%    These functions are implemented in other functions and this routine
%    simply formulates the call.
%
%    The space and time variables are either in the time/space domain or
%    frequency domain, depending on the call.  See below for examples.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanSpaceTime.m' into the Command Window.
%
% Inputs:
%    model - (Optional) String. The human space-time model. Default is
%            'kelly79'. Options, with spaces and cases added for
%            readability, include: 'Kelly 79', 'Watson Impulse Response',
%            'Watson MTF', and 'Poirson Color'
%    fs    - (Optional) Vector. A vector for space. The default values are
%            10 .^ (-.5:.05:1.3).
%    ft    - (Optional) Vector. A vector for time. The default values are
%            10 .^ (-.5:.05:1.7).
%
% Outputs:
%    sens  - Varies. Sens is most often a matrix, with matrix dimensions
%            dependent on the model input, however, in the poirsonColor
%            case, sens will be a struct.
%    fs    - Vector. Space samples (default if not provided), can be empty.
%    ft    - Vector. Time samples (default if not provided).
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/27/18  jnm  Formatting, convert example format, comment broken ex.

% Examples:
%{
    [sens, fs, ft] = humanSpaceTime('kelly79', ...
        logspace(-0.2, log10(30), 20), logspace(-0.2, log10(60), 20));
    surf(ft, fs, sens);
    set(gca, 'xscale', 'log', 'yscale', 'log');
    set(gca, 'xlim', [0 60], 'ylim', [0 30]);
    xlabel('Temporal freq (Hz)');
    ylabel('Spatial freq (cpd)')
%}
%{
    [tMTF, junk, ft] = humanSpaceTime('watsonTMTF', [], [0:60]);
    plot(ft, tMTF, 'r-o');
%}
%{
    t = [0.001:0.002:0.200];
    [impResp, junk, t] = humanSpaceTime('watsonImpulseResponse', [], t);
    plot(t, impResp)
%}
%{
    [spatialFilters, positions] = humanSpaceTime('poirsoncolor');
    mesh(positions, positions, spatialFilters.by);
    xlabel('Position (deg)')
%}

if notDefined('model'), model = 'kelly79'; end
if notDefined('fs'), fs = 10 .^ (-.5:.05:1.3); end
if notDefined('ft'), ft = 10 .^ (-.5:.05:1.7); end

sens = [];

switch(lower(model))
    case {'kelly79', 'kellyspacetime', 'kellyspacetimefrequencydomain'}
        sens = kellySpaceTime(fs, ft);
    case {'watsonimpulseresponse'}
        % In this case, ft refers to time samples.
        [sens, ~, ~] = watsonImpulseResponse(ft);
    case {'watsontmtf'}
        lowestF = min(ft);  % Sample 1ms over the lowest frequency
        if lowestF == 0, period = 1; else, period = 1 / lowestF; end
        t = 0.001:0.001:period;
        fs = [];
        [~, ~, tMTF, allFt] = watsonImpulseResponse(t);
        sens = interp1(allFt, tMTF, ft);
    case {'poirsoncolor', 'wandellpoirsoncolorspace'}
        [lum, rg, by, positions] = poirsonSpatioChromatic([], 2);
        sens.lum = lum;
        sens.rg = rg;
        sens.by = by;
        fs = positions;
    otherwise
        error('Unknown model');
end

end