function sceP = sceCreate(wave, rho_source, position_source)
% Return a structure with Stiles-Crawford Effect parameters
%
% Syntax:
%   sceP = sceCreate(wave, [rho_source], [position_source])
%
% Description:
%    Return a structure with Stiles-Crawford Effect parameters.
%
%    The 'berendschot' data/model is taken from Berendschot et al., 2001, 
%    "Wavelength dependence of the Stiles-Crawford ...", JOSA A, 18, 
%    1445-1451 and then adjusted slighlty (subtracting .0045) to give 
%    rho = 0.041 at 550 nm in agreement with Enoch and Lakshminaranayan's
%    average foveal data in normals (reference for this?). The model is the
%    bold curve in Figure 2, which includes choroidal backscatter.
%
%    The 'applegate' xo, yo parameters are from Applegate &
%    Lakshminaranayan, "Parametric representation of Stiles-Crawford
%    functions: normal variation of peak location and directionality", 
%    1993, JOSA A, 1611-1623.
%
%    If values for wavelengths outside of those over which data are
%    specified are requested, the routine estimates by extending the last
%    available value.
%
%    Original code provided by Heidi Hofer.
%
% Inputs:
%    wls              - Wavelengths (nm) over which to return rho
%    rho_source       - Data source for rho, options below.
%           'none'              - Fill in rho with 0's leads to no SCE
%                                 correction (default).
%           'berendschot_data'  - Adjusted Berendschot et al. (2001, JOSA
%                                 A) mean psychophysical data for rho.
%           'berendschot_model' - Adjusted Berendschot et al. (2001, JOSA
%                                 A) model for rho.
%    position_source  - Data source for SCE center position
%           'centered'          - 0, 0 mm. This may be as good a guess as
%                                 anything, if you don't know R/L eye or
%                                 anything about yoru subject (default).
%           'applegate'         - Right eye numbers from Applegate &
%                                 Lakshminaranayan, 1993.
%
% Output
%    sceP.wavelengths - SCE wavelengths. 
%    sceP.rho         - SCE peakedness rho as a function of wavelength
%                       (units: 1/mm^2)
%    sceP.xo          - SCE x center's position in mm relative to pupil's
%    sceP.yo          - SCE y center's position in mm relative to pupil's
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    TODO:
%       i) There should also be an sceSet
%       ii) Could allow unit specification rather than defaulting to
%       mm-based units.
%       iii) Understand in more detail dependence of SCE on other things, 
%       such as field size and position.
%       iv) Is the additive correction of the Berendschot numbers (as
%       opposed to, say, multiplicative) appropriate?
%       v) Reconcile the two versions of the Berendschot data. Perhaps
%       move where the data are coded and stored out of this routine to a
%       more centralized location.
%
% See Also:
%    sceGet
%

% History:
%    08/21/11  dhb  Pulled into a separate routine.
%    xx/xx/11       (c) WVF Toolbox Team 2011-2012
%    08/19/12  dhb  Expanded data options, better comments about the source
%                   of data.
%    11/10/17  jnm  Comments & formatting
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    sceCreate
    sceCreate(400:5:700, 'berendschot_data')
%}

%% Parameter setup
if ~exist('wave', 'var') || isempty(wave), wave = (400:10:700)'; end
if ~exist('rho_source', 'var') || isempty(rho_source)
    rho_source = 'none';
end
if ~exist('position_source', 'var') || isempty(position_source)
    position_source = 'centered';
end
wave = wave(:);

%% Peakedness (rho)
rho_source = ieParamFormat(rho_source);
switch (rho_source)
    case 'berendschot_data'
        DIGITIZED = 0;
        if (DIGITIZED)
            % Berendschot et al. 2001, wavelength parameters for rho0.
            % These values were digitized from the mean psychophysical data
            % in Figure 2 of that paper, and then splined onto an evenly
            % spaced wavelength basis. The data are not very smooth.
            % Heidi's values taken by eye from the graph smooth it out some
            % and are probably more realistic.
            %
            % Units of peakedness in the data file are 1/mm^2.
            dataFilename = fullfile(wvfRootPath, 'data', ...
                'berendschotEtAl2001_Figure2Data.txt');
            rawData = ReadStructsFromText(dataFilename);
            initWls = [400 5 71];
            rho0 = interp1([rawData.Wavelength]', ...
                [rawData.Peakedness]', ieSToWls(initWls), 'linear');
            index = find(ieSToWls(initWls) == 550);
            if (isempty(index))
                error('Oops. Need a splined value at exactly 550 nm');
            end
            rho0 = rho0 - rho0(index) + 0.041;

        else 
            % These were the psychophysical data read off Figure 2 by eye
            % by HH, with 0.045 subtracted to produce 0.041 at 550 nm. I
            % think they are probably preferable to the digitized version
            % above because they smooth the data. We could figure out how
            % to smooth the psychophysical data from the digitized values, 
            % but not today.
            initWls = [400, 10, 31];
            rho0 = [0.0565 0.0585 0.0605 0.06 0.05875 0.05775 0.0565 ...
                0.0545 0.0525 0.051 0.04925 0.04675 0.044 0.041 0.04 ...
                0.041 0.041 0.0415 0.0425 0.04275 0.04325 0.045 0.047 ...
                0.048 0.0485 0.049 0.04975 0.05 0.04975 0.04925 0.049]';
        end

    case 'berendschot_model'
        % Berendschot et al. 2001, wavelength parameters for rho0. These
        % values were digitized from the bold curve in Figure 2 of that
        % paper, and then splined onto an evenly spaced wavelength basis.
        %
        % Units of peakedness in the data file are 1/mm^2.
        dataFilename = fullfile(wvfRootPath, 'data', ...
            'berendschotEtAl2001_Figure2BoldSmooth.txt');
        rawData = ReadStructsFromText(dataFilename);
        initWls = [400 5 71];
        rho0 = interp1([rawData.Wavelength]', [rawData.Peakedness]', ...
            ieSToWls(initWls), 'linear');
        index = find(ieSToWls(initWls) == 550);
        if (isempty(index))
            error('Oops. Need a splined value at exactly 550 nm');
        end
        rho0 = rho0 - rho0(index) + 0.041;
              
    case 'none'
        % Fill in with zeros
        initWls = [400 10 31];
        rho0 = zeros(size(ieSToWls(initWls)));

    otherwise
        error('Unsupported method %s\n', rho_source);
        
end

%% Center position
position_source = ieParamFormat(position_source);
switch (position_source)
    case 'centered'
        % Given individual variation, just assuming the center of the pupil
        % is reasonable if you know nothing about the individual subject.
        sceP.xo = 0;   % SCE center in mm
        sceP.yo = 0;   % SCE center in mm
        
    case 'applegate'
        % These values are from  Applegate & Lakshminaranayan, 1993. They
        % give the horizontal position as nasal in mm, so that the 0.51
        % number is correct for the right eye (OD) in the OSA coordinate
        % system. It would be -0.51 for the left eye (OS). The verical
        % position is 0.20 superior, which is positive in the OSA system
        % for both eyes. Heidi says that in general, people think that 0
        % might be a better population guess for vertical.
        %
        % The standard deviations for these numbers is large, 0.72 mm
        % horizontal and 0.64 vertical. 
        sceP.xo = 0.51;   % SCE center in mm
        sceP.yo = 0.20;   % SCE center in mm
end
              
%% Spline initial wavelength sampling to request in wls, 
% and extend with values at min/max wavelength if requested
sceP.wavelengths = wave(:);
sceP.rho = interp1(ieSToWls(initWls), rho0, sceP.wavelengths, 'linear');
index = find(sceP.wavelengths < initWls(1));
if (~isempty(index)), sceP.rho(index) = rho0(1); end
index = find(sceP.wavelengths < initWls(end));
if (~isempty(index)), sceP.rho(index) = rho0(end); end

end

function vec = ieSToWls(wls)

lastW = wls(1) + (wls(3)-1)*wls(2);
vec = (wls(1):wls(2):lastW)';

end

