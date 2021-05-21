%% Reading multispectral and hyperspectral scenes
%
% We use the term multispectral to refer to scene spectral
% radiance estimated using simple instruments, such as
% multiple multiple illuminants and color filters.  We use the
% term hyperspectral to refer to spectral radiances measured with
% specialized instruments that literally acquire each image in a
% narrow waveband.
%
% In the end, however, both types of scenes are read in to
% generate the scene spectral radiance data. Some multispectral
% and hyperspectral scene data are included in data/images and
% much additional freely available scene radiance data can be
% found on the ImageVal web site. These are all formatted so they
% can be read using the function *sceneFromFile*.
%
% The multispectral data are tyically stored in a compressed
% format, using the singular value decomposition (principal
% components).
%
% When the data are compressed, the files contain the following
% variables:
%
% * basis.basis: [N x M] matrix where N is the number of
%                wavelength samples and  M is the number of
%                spectral basis functions
% * basis.wave:  [1 x N] vector containing the wavelength samples
% * coefficients:[rows x cols x M] matrix of the model
%                coefficients
% * wave:        [1 x N] vector containing the sampled wavelengths
% * illuminant:  Illuminant structure.  See illuminantCreate.
%
% Other multispectral and hyperspectral data can be downloaded from
%
%  https://exhibits.stanford.edu/data/browse/iset-hyperspectral-image-database
%
% See also: s_sceneFromRGB, sceneFromFile
%
% Copyright ImagEval Consulting LLC, 2013

%%
ieInit;

%% Name the scene data file

fullFileName = fullfile(isetRootPath,...
    'data','images','multispectral','StuffedAnimals_tungsten-hdrs');

%% Specify the wavelength sampling
wList = (400:10:700);
meanLuminance = [];  % Accepts the data
display = [];        % Use default ISET display structure (displayCreate)

%% Read the file and display the scene

scene = sceneFromFile(fullFileName,'multispectral',meanLuminance,display,wList);
ieAddObject(scene); sceneWindow

%%

