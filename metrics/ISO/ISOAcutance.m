function Acutance = ISOAcutance(cpd,lumMTF)
% ISOAcutance  Compute acutance by CSF-weighted integration of luminance MTF
%
%   Acutance = ISOAcutance(cpd, lumMTF)
%
% Inputs
%   cpd      - Vector of spatial frequencies in cycles per degree (cyc/deg).
%              Must be monotonically increasing and uniformly sampled.
%   lumMTF   - Vector of luminance MTF values at the frequencies in cpd.
%              Same length as cpd. Typical range 0..1 (but any scale is allowed;
%              result will scale accordingly).
%
% Output
%   Acutance - Scalar acutance metric computed as the normalized integral:
%              Acutance = (∫ MTF(f) * CSF(f) df) / (∫ CSF(f) df).
%              If lumMTF = 1 at all frequencies, Acutance = 1.
%
% Description and assumptions
%   The function weights the supplied luminance MTF by a contrast-sensitivity
%   weighting function returned by cpiqCSF(cpd), integrates over frequency,
%   and normalizes by the integral of the weighting function. This yields a
%   single perceptual sharpness number. The precise CSF used depends on the
%   implementation of cpiqCSF (e.g., a standard psychophysical CSF model).
%
% Notes and caveats
% - Frequency range: The integration is performed over the range covered by
%   cpd. If cpd extends beyond the optical sampling (Nyquist) frequency of
%   the sensor or system, consider limiting cpd to the Nyquist frequency to
%   avoid attributing energy to frequencies that cannot be resolved.
% - Sampling spacing: The code uses a simple Riemann sum with dv = cpd(2)-cpd(1).
%   This assumes uniform sampling. If cpd is nonuniform, compute differences
%   with diff(cpd) and use a trapezoidal or proper integration method.
% - Noise: The metric does not explicitly account for noise. In low SNR
%   conditions, MTF estimates can be biased and acutance may be overly
%   optimistic. Consider applying denoising, SNR weighting, or subtracting
%   noise bias from the MTF before integration.
% - Color: This routine uses luminance MTF only. For color-aware assessment,
%   compute acutance per color channel (or compute a perceptual luminance from
%   R,G,B) and combine according to task-specific weights.
%
% References (representative literature on CSF / perceptual weighting)
% - Campbell FW, Robson JG. "Application of Fourier analysis to the visibility
%   of gratings". The Journal of Physiology. 1968. (Classic human CSF work)
% - Barten PGJ. "Contrast Sensitivity of the Human Eye and Its Effects on Image
%   Quality". SPIE Press, 1999. (Model-based CSF and image quality)
% - ISO 12233:2017 (and predecessors) define MTF measurement procedures for
%   imaging systems (chart-based MTF); many perceptual metrics use CSF
%   weighting in combination with MTF results.
% - DxO Labs: DxO uses a proprietary acutance metric derived from MTF/CSF
%   weighting; implementations in evaluation software often follow the same
%   high-level approach (weight MTF by a CSF and normalize).
%
% Example
%   % Given cpd and measured lumMTF vectors:
%   Ac = ISOAcutance(cpd, lumMTF);
%
% Implementation details
%   The current implementation uses simple uniform-sampling Riemann sum
%   integration. If higher accuracy is desired, use trapz(cpd, lumMTF .* cpiq)
%   and trapz(cpd, cpiq) instead.
%
% See also cpiqCSF, trapz

if ieNotDefined('cpd'), error('CPD required'); end
if ieNotDefined('lumMTF'), error('Luminance MTF required'); end

% To compute acutance we multiply point by point the luminance MTF values
% (4th column of cMTF) by a standard function given (cpiq) in cyc/deg.
% Then we sum the result.
cpiq = cpiqCSF(cpd);
dv   = cpd(2) - cpd(1);
A    = sum(lumMTF .* cpiq)*dv;
Ar   = sum(cpiq)*dv;

Acutance = A/Ar;

end
