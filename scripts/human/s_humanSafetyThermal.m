%% s_humanSafetyBlueLight
%
% Calculate the safety of blue lights for exposure to the eye and to skin.
%
% The safety function curves used in these calculations are stored in
% data/human/safetyStandard.
%
%   burnHazard      - Retinal thermal injury (4.3.5 and 4.3.6)
%
% There are two other types of safety calculations that we include in
% related scripts
%
%   Actinic         - UV hazard for skin and eye safety The limits for
%                     exposure to ultraviolet radiation incident upon the
%                     unprotected skin or eye (4.3.1 and 4.3.2)
%
%   blueLightHazard - Eye (retinal) safety (retinal photochemical injury
%                     from chronic blue-light exposure).  There are
%                     different functions for large and small field lights
%                     (4.3.3 and 4.3.4)
%
% The data for the safety function curves were taken from this paper
%
%  ?IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems.? n.d.
%  Accessed October 5, 2019. https://webstore.iec.ch/publication/7076
%  J.E. Farrell has a copy of this standard
%
% Notes:   Near UV is also called UV-A and is 315-400nm.
%
% Calculations
%  We load in a radiance (Watts/sr/nm/m2), convert it to irradiance
%
%      Irradiance = Radiance * pi
%
% This was used for the Oral Eye project, but we can not expect that the
% repository will always be on the path.  So for this test we commented out
% that part of the script
%
% See also
%   Oral eye project

%%
%{
% Plot the three different functions and explain them here
% Make sure the formulae for hazards are implemented for

Actinic UV hazard exposure limit skin and eye (4.3.1)
Near UV hazard limit for the eye (4.3.2)
    Retinal blue light hazard exposure (4.3.3)
    Retinal blue light small source (4.3.4)
    Retinal thermal hazard (4.3.5)
    Retinal theermal hazard for weak visual stimulus (4.3.6)
        Infrared exposure for the eye (4.3.7)
            Thermal hazard for the skin (4.3.8)
                %}

                %{
                We checked two ways if radiance -> irradiance is multiplied by 2pi or 1pi

                    From: Peter B. Catrysse <pcatryss@stanford.edu>
                    Sent: Wednesday, August 21, 2019 11:02 AM
                    To: Joyce Eileen Farrell <jefarrel@stanford.edu>
                    Subject: RE: spectroradiometric measurements

                    Hello Joyce,

                    It is definitely pi.
                    There is 2*pi solid angle for the hemisphere, but when you integrate
                        you end up getting pi as factor.

                    See you next week,

                    Peter

                    From: Joyce Eileen Farrell [mailto:jefarrel@stanford.edu]
                    Sent: Tuesday, August 20, 2019 10:58 PM
                    To: Peter Bert Catrysse <pcatryss@stanford.edu>
                    Subject: Re: spectroradiometric measurements

                    Hi Peter,

                    Thanks so very much for giving me the conversion from radiance to
                        irradiance.

                        is it
                        E = pi*L/R (where E is irradiance, L is radiance and R is reflectance)
                        or
                        E=2pi*L/R

                        See also this exchange

                        https://physics.stackexchange.com/questions/116596/convert-units-for-spectral-irradiance

                        The person multiplies b6000 by pi, not 2pi

                        %}

                        %%  Create a radiance and convert it to irradiance

                        wave = 300:700;
                        radiance = blackbody(wave, 3000);
                        irradiance = radiance * pi;

                        % ieNewGraphWin; plot(wave,irradiance);

                        %%  Load the safety function

                        fname = which('Actinic.mat');
                        Actinic = ieReadSpectra(fname, wave);

                        % The formula is
                        %
                        %    sum (Actinic(lambda,t) irradiance(Lambda)) dLambda dTime
                        %
                        % Our stimuli are constant over time, so this simplifies to
                        %
                        %    T * sum(Actinic(lambda) irradiance(lambda) dLambda
                        %
                        % where T is the total time.  Follow the units this way:
                        %
                        %     Irradiance units: Watts/m2/nm
                        %     Watts = Joules/sec
                        %
                        %     Watts/m2/nm * (nm * sec)         % Irradiance summed over nm and time
                        %     Joules/sec/m2/nm * (nm * sec)
                        %     Joules/m2                        % Becomes Joules/area
                        %
                        dLambda = wave(2) - wave(1);
                        duration = 1; % Seconds
                        hazardEnergy = dot(Actinic, irradiance) * dLambda * duration;

                        % This is the formula from the standard to compute the maximum daily
                        % allowable exposure
                        fprintf('Maximum exposure duration per eight hours:  %f (min)\n', (30 / hazardEnergy)/60)

                        %% An example of a light measured in the lab

                        fname = fullfile(isetRootPath, 'local', 'blueLedlight30.mat');
                        load(fname, 'wave', 'radiance');
                        radiance = mean(radiance, 2);
                        irradiance = pi * radiance;

                        fname = which('Actinic.mat');
                        Actinic = ieReadSpectra(fname, wave);
                        dLambda = wave(2) - wave(1);
                        duration = 1; % Seconds
                        hazardEnergy = dot(Actinic, irradiance) * dLambda * duration;
                        %{
                        The maximum permissible exposure time per 8 hours for ultraviolet radiation
                            incident upon the unprotected eye or skin shall be computed by:

                            t_max = 30/E_s   (seconds) (Equation 4.2)

                            E_s is the effective ultraviolet irradiance (W/m^2).  The formula for E_s
                                is defined in Equation 4.1.  It is the inner product of the Actinic
                                    function and the irradiance function, accounting for time and wavelength
                                                sampling.

                                                %}
                                                fprintf('Maximum exposure duration per eight hours:  %f (min)\n', (30 / hazardEnergy)/60)

                                                %% An example of the 385nm light in the OralEye camera

                                                %{
                                                fname = fullfile(oreyeRootPath,'data','lights','OralEyeBlueLight.mat');
                                                load(fname,'wave','radiance');
                                                radiance = mean(radiance,2);
                                                irradiance = pi*radiance;

                                                fname = which('Actinic.mat');
                                                Actinic = ieReadSpectra(fname,wave);
                                                dLambda  = wave(2) - wave(1);
                                                duration = 1;                  % Seconds
                                                hazardEnergy = dot(Actinic,irradiance) * dLambda * duration;
                                                fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60)
                                                %}

                                                %% Start with a monochromatic light luminance

                                                % Suppose we know the luminance of a 380 nm light with a 10 nm sd width
                                                lum = 10;
                                                thisWave = 380;
                                                dLambda = 10;

                                                % We convert the luminance to energy
                                                radiance = ieLuminance2Radiance(lum, thisWave, 'wave', wave, 'sd', dLambda); % watts/sr/nm/m2

                                                % Now read the hazard function (Actinic)
                                                Actinic = ieReadSpectra(fname, wave);

                                                % Convert radiance to irradiance and calculate the hazard for 1 sec
                                                % duration
                                                duration = 1; % Seconds
                                                hazardEnergy = dot(Actinic, radiance*pi) * dLambda * duration;

                                                % Conver the hazard energy into maximum daily allowable exposure in minutes
                                                fprintf('Maximum exposure duration per eight hours:  %f (min)\n', (30 / hazardEnergy)/60)

                                                %%  Plot the Actinic hazard function

                                                ieNewGraphWin;
                                                mx = max(irradiance(:));
                                                dummy = ieScale(Actinic, 1) * mx;
                                                plot(wave, irradiance, 'k-', wave, dummy, 'r--', 'linewidth', 2);
                                                xlabel('Wave (nm)');
                                                ylabel('Irradiance (watts/m^2');
                                                grid on
                                                legend({'Irradiance', 'Normalized hazard'});

                                                %%  Near-UV hazard exposure limit
                                                %{
                                                This calculation has no weighting function.

                                                For times less than 1000 sec, add up the total irradiance
                                                from 315-400 without any hazard function (Equation 4.3a).  Call this E_UVA.
                                                    Multiply by time (seconds).  The product should be less than 10,000.

                                                    For times exceeding 1000 sec, add up the total irradiance, divide by the
                                                    time, and the value must be less than 10 (Equation 4.3b).
                                                    %}
