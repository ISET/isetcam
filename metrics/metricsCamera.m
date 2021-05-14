function metric = metricsCamera(camera, metricname)
% metricsCamera - Gateway routine for computing metrics for a camera
%
%  metric = metricsCamera(camera, metricname)
%
% This function calculates predefined metrics for a camera.  These metrics
% include the scene that should be calculated, which differs from metrics
% that apply to any pair of images such as in metricsCompute.m.
%
% This function will include various existing standards and procedures for
% real cameras such as the ones invoked by DxO and Imatest, on physical
% cameras.
%
% All important results calculated for the metric can be returned in the
% output metric structure.
%
% Perhaps this should not be called directly but only by cameraGet.
%
% The script, s_metricsCamera, does the same thing and probably should be
% deleted.
%
% Copyright ImagEval Consultants, LLC, 2012.

if ~exist('camera', 'var') || isempty(camera),   error('camera struct required'); end
if ~exist('metricname','var') || isempty(metricname), error('metricname must be defined.'); end

metricname = ieParamFormat(metricname);

switch(metricname)
    
    % Color accuracy test
    case {'mcccolor'}
        %  Measure the CIELAB delta E values for rendering a Macbeth Color
        %  Checker under a D65 illuminant.
        metric = cameraColorAccuracy(camera);
        
        % Slanted edge MTF test
    case {'slantededge'}
        metric = cameraMTF(camera);
        
        % Full reference metrics for pre-selected scenes
    case {'fullreference'}
        metric = cameraFullReference(camera);
        
        % Moire starting point
    case {'moire'}
        metric = cameraMoire(camera);
        
        % Visible SNR (visibility of noise in uniform area)
    case {'vsnr'}
        metric = cameraVSNR_SL(camera);
        
        
        %Following need more work
        %% Compute acutance
    case {'acutance'}
        
        
        % cycles/mm is the default for the ISO12233 MTF.  We would like to compute
        % cy/deg, which is related by cpd = (cycles/mm) *(1/degPerMM)
        degPerMM = sensorGet(camera.sensor,'h deg per distance','mm');
        cpd = cMTF.freq / degPerMM;
        lumMTF = cMTF.mtf(:,4);  % This is the MTF in cpd for the luminance
        cpiq = cpiqCSF(cpd);
        Acutance = ISOAcutance(cpd,lumMTF);
        
        vcNewGraphWin([],'tall'); subplot(2,1,1)
        plot(cpd,cpiq,'-k',cpd,lumMTF,'--r');
        grid on;
        hold on;
        xlabel('Cycles per degree'); ylabel('SFR');
        title(sprintf('Acutance %.2f',Acutance))
        legend('CPIQ','MTF')
        
        % Interpolate the standard function to these cpd values, but only up to the
        % Nyquist
        subplot(2,1,2)
        idx = (cMTF.freq < cMTF.nyquistf);
        cpiq = cpiqCSF(cpd(idx));
        plot(cpd(idx),cpiq,'-k',cpd(idx),lumMTF(idx),'--r'); grid on
        xlabel('cpd'); ylabel('SFR')
        Acutance = ISOAcutance(cpd(idx),lumMTF(idx));
        title(sprintf('Acutance %.2f',Acutance))
        legend('CPIQ','MTF')
        
        %% Lateral chromatic aberration test
        
        %% Relative illumination fall off
        
        %% Geometric distortion
        
    otherwise
        error('Unknown %s\n',param);
        
end

%% Remove vci from metric if it exists
% Goal here is to save memory under the assumption these metrics will be
% saved to disk along with lots of similar files.  If we want the vci, this
% can be commented.
if isfield(metric, 'vci')
    metric = rmfield(metric, 'vci');
end