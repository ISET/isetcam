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
%           The default reflectance chart uses a fixed sample list so the
%           same chart is recreated each time.
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

% Surface samples from the files.  These are explicit sample indices,
% rather than counts, so chartParams recreates the same chart each time.
chartP.sFiles = sFiles;
chartP.sSamples = {
  [27 47 1 20 10 6 12 23 26 35 27 44 14 57 2 43 27 36 9 13 52 62 21 45 57 58 6 3 11 57 7 27 62 35 45 21 44 54 2 49 64 48 18 51 7 29 59 19 19 9], ...
  [1 19 6 8 14 2 16 4 16 19 3 12 19 12 2 15 18 14 26 16 25 4 4 22 11 5 26 10 21 20 24 17 21 10 8 25 12 27 18 17], ...
  [9 68 32 42 29 17 65 41 1 44]};
chartP.pSize = 24;     % Patch size in pixels
chartP.wave = [];      % Wavelength samples
chartP.grayFlag = 1;   % Add a gray strip column on right
chartP.sampling = 'r'; % Sample with replacement

end
