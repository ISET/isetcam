function photoreceptors = DefaultPhotoreceptors(kind)
% photoreceptors = DefaultPhotoreceptors(kind)
% 
% Return a structure containing default sources 
% for photoreceptor complements of various kinds.
%
% Available kinds
%   LivingHumanFovea (Default) - Human foveal cones in the eye
%   LivingHumanMelanopsinTsujimura2010 - Estimate of melanopsin gc spectral sensitivity in living eye
%   LivingDog - Canine
%   GuineaPig - Guinea pig in dish
%
% See also:  FillInPhotoreceptors, PrintPhotoreceptors, RetIrradianceToIsoRecSec
%  IsomerizationsInEyeDemo, IsomerizationsInDishDemo, ComputeCIEConeFundamentals,
%  RodFundamentalTest, MelanopsinFundamentalTest.
%
% NOTES: Should probably update the parameters for LivingHumanFovea so that
% they produce the Stockman-Sharpe fundamentals.  This should be pretty
% straightforward, now that all the pieces are implemented as via ComputeCIEConeFundamentals. 
%
% 7/25/03  dhb  Wrote it.
% 12/04/07 dhb  Added dog parameters
% 8/14/11  dhb  Added fieldSizeDegrees and ageInYears fields to photoreceptors for LivingHumanFovea case.
%               These defaults match the CIE standard.
% 4/20/12  dhb  Add LivingHumanMelanopsin
% 5/10/12  dhb  Changed name for LivingHumanMelanopsin to postpend Tsujimura2010
% 8/12/13  dhb  Change field order to make printouts look nicer.
% 11/13/13 dhb  Add 'LivingHumanRod' and 'LivingHumanMelanopsin' options.
% 5/26/14  dhb  Add pupilDimater.value = [] to fix FillInPhotoreceptors.

% Default
if (nargin < 1 || isempty(kind))
	kind = 'LivingHumanFovea';
end

% Fill it in
switch (kind)
    case 'CIE2Deg'
        photoreceptors.species = 'Human';
        photoreceptors.types = {'FovealLCone' 'FovealMCone' 'FovealSCone'};
        photoreceptors.nomogram.S = WlsToS((390:5:780)');
		photoreceptors.OSlength.source = 'None';
		photoreceptors.ISdiameter.source = 'Rodieck';
		photoreceptors.specificDensity.source = 'None';
        photoreceptors.axialDensity.source = 'CIE';
        photoreceptors.nomogram.source = 'None';
        photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.fieldSizeDegrees = 2;
        photoreceptors.ageInYears = 32;
        photoreceptors.pupilDiameter.value = 3;
		photoreceptors.eyeLengthMM.source = 'Rodieck';
        photoreceptors.absorbance = 'log10coneabsorbance_ss';
		photoreceptors.lensDensity.source = 'CIE';
        photoreceptors.macularPigmentDensity.source = 'CIE';
        
    case 'CIE10Deg'
        photoreceptors.species = 'Human';
        photoreceptors.types = {'LCone' 'MCone' 'SCone'};
        photoreceptors.nomogram.S = WlsToS((390:5:780)');
		photoreceptors.OSlength.source = 'None';
		photoreceptors.ISdiameter.source = 'Webvision';
		photoreceptors.specificDensity.source = 'None';
        photoreceptors.axialDensity.source = 'CIE';
        photoreceptors.nomogram.source = 'None';
        photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.fieldSizeDegrees = 10;
        photoreceptors.ageInYears = 32;
        photoreceptors.pupilDiameter.value = 3;
		photoreceptors.eyeLengthMM.source = 'Rodieck';
        photoreceptors.absorbance = 'log10coneabsorbance_ss';
		photoreceptors.lensDensity.source = 'CIE';
        photoreceptors.macularPigmentDensity.source = 'CIE';
   
   % LivingHumanRod
   %
   % The choices of values here were chosen in the Brainard
   % lab (by Manuel Spitschan) to provide a pretty good fit to the CIE
   % 1924 scotopic sensitivity curve.  Many combinations of lambda max,
   % nomogram, and axial densitiy will provide a good fit.  We chose the ones
   % below because the lambda-max and axial density parameters seem
   % in accord with values in the literature and the fit is quite good.
   % Ref [1] gives lambda max of 491, and the average of the rod axial density values in
   % [2] and [3] is the value 0.334.
   %
   % See RodFundamentalTest to obtain a plot of the agreement with the tabulated 1924 function.
   %
   % Depending on what you are using this for, you may want to override the default 3 mm pupil.
   %
   % [1] Baylor DA, Nunn BJ, Schnapf JL. The photocurrent, noise, and spectral
   % sensitivity of rods of the monkey Macaca fascicularis. J Physiol. 1984; 357: 575?607.
   %
   % [2] Alpern, M. & Pugh, E.N. (1974). The density and photosensitivity of human rhodopsin in
   % the living retina. Journal of Physiology, London, 237, 341-370. [0.342 from densitometry]
   %
   % [3] Zwas, F. & Alpern, M. (1976). The density of human rhodopsin in the rods. Vision Research 16,
   % 121-127. [0.318 from brightness matching, 0.342 from dark adaptation curves]
   case 'LivingHumanRod'
        photoreceptors.species = 'Human';
        photoreceptors.types = {'Rod'};
        photoreceptors.nomogram.S = WlsToS((390:5:780)');
		photoreceptors.OSlength.source = 'None';
		photoreceptors.ISdiameter.source = 'Webvision';
		photoreceptors.specificDensity.source = 'None';
        photoreceptors.axialDensity.source = 'Value Provided Directly';
        photoreceptors.axialDensity.value = 0.334;
        photoreceptors.nomogram.source = 'Govardovskii';
        photoreceptors.nomogram.lambdaMax = 491;
        photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.fieldSizeDegrees = 10;
        photoreceptors.ageInYears = 32;
        photoreceptors.pupilDiameter.value = 3;
		photoreceptors.eyeLengthMM.source = 'Rodieck';
		photoreceptors.lensDensity.source = 'CIE';
        photoreceptors.macularPigmentDensity.source = 'CIE';
        
   % LivingHumanMelanopsin
   %
   % The choices of values here were chosen in the Brainard
   % lab to privde an estimate of a reasonable fundamental for
   % melanopin ipRGCs.  We follow work from the Lucas lab [1,2]
   % and use a very low (essentially zero) axial density and no
   % macular pigment (because the ipRGCs are in front of most of
   % the macular pigment, as we understand it [3].  We inherit the
   % CIE standard for lens density, and this can be adjusted via
   % the CIE formulae by overriding the default age and pupil size
   % parameters.
   %
   % [1] Enezi, J, Revell, V, Brown, T, Wynne, J, Schlangen, L. & Lucas, R. (2011).
   % A "melanopic" spectral efficiency function predicts the sensitivity of melanopsin
   % photoreceptors to polychromatic lights. J Biol Rhythms 26(4), 314-23.
   % doi: 10.1177/0748730411409719
   %
   % Brown, T, Allen, A, Al-Enezi, J., Wynne, J., Schlangen, L., Hommes, V. & Lucas, R. (2013).
   % The Melanopic Sensitivity Function Accounts for Melanopsin-Driven Responses in Mice under
   % Diverse Lighting Conditions. PLoS One, 8(1), e53583. doi: 10.1371/journal.pone.0053583.
   %
   % Vienot, F., Brettel, H., Dang, T.V., Le Rohellec, J. (2012). Domain of metamers exciting
   % intrinsically photosensitive retinal ganglion cells (ipRGCs) and rods. J Opt Soc Am A Opt
   % Image Sci Vis. 29(2): A366-76. doi: 10.1364/JOSAA.29.00A366.
    case 'LivingHumanMelanopsin'
        photoreceptors.species = 'Human';
        photoreceptors.types = {'Melanopsin'};
        photoreceptors.nomogram.S = WlsToS((390:5:780)');
        photoreceptors.axialDensity.source = 'Value provided directly';
        photoreceptors.axialDensity.value = 0.015;
        photoreceptors.nomogram.source = 'Govardovskii';
        photoreceptors.nomogram.lambdaMax = 480;
        photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.fieldSizeDegrees = 10;
        photoreceptors.ageInYears = 32;
        photoreceptors.pupilDiameter.value = 3;
        photoreceptors.lensDensity.source = 'CIE';
        photoreceptors.macularPigmentDensity.source = 'None';
        
	case 'LivingHumanFovea'
		photoreceptors.species = 'Human';
        photoreceptors.types = {'FovealLCone' 'FovealMCone' 'FovealSCone'};
        photoreceptors.nomogram.S = [380 1 401];
		photoreceptors.OSlength.source = 'Rodieck';
		photoreceptors.ISdiameter.source = 'Rodieck';
		photoreceptors.specificDensity.source = 'Rodieck';
		photoreceptors.nomogram.source = 'StockmanSharpe';
		photoreceptors.nomogram.lambdaMax = [558.9 530.3 420.7]';
		photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.fieldSizeDegrees = 2;
        photoreceptors.ageInYears = 32;
        photoreceptors.pupilDiameter.source = 'PokornySmith';
        photoreceptors.pupilDiameter.value = [];
		photoreceptors.eyeLengthMM.source = 'Rodieck';
        photoreceptors.lensDensity.source = 'StockmanSharpe';
		photoreceptors.macularPigmentDensity.source = 'Bone';

    % This creates Tsujiumura's (2010) estimate of the melanopsin gc
    % spectral sensitivity in the human eye. The quantal efficiency
    % is just made up, though, so that the code runs.
    %
    % Tsujimura has used different lambda-max in different papers.
    % The 482 value given here is from the 2010 paper.  His email
    % suggests he may have used 489 and 502 at different times.  Also
    % by email, he used Stockman-Sharpe not Govardovskii nomogram
    % for the 2010 paper, despite what the paper says.
    %
    % The value Tsujimura uses for axial density seems way too high,
    % given what the physiologists tell us about the fact that
    % the melanopsin receptors live in a very thin layer in the ganglion
    % cells.
    case 'LivingHumanMelanopsinTsujimura2010'
        photoreceptors.species = 'Human';
        photoreceptors.types = {'Melanopsin'};
        photoreceptors.nomogram.S = [380 1 401];
        photoreceptors.axialDensity.source = 'Tsujimura';
        photoreceptors.axialDensity.value = 0.5;
        photoreceptors.nomogram.source = 'StockmanSharpe';
		photoreceptors.nomogram.lambdaMax = [482]';
        photoreceptors.quantalEfficiency.source = 'None';
        photoreceptors.quantalEfficiency.value = 1;
        photoreceptors.fieldSizeDegrees = 10;
        photoreceptors.ageInYears = 32;
        photoreceptors.lensDensity.source = 'CIE';
		photoreceptors.macularPigmentDensity.source = 'CIE';

    case 'LivingDog'
        photoreceptors.species = 'Dog';
        photoreceptors.types = {'LCone' 'SCone' 'Rod'};
        photoreceptors.nomogram.S = [380 1 401];
        photoreceptors.OSlength.source = 'PennDog';
        photoreceptors.ISdiameter.source = 'PennDog';
		photoreceptors.specificDensity.source = 'Generic';
		photoreceptors.pupilDiameter.source = 'PennDog';
        photoreceptors.pupilDiameter.value = [];
		photoreceptors.eyeLengthMM.source = 'PennDog';
		photoreceptors.nomogram.source = 'Govardovskii';
		photoreceptors.nomogram.lambdaMax = [555 429 506]';
		photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.lensDensity.source = 'None';
		photoreceptors.macularPigmentDensity.source = 'None';
        
	case 'GuineaPig'
        photoreceptors.species = 'GuineaPig';
        photoreceptors.types = {'MCone' 'SCone' 'Rod'};
        photoreceptors.nomogram.S = [380 1 401];
        photoreceptors.OSlength.source = 'SterlingLab';
        photoreceptors.OSdiameter.source = 'SterlingLab';
		photoreceptors.ISdiameter.source = 'SterlingLab';
		photoreceptors.specificDensity.source = 'Bowmaker';
		photoreceptors.pupilDiameter.source = 'None';
        photoreceptors.pupilDiameter.value = [];
		photoreceptors.eyeLengthMM.source = 'None';
		photoreceptors.nomogram.source = 'Govardovskii';
		photoreceptors.nomogram.lambdaMax = [529 430 500]';
		photoreceptors.quantalEfficiency.source = 'Generic';
        photoreceptors.lensDensity.source = 'None';
		photoreceptors.macularPigmentDensity.source = 'None';
        
	otherwise
		error('Unknown photoreceptor kind specified');
end
