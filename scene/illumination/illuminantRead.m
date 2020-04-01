function [spectralRadiance,wave] = illuminantRead(illP,lightName,wave,luminance)
%Return spectral radiance of a standard illuminants in energy units
%
%    [spectralRadiance,wave] = illuminantRead(illP,lightName,wave,luminance)
% 
% Brief description
%  The illuminant parameters (illP) are stored in the structure illP, or
%  they  are provided by the lightName, wave and luminance parameters. The
%  examples show how to initialize the values of this structure.
%
%  The illP structure is idiosyncratic and used only here. If you don't
%  wish to establish illP, but only to get a default SPD for some named
%  illuminant, you can use the format 
%
%   illuminantRead([],illuminantName,wave,luminance)
%
%  In this case the spectral radiance is returned at wave samples (default
%  400:10:700), and the mean luminance is luminance cd/m2 (default 100).
%
% The standard illuminant names are:
%
%     {'tungsten'}
%     {'illuminantc'}
%     {'d50'}
%     {'fluorescent'}
%     {'d65','D65'}
%     {'equalenergy'}
%     {'555nm'}
%
% You can use the illP format with the name 'blackbody' as well.  In that
% case you must specify the color temperature in the illP.temperature slot.
%
% Examples:
%  ieExamplesPrint('illuminantRead')
%
% See also: 
%   illuminantCreate, illuminantGet/Set

% Examples:
%{
   wave = 380:770; luminance = 10;
   [radiance, wave] = illuminantRead([],'d65',wave,luminance)
   plotRadiance(wave,radiance)
%}
%{
   [illSPD,wave] = illuminantRead([],'tungsten'); 
   plotRadiance(wave,illSPD)
%}
%{
   illP.name = 'd65';
   illP.spectrum.wave = 400:2:700;
   illP.luminance = 100;
   [spd,wave] = illuminantRead(illP);
   plotRadiance(wave,spd);
%}
%{
   illP.name = 'blackbody';
   illP.temperature = 3000;
   illP.spectrum.wave = 400:10:700;
   illP.luminance = 100;
   [sr,wave] = illuminantRead(illP);
   plotRadiance(wave,sr);
%}

%%
if ieNotDefined('illP')
    % No illP
    if ieNotDefined('lightName')
        name = 'd65';
        warndlg('No illuminant name.  Assuming D65');
    else, name =  lightName;
    end
    if ieNotDefined('wave'), wave = 400:10:700; end
    if ieNotDefined('luminance'), luminance = 100; end
else
    % We have the illP
    name      = illP.name;
    luminance = illP.luminance; 
    wave      = illP.spectrum.wave;
end

%%
name = ieParamFormat(name);
baseDir = fullfile(isetRootPath,'data','lights');
switch lower(name)
    case {'tungsten'}
        thisLight = fullfile(baseDir,'Tungsten.mat');
        SPD = ieReadSpectra(thisLight,wave);
    case {'illuminantc'}
        thisLight = fullfile(baseDir,'illuminantC.mat');
        SPD = ieReadSpectra(thisLight,wave);
    case {'d50'}
        thisLight = fullfile(baseDir,'D50.mat');        
        SPD = ieReadSpectra(thisLight,wave);
    case {'fluorescent'}
        thisLight = fullfile(baseDir,'Fluorescent.mat');
        SPD = ieReadSpectra(thisLight,wave);
    case {'d65'}
        thisLight = fullfile(baseDir,'D65.mat');
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

%% Compute the current light source luminance

% Scale the radiance to the desired luminance.
% The formula for luminance is 
% currentL = 683 * binwidth*(photopicLuminosity' * SPD);
currentL = ieLuminanceFromEnergy(SPD',wave);
spectralRadiance = (SPD / currentL) * luminance;

% Just check the values
%  ieLuminanceFromEnergy(spectralRadiance',wave)
%  ieXYZFromEnergy(spectralRadiance',wave)

end