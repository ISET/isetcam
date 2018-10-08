function [trolands] = EffectiveTrolandsFromLum(lum,method)
% [trolands] = EffectiveTrolandsFromLum(lum,[method])
%
% Compute effective trolands for large fields from photopic
% luminance.  Based on LeGrand's work, takes Stiles-Crawford
% effect into account.
%
% Luminance is in cd/m2.
%
% Method (string):
%   PokornySmith1: (default)
%			Formula is Eq. 2 from: Pokorny and Smith, "How much light
%			reaches the retina", Colour Vision Deficiences XIII (C.
%			Cavonius, ed.), pp. 491-511.  The formula in the paper
%     has some typos, corrections provided to me by Pokorny.
%
%		PokornySmith2:
%			Formula is Eq. 3 from: Pokorny and Smith, "How much light
%			reaches the retina", Colour Vision Deficiences XIII (C.
%			Cavonius, ed.), pp. 491-511.  Conversion to and from log
%     done here so input/output is same as above.
%
% The agreement between the two methods is not spectacular.  See PupilDiameterTest.
%
% 5/8/99  dhb  Wrote it.
% 7/11/03 dhb  More general method naming. 

% Set default methods
if (nargin < 2 || isempty(method))
	method = 'PokornySmith1';
end

% Get diameter according to chosen method
switch (method)
	case {'PokornySmith1', 'Pokorny_Smith1'},
		d = PupilDiameterFromLum(lum,'Pokorny_Smith');
		trolands = (lum.*pi.*d.^2/4).*(1 - 0.085.*(d.^2/8) + 0.002.*(d.^4/48));
	case {'PokornySmith2', 'Pokorny_Smith2'},
		logLum = log10(lum);
		logTrol = 1.147 + 0.80738*logLum+0.013181*logLum.^2;	
		trolands = 10.^logTrol;
end

