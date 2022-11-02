function [val, level] = humanUVSafety(energy,wave,varargin)
% Calculate the UV hazard safety for an irradiance
%
% Synopsis
%  [val, level] = humanUVSafety(irradiance,wave,varargin)
%
% Inputs:
%   energy - irradiance (skineye, eye) or radiance (bluehazard) (watts/nm/m2)
%   wave   - wavelength samples of the irradiance
%
% Optional key/val pairs
%   method -  'skineye' or 'eye' (sections 4.3.1 and 4.3.2 of the PDF)
%   duration - Stimulus duration in seconds used for 'eye' and 'bluehazard'
%              methods
%
% Return:
%
% Method: 'skineye'
%   val   - Maximum safe exposure time (minutes) per eight hour period
%   level - hazardEnergy
%
% Method: 'eye'
%    val   - logical (true/false)
%    level - the irradiance integrated over wavelength
%
% Method:  'bluehazard'
%    val   - logical (true/false)
%    level - the dot product of the radiance with the blueLightHazard
%            function.
%
% Description:
%
%  (Near UV is also called UV-A and is 315-400nm)
%
%  We caclulate for a constant light (not time-varying).
%
%  The data for the Actinic safety function curves were taken from this
%  paper
%
%    IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems. n.d.
%    Accessed October 5, 2019. https://webstore.iec.ch/publication/7076
%    J.E. Farrell has a copy of this standard and it is in ISETCam/docs
%
%  The document explains the different functions in these sections.
%
%    Actinic UV hazard exposure limit skin and eye (4.3.1)
%    Near UV hazard limit for the eye (4.3.2)
%    Retinal blue light hazard exposure (4.3.3)
%    Retinal blue light small source (4.3.4)
%    Retinal thermal hazard (4.3.5)
%    Retinal theermal hazard for weak visual stimulus (4.3.6)
%    Infrared exposure for the eye (4.3.7)
%    Thermal hazard for the skin (4.3.8)
%
% Notes
%
% I was not sure if radiance -> irradiance is multiplied by 2pi or 1pi.
% So, we checked with Peter and the Internet.  The answer:  1pi.
%
% From: Peter B. Catrysse <pcatryss@stanford.edu>
% Sent: Wednesday, August 21, 2019 11:02 AM
% To: Joyce Eileen Farrell <jefarrel@stanford.edu>
% Subject: RE: spectroradiometric measurements
%
% Hello Joyce,
%
%  It is definitely pi.
%  There is 2*pi solid angle for the hemisphere, but when you integrate
%  you end up getting pi as factor.
%
% See you next week,
%
% Peter
%
% From: Joyce Eileen Farrell [mailto:jefarrel@stanford.edu]
% Sent: Tuesday, August 20, 2019 10:58 PM
% To: Peter Bert Catrysse <pcatryss@stanford.edu>
% Subject: Re: spectroradiometric measurements
%
% Hi Peter,
%
% Thanks so very much for giving me the conversion from radiance to
% irradiance.
%
% is it
% E = pi*L/R (where E is irradiance, L is radiance and R is reflectance)
% or
% E=2pi*L/R
%
% ----
%
% See also this exchange online
%
%  https://physics.stackexchange.com/questions/116596/convert-units-for-spectral-irradiance
%
% The person multiplies b6000 by pi, not 2pi
%
% Notes
%
% This calculation is for skin and eye (4.3.1).
%
% We are calculating the irradiance, not the irradiance at the retina. We
% could try to calculate irradiance at the retina, accounting for the pupil
% diameter and the tranmissivity of the lens. But the standard's committee
% baked that into the standard itself. (page 27).
%
% A related issue is the area subtended.  In our case we are measuring
% irradiance as watts/m2, so the assumption is that any area is accounted
% for by the units, and that over the area that is illuminated by the light
% the intensity is uniform.
%
% See also
%   s_humanSafetyUVExposure, ieLuminance2Radiance
%


%% Check inputs

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('irradiance',@isvector);
p.addRequired('wave',@isvector)
p.addParameter('method','skineye',@(x)(ismember(ieParamFormat(x),{'skineye','eye','bluehazard'})));
p.addParameter('duration',1,@isnumeric);
p.parse(energy,wave,varargin{:});

method = ieParamFormat(p.Results.method);
duration = p.Results.duration;

%%  Set up wavelength sampling

if numel(wave) == 1
    dLambda = 10;
    disp('Assuming 10 nm bandwidth');
else
    dLambda  = wave(2) - wave(1);
end

%% Load the standard function
switch method
    case 'skineye'
        fname = which('Actinic.mat');
        Actinic = ieReadSpectra(fname,wave);
        % semilogy(wave,Actinic); xlabel('Wave'); grid on;
        % Notice that the actinic function only goes up to 400
        % see "4.3.1 Actinic UV hazard exposure limit for the skin and eye" in the EN6247 standard 

        %% The UV hazard safety formula
        %
        %    sum (Actinic(lambda,t) irradiance(Lambda)) dLambda dTime
        %
        % Our stimuli are constant over time, so this simplifies to
        %
        %    T * sum(Actinic(lambda) irradiance(lambda) dLambda)
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
        % This standard is defined for 200-400 nm, but we do not have any
        % data that go that short.
        
        % We only evaluate up to a wavelength limit of 400nm
        wLimit = (wave <= 400);
        hazardEnergy = (dot(Actinic(wLimit),energy(wLimit)) * dLambda);
        
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
        val = (30/hazardEnergy)/60;
        level = hazardEnergy;
        
    case 'eye'
        %% The calculation in 4.3.2 is specialized for the eye.
        % The formula they derive in that case is a maximum irradiance value that
        % is calculated separately when the eye is exposed for less than 1,000 sec
        % or more than 1,000 seconds.
        %
        % Suppose for an irradiance level that is constant over time we have
        %
        %     IR = Integral (E(lambda) dlambda) (Watts/m2)
        %
        %  where E(lambda) has units of Watts/nm/m2
        %
        %     ExpTime * IR has units of (sec * Watts/m2  = Joules/m^2)
        %
        %  Then for times less than 1000 sec, the rule is
        %
        %     ExpTime * IR  < 10,000
        %
        % For times greater than 1000 sec we require that
        %
        %     IR < 10
        %
        wLimit = (wave <= 400);
        level = dLambda * sum(energy(wLimit));
        
        % val is set to true for safe and false for not safe
        val = false;
        if duration <= 1000   % seconds
            if level*duration < 10000, val = true; end
        elseif level < 10    % Duration is long, so level must be low
            val = true;
        end

    case 'bluehazard'
        % Retinal blue light hazard, Section 4.3.3 - large spatial source
        %
        % The manual assumes you are staring at a light source so the units
        % are radiance (W/sr/m2/nm) 
        %
        % Potential for  a photochemically  induced retinal injury
        % resulting  from radiation  exposure  at  wavelengths primarily
        % between 400 nm and 500 nm. This  damage mechanism  dominates
        % over  the  thermal damage mechanism  for  times  exceeding 10
        % seconds. (Page 15).
        %
        % The standard applies over the wavelength range from 300-700 nm.
        %
        fname = which('blueLightHazard.mat');
        blueHazard = ieReadSpectra(fname,wave);
        % ieNewGraphWin; semilogy(wave,blueHazard)
        % Notice that this function is defined beyond 400 nm so it takes
        % into account the effect of visible and NIR light
        
        % Calculate the level of the energy w.r.t. the blueHazard curve
        level = dLambda*dot(blueHazard,energy);

        % Equations 4.5a, 4.5b
        % Determine if the level times the duration is safe or not
        % Returns val as true for safe, and false for not safe.

        if duration <= 1e4  && level*duration < 1e6 % seconds
            val = true;  % Eqn 4.5a
        elseif duration > 1e4 && level < 100
            val = true; % Eqn 4.5b
        else
            val = false;
        end

        % The max exposure time is given by Eqn 4.6 when level > 100
        if level > 100  && duration <= 1e4
            fprintf('Max permissible exposure time in min %f (for durations < 1e4 s)',100/level/60);
        elseif level > 100 && duration > 1e4
            fprintf('Level > 100 and duration long.  Standard says it is dangerous.')
        else
            %level < 100.   Maybe any amount of time is OK
            fprintf('The level is less than 100 and the standard says it is safe.')
        end

        fprintf('')
    case 'bluehazardsmall'
        % For an angle < 0.011 radians, which 0.63 deg
        %
        % See Section 4.3.4 if you want to implement this case.  It
        % requires converting the source to the irradiance as explained in
        % the standards document.  May be simple to do.
    case 'thermalhazardeye'
        % uses a burn hazard function that we would need to enter
        % See Section 4.3.5
        % there is also another specification for retinal thermal hazard
        % for weak stimuli that do not active an aversion response (i.e. we
        % do not turn our eyes away) 
    case 'infraredhazardeye'
        % 4.3.7
    case 'thermalhazardskin'
        % See Section 4.3.8
        % "This exposure limit is based on skin injury due to a 
        % rise in tissue temperature and applies only to small area irradiation."
    otherwise
        error('Unknown UV safety method %s\n',method);
end

end