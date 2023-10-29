function [sens,fs,ft] = humanSpaceTime(model,fs,ft)
% Gateway routine to various human space-time sensitivity curves
%
%  [sens,spaceSamples,timeSamples] = humanSpaceTime(spaceVariable,timeVariable)
%  Current calculations includes
%
%   * Kelly's 1979 space time surface
%   * Watson's temporal impulse response
%   * Poirson/Wandell spatial color models
%
%  These functions are implemented in other functions and this routine
%  simply formulates the call.
%
%  The space and time variables are either in the time/space domain or
%  frequency domain, depending on the call.  See below for examples.
%
% Example:
%    [sens,fs,ft] = humanSpaceTime('kelly79',logspace(-0.2,log10(30),20),logspace(-0.2,log10(60),20));
%    surf(ft,fs,sens); set(gca,'xscale','log','yscale','log');
%    set(gca,'xlim',[0 60],'ylim',[0 30]);
%    xlabel('Temporal freq (Hz)');ylabel('Spatial freq (cpd)')
%
%    [tMTF,junk,ft] = humanSpaceTime('watsonTMTF',[],[0:60]);
%    plot(ft,tMTF,'r-o');
%
%    t = [0.001:0.002:0.200];
%    [impResp,junk,t] = humanSpaceTime('watsonImpulseResponse',[],t);
%    plot(t,impResp)
%
%    [spatialFilters,positions] = humanSpaceTime('poirsoncolor');
%    mesh(positions,positions,spatialFilters.by); xlabel('Position (deg)')
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('model'), model = 'kelly79'; end
if ieNotDefined('fs'), fs = 10 .^ [-.5:.05:1.3]; end
if ieNotDefined('ft'), ft = 10 .^ [-.5:.05:1.7]; end

sens = [];

switch(lower(model))
    case {'kelly79','kellyspacetime','kellyspacetimefrequencydomain'}
        sens = kellySpaceTime(fs,ft);
    case {'watsonimpulseresponse'}
        % In this case, ft refers to time samples.
        [sens,junk,t] = watsonImpulseResponse(ft);
    case {'watsontmtf'}
        lowestF = min(ft);         % Sample 1ms over the lowest frequency
        if lowestF == 0, period = 1; else period = 1/lowestF; end
        t = [0.001:0.001:period];   %
        fs = [];
        [a,b,tMTF,allFt] = watsonImpulseResponse(t);
        sens = interp1(allFt,tMTF,ft);
    case {'poirsoncolor','wandellpoirsoncolorspace'}
        [lum, rg, by, positions] = poirsonSpatioChromatic([],2);
        sens.lum = lum; sens.rg = rg; sens.by = by;
        fs = positions;
    otherwise
        error('Unknown model');
end

return;

