function params = hdrlightsP
% Default parameters for hdr lights scene
%
% See also
%  sceneHDRLights, harmonicP, sceneCreate('hdr lights');

%{
p = hdrlightsP;
scene = sceneCreate('hdr lights',p);
%}

params.imagesize = 384;

params.ncircles = 4;
params.radius = [0.01,0.035,0.07,0.1];
params.circlecolors = {'white' ,'green','blue','yellow','magenta'};

params.nlines = 4;
params.linelength = 0.02;
params.linecolors = {'white','green','blue','yellow','magenta','white'};

end

