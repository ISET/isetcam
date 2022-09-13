function chartP = chartParams
% Return struct with default chart parameters 
% 
% Synopsis
%   chartP = chartParams;
%
% Inputs
%  N/A
%
% Returns
%  chartP - default chart parameters
%
% See also
%    sceneCreate('reflectance chart',chartP);

% Examples:
%{
  chartP = chartParams;
  scene = sceneCreate('reflectance chart',chartP);
  sceneWindow(scene);

  chartP.grayFlag = false;
  scene = sceneCreate('reflectance chart',chartP);
  sceneWindow(scene);

%}

sFiles{1} = which('MunsellSamples_Vhrel.mat');
sFiles{2} = which('Food_Vhrel.mat');
sFiles{3} = which('HyspexSkinReflectance.mat');

% Surface samples from the files
chartP.sFiles = sFiles;
chartP.sSamples = [50 40 10];   % 100 total samples, should be 10x10
chartP.pSize = 24;     % Patch size in pixels
chartP.wave = [];      % Wavelength samples
chartP.grayFlag = 1;   % Add a gray strip column on right
chartP.sampling = 'r'; % Sample with replacement

end
