function Acutance = ISOAcutance(cpd, lumMTF)
% Compute Acutance as per the DxO method (is it the ISO method, too?)
%
%  Acutance = ISOAcutance(cpd,lumMTF)
%
% See the DxO documentation for the description of this calculation.
%
% This is some kind of a standard.  (Why do we integrate beyond the
% Nyquist? What about accounting for noise? How do we deal with color
% variations?)
%
% Example:
%
% Copyright Imageval, LLC 2012

if ieNotDefined('cpd'), error('CPD required'); end
if ieNotDefined('lumMTF'), error('Luminance MTF required'); end

% To compute acutance we multiply point by point the luminance MTF values
% (4th column of cMTF) by a standard function given (cpiq) in cyc/deg.
% Then we sum the result.
cpiq = cpiqCSF(cpd);
dv = cpd(2) - cpd(1);
A = sum(lumMTF.*cpiq) * dv;
Ar   = sum(cpiq)*dv;

Acutance = A / Ar;

return
