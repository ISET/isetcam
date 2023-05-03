%% ReDFISh data from Grenbole
% 
% https://perscido.univ-grenoble-alpes.fr/datasets/DS289
%
% Every 50 nm from 400 to 1050.  Thus, very coarse in the visible
% range.
%
% The repository says these are reflectance spectra, not radiance
% spectra.  Maybe so.  Read the paper.
%
%{
Paper:
Visible to near infrared multispectral images dataset for image sensors design
Axel Clouet, Célia Viola, Jérôme Vaillant

Database
General information ReDFISh multispectral dataset Contributor: 
Axel CLOUET

Institution: CEA-LETI

Description:

ReDFISh is a dataset containing multispectral images to help image
sensors design. They contain a spectral sampling of reflectance
properties of scenes over the absorption range of silicon (400 - 1050
nm). These data are used to simulate raw image acquisitions according
to spectral sensitivities of a given image sensor under chosen
illumination conditions and exposure setting. They can also be used
for color science.
%}

% Example file.  All are stored on Google Drive in Backup/Data
fname = fullfile(isetRootPath,'local','Candle_50nm.h5');

% The files are reflectance
reflectance = h5read(fname,'/Hymage');
reflectance = double(reflectance)/65536;
wave   = h5read(fname,'/Wavelength');

img    = double(h5read(fname, '/ColorImage'))/255;
% imtool(img);

illuminant = blackbody(wave,6500);  % Energy
[tmp, r, c] = RGB2XWFormat(reflectance);
radiance = XW2RGBFormat(tmp*diag(illuminant),r,c);

%% Turn the reflectance data into a scene with a 6500 bb illuminant

scene = sceneCreate('empty');
scene = sceneSet(scene,'wavelength',wave);
scene = sceneSet(scene,'energy',radiance);
scene = sceneSet(scene,'mean luminance',100);
scene = sceneSet(scene,'illuminant wave',wave);
scene = sceneSet(scene,'illuminant energy',illuminant(:));

sceneWindow(scene);

%% The data were collected under this illuminant

scene = sceneAdjustIlluminant(scene,blackbody(wave,2900));
ieReplaceObject(scene);
sceneWindow;

%{
cube (uint16)

-Wavelength: wavelengths corresponding to each reflectance plane (double)

-ColorImage: sRGB color frame that has been computed thanks to th reflectance datacube using human visual system color matching functions, and equal energy illuminant, a gamma of 1/2.2 has been applied. (uint8)

///////////////Open HDF5 files containing multispectral images (in matlab and python):

Matlab:
function [hymg , color , wave] = read_hdf5(pathFile) %reading multispectral images %hymg: reflectance datacube %color: color frame %wave: wavelength corresponding to each planes of hymg %author: Axel Clouet, axel.clouet@cea.fr

hymg = h5read(pathFile,'/Hymage');
hymg = double(hymg)/65536;

color = double(h5read(pathFile, '/ColorImage'))/255;

wave = h5read(pathFile,'/Wavelength');
end

Python:
import numpy as np import h5py

def read_hdf5(pathFile):

f = h5py.File(pathFile,'r')
ls = list(f.keys())

#open Color image

l_colorImage = list(f[ls[0]])

color = np.zeros( ( l_colorImage[0].shape[1] , l_colorImage[0].shape[0] , len(l_colorImage) ) )
color[:,:,0] = l_colorImage[0].T
color[:,:,1] = l_colorImage[1].T
color[:,:,2] = l_colorImage[2].T

color = color/255
#open Reflectance
l_reflectance = list(f[ls[1]])

hymg = np.zeros( ( l_reflectance[0].shape[1] , l_reflectance[0].shape[0] , len(l_reflectance) ) )

for w in range(len(l_reflectance)):
    hymg[:,:,w] = l_reflectance[w].T

hymg = hymg/65536

#open Wavelength
l_wavelength = list(f[ls[2]])

wave = l_wavelength[0]

return hymg,color,wave~
%}
