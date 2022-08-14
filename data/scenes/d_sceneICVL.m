%% d_sceneICVL
%
% How to read in data from the ICVL repository and create an ISETCam scene.
% Our copy of the data is in Wandell's Google Drive 
% 
%      Backup/Data/Hyperspectral/ICVL
%
%   https://icvl.cs.bgu.ac.il/hyperspectral/
%
% From the site:
%  The database images were acquired using a Specim PS Kappa DX4
%  hyperspectral camera and a rotary stage for spatial scanning. At this
%  time it contains 200 images and will continue to grow progressively.
%
% Notes
% This is part of a more general effort to create scripts with d_* to
% indicate methods for reading in data.
%
% @inproceedings{arad_and_ben_shahar_2016_ECCV,
%   title={Sparse Recovery of Hyperspectral Signal from Natural RGB Images},
%   author={Arad, Boaz and Ben-Shahar, Ohad},
%   booktitle={European Conference on Computer Vision},
%   pages={19--34},
%   year={2016},
%   organization={Springer}
% }

% Also, ieWebGet() is a means for getting some datasets that we store
% online at wandell@cardinal.stanford.edu
%
% Many of these should be renamed, such as
%   logAR0132AT.m, mccGBRGSensorData.m
%   CMYGCreate.m          fourChannelCreate.m   gaussianCreate.m      s_radiometerCreate.m  sixChannelCreate.m  
%   cornell_thomas.m             multispectral_pbrt.m         sensorCreateIMECSSM4x4vis.m  
%   generateImecQEfile.m         s_imecSensorTestScene.m      v_imec.m  
%   MT9V024Create.m   ar0132atCreate.m  
%   s_dataLamps.m 
%   s_closestFocalDistance.m  s_focusLensTable.m        s_lensUpdateFormat.m  
%   absoluteEfficiency.m    luminosityJuddCreate.m  macularPigmentCreate.m  xyzQuantaCreate.m       
%   lensDensity.m           macular.m               stockmanQuantaCreate.m 
%   ieBarcoSign.m              render_lcd_samsung_rgbw.m  render_oled_samsung.m      
%   s_dataFaces.m  
%   s_safetyStandards.m  
%
% See also
%   ieWebGet

%% The ICVL data set

% Wandell at home
ddir = '/Volumes/Wandell/Spectral_data/ICVL';
chdir(ddir);
sName = '4cam_0411-1640-1';
data = load(sName);
scene = sceneCreate('empty');
scene = sceneSet(scene,'wave',data.bands);
scene = sceneSet(scene,'name',sName);

% If figure energy, not photons
scene = sceneSet(scene,'energy',data.rad);
scene = sceneRotate(scene,'ccw');


scene = sceneAdjustLuminance(scene,100);
illE = sceneGet(scene,'illuminant energy');

energy = sceneGet(scene,'energy');
illE = illE*max(energy(:))/max(illE);
scene = sceneSet(scene,'illuminant energy',illE);
ieReplaceObject(scene);
sceneWindow(scene);
