%% Visible SNR metric calculation
%
% We calculate the *visible SNR* (VSNR) of a camera and its
% processing pipeline. This metric can be used to evaluate
% different imaging artifacts.  See
% <http://white.stanford.edu/~brian/papers/pdc/2010-vSNR-Farrell.pdf
% Farrell et al., 2010>.
%
% We show both the VSNR and the $\Delta E$ CIELAB error.
%
% The script relies on the camera object a structure with
% slots for optics (oi), image sensor (sensor), and image
% processing pipeline (vci).
%
% See also:  cameraVSNR, cameraCreate, s_metricsAcutance,
% s_metricsColorAccuracy 
%
% Copyright ImagEval Consultants, LLC, 2012.

%%
ieInit

%% Initialize the virtual camera.

camera = cameraCreate;

%% Visible SNR (VSNR) at different mean intensities

% Light intensity of uniform field in cd/m2
levels = logspace(1.5,3,3);

% Computes for a 10 ms exposure duration.
cVSNR  = cameraVSNR(camera,levels);

vcNewGraphWin;
loglog(cVSNR.lightLevels,cVSNR.vSNR,'-o');
xlabel('Light level (cd/m^2)')
ylabel('vSNR (1/dE)');
grid on;

%% It can be nice to plot the dE values on the right hand side.

vcNewGraphWin();
ax = plotyy(cVSNR.lightLevels,cVSNR.vSNR,cVSNR.lightLevels,cVSNR.vSNR,'loglog');
xlabel('Light level (cd/m^2)')
grid on;
vsnrLabels = get(ax(1),'yticklabel');

deLabels = vsnrLabels;
for ii=1:length(vsnrLabels)
    deLabels{ii}   = num2str( round(100*(1/str2double(vsnrLabels{ii})))/100);
    vsnrLabels{ii} = num2str( round(100*(str2double(vsnrLabels{ii})))  /100);
end
set(ax(1),'yticklabel',vsnrLabels)
set(ax(2),'yticklabel',deLabels)

set(get(ax(1),'Ylabel'),'String','VSNR','fontsize',20) 
set(get(ax(2),'Ylabel'),'String','\Delta E','fontsize',20) 

%% 



