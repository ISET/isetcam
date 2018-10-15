function spectralRadiance = illuminantRead(illP,lightName)
%Return spectral radiance of a standard illuminants in energy units
%
%    spectralRadiance = illuminantRead(illP,lightName)
% 
% The illuminant parameters (illP) are stored in the structure illP. See
% the example below for how to initialize the values of this structure.
% The illP structure is idiosyncratic and used only here.  
% 
% If you don't wish to establish illP, but only to get a default SPD for
% some named illuminant, you can use the format
%
%     illuminantRead([],'d65')
%
% In this case the spectral radiance is returned at 400:10:700 nm samples
% and the mean luminance is 100 cd/m2.
%
% The standard illuminant names are:
%
%     {'tungsten'}
%     {'illuminantc'}
%     {'d50'}
%     {'fluorescent'}
%     {'d65','D65'}
%     {'equalenergy'}
%     {'blackbody'}   -- You must specify a color temperature in
%                        illP.temperature
%     {'555nm'}
%
% See also: illuminantCreate, illuminantGet/Set
%
% Examples:
%   illuminantRead([],'d65')
%   illSPD = illuminantRead([],'tungsten'); plot(400:10:700,illSPD)
%
%   illP.name = 'd65';illP.spectrum.wave = 400:10:700;illP.luminance = 100;
%   plot(illuminantRead(illP));
%
%   illP.name = 'blackbody';
%   illP.temperature = 3000;
%   illP.spectrum.wave = 400:10:700;
%   illP.luminance = 100;
%   sr = illuminantRead(illP);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('illP')
    if ieNotDefined('lightName')
        name = 'd65';
        warndlg('No illuminant name.  Assuming D65');
    else, name =  lightName;
    end
    luminance = 100;
    wave = 400:10:700;
else
    name      = illP.name;
    luminance = illP.luminance; 
    wave      = illP.spectrum.wave;
end

name = ieParamFormat(name);
baseDir = fullfile(isetRootPath,'data','lights');
switch lower(name)
    case {'tungsten'}
        thisLight = fullfile(baseDir,'Tungsten');
        SPD = ieReadSpectra(thisLight,wave);
    case {'illuminantc'}
        thisLight = fullfile(baseDir,'illuminantC');
        SPD = ieReadSpectra(thisLight,wave);
    case {'d50'}
        thisLight = fullfile(baseDir,'D50');        
        SPD = ieReadSpectra(thisLight,wave);
    case {'fluorescent'}
        thisLight = fullfile(baseDir,'Fluorescent');
        SPD = ieReadSpectra(thisLight,wave);
    case {'d65'}
        thisLight = fullfile(baseDir,'D65');
        SPD = ieReadSpectra(thisLight,wave);
        
    case {'white','uniform','equalenergy'}
        SPD = ones(length(wave),1);
         
    case {'equalphotons'}
        SPD = Quanta2Energy(wave,ones(1,length(wave)))';
    
    case 'blackbody'
        if ~checkfields(illP,'temperature')
            temperature = 6500;
        else
            temperature = illP.temperature;
        end
        SPD = blackbody(wave,temperature);
        
    case {'555nm','monochrome'}
        SPD = zeros(length(wave),1);
        % Set the wavelength closest to 555 to 1
        [~,idx] = min(abs(wave - 555));
        SPD(idx) = 1;
        
    otherwise   
        error('Illumination:  Unknown light source');
end

% Compute the current light source luminance; scale it to the desired luminance.
% The formula for luminance is 
% currentL = 683 * binwidth*(photopicLuminosity' * SPD);
currentL = ieLuminanceFromEnergy(SPD',wave);
spectralRadiance = (SPD / currentL) * luminance;

% Just check the values
%  ieLuminanceFromEnergy(spectralRadiance',wave)
%  ieXYZFromEnergy(spectralRadiance',wave)

end