function csf = cpiqCSF(v)
% cpiqCSF  Contrast Sensitivity Function used for CPIQ acutance weighting
%
%   csf = cpiqCSF(v)
%
% Inputs
%   v   - Vector (or scalar) of spatial frequencies in cycles per degree (cpd).
%         Values must be nonnegative. Can be nonuniformly spaced.
%
% Output
%   csf - Vector of same size as v giving relative sensitivity (unitless).
%         The function is normalized so its maximum value is 1.
%
% Description
%   This routine implements a parametric CSF used in CPIQ-style acutance
%   calculations. The model is
%       csf_raw(v) = a * v.^c .* exp(-b * v) / K
%   and the result is normalized so that max(csf) == 1. The numeric
%   parameters in this implementation are:
%       a = 75; b = 0.2; c = 0.8; K = 34.05;
%
%   The shape is a bandpass-like curve: sensitivity rises at low frequencies
%   (v^c term) and falls at higher frequencies (exp(-b v) term). The final
%   normalization makes the function a relative weighting suitable for
%   perceptual integration (for example, multiplying an MTF and integrating).
%
% Notes and recommendations
% - Units: v must be cycles per degree. If you have cycles per mm or cycles
%   per pixel, convert to cpd before using this function.
% - Normalization: The built-in normalization is convenient for relative
%   weighting (e.g., producing acutance in the range 0..1). If you need the
%   absolute, unnormalized model, comment out the final normalization step.
% - Input validation: The function assumes nonnegative v values. Negative
%   inputs are not physically meaningful for spatial frequency and should be
%   avoided.
% - Sampling: If you will integrate csf(v) numerically over v, use the same
%   sampling (or interpolate) as the MTF to avoid aliasing errors.
%
% Example
%   v = 0.5:0.5:30;
%   csf = cpiqCSF(v);
%   vcNewGraphWin; plot(v,csf);
%   xlabel('Freq (cpd)'); ylabel('Relative sensitivity');
%
% References (representative literature on CSF modeling and perceptual weighting)
% - Campbell FW, Robson JG. "Application of Fourier analysis to the visibility
%   of gratings". The Journal of Physiology. 1968.
% - Mannos JS, Sakrison DJ. "The Effects of a Visual Fidelity Criterion on the
%   Encoding of Images". (Often cited for CSF used in JPEG quantization).
% - Barten PGJ. "Contrast Sensitivity of the Human Eye and Its Effects on
%   Image Quality". SPIE Press, 1999.
% - CPIQ / imaging quality literature: consumer photography image-quality
%   work uses similar CSF-shaped weightings for perceptual metrics such as
%   acutance (implementation details may be proprietary).
%
% Implementation notes
% - The implementation below follows the simple parametric form above and
%   then normalizes by the maximum value. This normalization is consistent
%   with practical weighting of MTFs where only relative sensitivity matters.
%
% See also ISOAcutance
%
% Copyright ImagEval Consultants, LLC, 2005

% The parameters here were chosen in the distant past.  The are fit to
% a CSF model someone liked.  Not sure who.
%
% If you have another CSF you would like to use as a model, you can
% find alternative parameters this way:
%{

% Data: 
% v_ref, csf_ref are sample points from a published model/data (cpd)

model = @(p,v) (p(1) * v.^p(3) .* exp(-p(2)*v) / p(4));
resid = @(p) model(p, v_ref) - csf_ref;
p0 = [75, 0.2, 0.8, 34.05];
p = lsqnonlin(resid, p0);    % requires Optimization Toolbox

% Then normalize if desired: csf = model(p,v) / max(model(p,v)); as in
% the code below.

%}

a = 75;
b = 0.2;
c = 0.8;
K = 34.05;

csf = a * (v.^c) .* exp(-b*v) / K;

% Normalize to 1.  The normalization is irrelevant for the acutance
% calculation.
csf = csf/max(csf(:));

end

