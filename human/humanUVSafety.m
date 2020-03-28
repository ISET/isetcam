function exposureMinutes = humanUVSafety(irradiance,wave)
% Calculate the UV hazard safety for an irradiance
%
% Synopsis
%  exposureMinutes = humanUVSafety(irradiance,wave)
%  
% Inputs:
%   irradiance - in energy (watts/nm/m2)
%   wave       - wavelength samples of the irradiance
%
% Returns
%   exposureMinutes - Maximum safe exposure time (minutes) per eight hour
%                    period 
%
% Description:
%
%  We caclulate for a constant light (not time-varying).
%
%  The data for the Actinic safety function curves were taken from this
%  paper
%
%    IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems. n.d.
%    Accessed October 5, 2019. https://webstore.iec.ch/publication/7076 
%    J.E. Farrell has a copy of this standard
%
% Notes:   Near UV is also called UV-A and is 315-400nm.
%
% See also
%   s_humanSafetyUVExposure

%%  Near-UV hazard exposure limit
%{
This calculation has no weighting function.  

For times less than 1000 sec, add up the total irradiance
from 315-400 without any hazard function (Equation 4.3a).  Call this E_UVA.
Multiply by time (seconds).  The product should be less than 10,000.

For times exceeding 1000 sec, add up the total irradiance, divide by the
time, and the value must be less than 10 (Equation 4.3b).

%}

%% Check inputs

if ieNotDefined('irradiance'), error('Spectral irradiance required'); end
if ieNotDefined('wave') || length(wave) ~= length(irradiance)
    error('wave representation missing or incorrect');
end

%% Load the standard function

fname = which('Actinic.mat');
Actinic = ieReadSpectra(fname,wave);
% semilogy(wave,Actinic); xlabel('Wave'); grid on; 

%% The UV hazard safety formula
%   
%    sum (Actinic(lambda,t) irradiance(Lambda)) dLambda dTime
%
% Our stimuli are constant over time, so this simplifies to
%
%    T * sum(Actinic(lambda) irradiance(lambda) dLambda
%
% where T is the total time.  For simplicty we set T = 1, so we are
% calculating the total amount of time (in minutes) for a light with this
% spectral irradiance.
%
% Follow the units this way:
%
%     Irradiance units: Watts/m2/nm
%     Watts = Joules/sec
%  
%     Watts/m2/nm * (nm * sec)         % Irradiance summed over nm and time
%     Joules/sec/m2/nm * (nm * sec)    
%     Joules/m2                        % Becomes Joules/area
%

% Summing over wavelength and time (1 sec)
if numel(wave) == 1
    dLambda = 10;
    disp('Assuming 10 nm bandwidth');
else
    dLambda  = wave(2) - wave(1);
end
hazardEnergy = (dot(Actinic,irradiance) * dLambda);

% This is the formula from the standard to compute the maximum daily
% allowable exposure from the hazard energy.  
%{
  The maximum permissible exposure time per 8 hours for ultraviolet
  radiation incident upon the unprotected eye or skin shall be computed by:

       t_max = 30/E_s   (seconds) (Equation 4.2)

  E_s is the effective ultraviolet irradiance (W/m^2).  The formula for
  E_s is defined in Equation 4.1.  It is the inner product of the Actinic
  function and the irradiance function, accounting for time and
  wavelength sampling.
%}

% We return the time in minutes.
exposureMinutes = (30/hazardEnergy)/60;

end