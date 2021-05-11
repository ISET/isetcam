function [responsivity, sFactor] = ieResponsivityConvert(responsivity, wave, method);
% Convert sensory responsivity in photons to energy, or in energy to photons
%
%  [responsivity,sFactor] = ieResponsivityConvert(responsivity, wave,[method='e2q']);
%
%   When calculating a sensor responsivity, it is essential to specify
%   whether the input is in units of photons or energy. In a digital
%   imager, for example, each photon has a probability of producing an
%   electron.  Different wavelengths must account for the number of
%   photons, even if the data are expressed in units of energy.
%
%   ISET uses photons as the basis for nearly all response calculations.
%
%   But some important sensors are defined with respect to signal energy.
%   The most important of these are the XYZ sensors. These are specified
%   with respect to energy. It is also the case the the human cone
%   responses are specified with respect to energy units.
%
%   In some cases in the code, we convert the input signal in photons to
%   energy and use the standard XYZ values.
%
%   In other cases, however, we have many inputs and it is easier to
%   convert the specification of the XYZ functions into a form that is
%   correct for photon inputs.  This function performs that conversion.
%
%   Suppose transQ, transE are responsivity measured with respect to quanta
%   and energy. Suppose that E2Q is the conversion from energy to quanta as
%   a function of wavelength.  Finally, suppose inE and inQ are input
%   signals in energy and quanta units.
%
%      response = transE'*inE = (transE'*(1/E2Q)) * (E2Q*inE) = transQ'*inQ
%
%    We can see that transQ is related to transE as transQ' = transE' * (1/E2Q).
%
%   This routine converts responsivities measured in energy units (respE) to
%   responsivities appropriate for photons calculations (respQ).
%
%   These issues are handled explicitly in ieLuminanceFromEnergy,
%   ieLuminanceFromPhotons and ieXYZFromEnergy
%
%   To specify filter transmissivities, it is not necessary to pay attention
%   to the input signal units (photons or energy).  Filters transmit a
%   fraction of the photons and they transmit the same fraction of the
%   energy.
%
%   The color responsivities are in the columns of RESPONSIVITY.
%   WAVE is the wavelength in nanometers.
%   If METHOD = 'e2q' this routine converts filters specified for energy to
%   work with photons (quanta).  if method = 'q2e' this routine converts
%   filters for quanta to work with energy.
%
% Example:
%       signalPhotons = signalSPD;                               % Signal in photon units
%       signalEnergy = Quanta2Energy(wave,signalPhotons');       % Signal in energy units
%       conesE = humanCones('stockmanAbs',wave);
%       [conesP,sFactor] = ieFilterConvert(conesE,wave,'e2q');
%       % These two calculations produce equal results
%       vP = conesP'*signalPhotons(:)
%       vE = conesE'*signalEnergy(:)
%
% See also:  ieLuminanceFromEnergy,
% ieLuminanceFromPhotons,ieXYZFromEnergy.
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('responsivity'), error('Must define color responsivity functions'); end
if ieNotDefined('wave'), error('Must define wavelength in nanometers'); end
if ieNotDefined('method'), method = 'e2q'; end

if length(wave) ~= size(responsivity, 1)
    error('Mis-match between wavelength and color filters.');
end

maxTrans = max(responsivity(:));
switch lower(method)
    case {'e2q', 'energy2quanta', 'e2p', 'energy2photons'}
        % Set up filters that handle energy to handle quanta
        sFactor = Quanta2Energy(wave(:), ones(1, length(wave)));
        responsivity = diag(sFactor) * responsivity;
    case {'q2e', 'quanta2energy', 'p2e', 'photons2energy'}
        % Set up filters that handle energy to handle quanta
        sFactor = Energy2Quanta(wave(:), ones(1, length(wave))');
        responsivity = diag(sFactor) * responsivity;
    otherwise
        error('Unknown method');
end

% The throughput at max should be the same
responsivity = responsivity * (maxTrans / (max(responsivity(:))));

return;