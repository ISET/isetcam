function [sensorCombined,sensors] = sensorComputeArray(sensorArray,oi,varargin)
% Calculate sensor array response including a combined resonse
%
% Synopsis
%   [sensorCombined, sensorArray] = sensorComputeArray(sensorArray,oi,varargin)
%
% Brief:
%   Calculate response to oi for each of the sensors, and then create
%   the combined sensor.  There are various possible algorithms for
%   combining the multiple sensors.
%
% Input
%   sensorArray -  An array of 3 (OVT) or 4 sensors (imx490).  The
%                  first two are always large photodiode.
%   oi          - Optical image
%
% Optional key/val
%  method:  {'average','best snr','saturated'}  default: saturated
%  saturated:  The fraction of the voltage swing before we declare the
%              pixel saturated.  Default: 0.95
%
% Output
%   sensorCombined - Data pooled from the multiple sensors in the array
%   sensorArray    - The individual sensors
%
% See also
%    sensorCompute, sensorCreateArray, s_sensorSplitPixel

% Examples:
%{
scene = sceneCreate('default',12); scene = sceneSet(scene,'fov',3); oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
sensorArray = sensorCreateArray('array type','ovt','exp time',0.1,'size',[64 96]);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');
ip = ipCreate; ip = ipCompute(ip,sA); ipWindow(ip);
ieNewGraphWin; colormap(jet(4)); image(sA.metadata.npixels); colorbar;
%}
%{
scene = sceneCreate('default',12); scene = sceneSet(scene,'fov',3); oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
sensorArray = sensorCreateArray('array type','imx490','exp time',0.2,'size',[64 96]);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','best snr');
ip = ipCreate; ip = ipCompute(ip,sA); ipWindow(ip);
ieNewGraphWin; colormap(jet(4)); image(sA.metadata.bestPixel); colorbar;
%}

%% Parameters

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('sensorArray',@(x)(isstruct(x(:))));
p.addRequired('oi',@(x)(isstruct(x(:)) && isequal(x.type,'opticalimage')));

validMethods = {'average','saturated'};
p.addParameter('method','saturated',@(x)(ismember(ieParamFormat(x),validMethods)));
p.addParameter('saturated',0.95,@(x)(x >= 0 && x < 1));

p.parse(sensorArray,oi,varargin{:});

method    = p.Results.method;
saturated = p.Results.saturated;  % Between 0 and 1

%% Compute for each of the sensors in the array

for ii=1:numel(sensorArray)
    sensors(ii) = sensorCompute(sensorArray(ii),oi); %#ok<AGROW>
end
% for ii=1:numel(sensors); sensorWindow(sensors(ii)); end       

%% Computational method

% We base our calculations on the electrons, not the voltages.
% The conversion gain is internal to the sensor.
%
% Note: We are not calculating in the quantized space.  To deal with
% quantization, we need to incorporate conversion gain. For now, we
% are just using analog values.
%
% To infer the input level from the number of electrons, we need to
% account for both the area of the pixel, and the presence of a filter
% mask in front of the pixel. These electrons are really 'virtual
% electrons'.  Maybe we should call the estimates apparent photons
% (aPhotons)?

rowcol      = sensorGet(sensors(1),'size');
idx         = false(rowcol(1),rowcol(2),numel(sensors));
input       = zeros(rowcol(1),rowcol(2),numel(sensors));
vSwing      = zeros(numel(sensors),1);
sensitivity = zeros(numel(sensors),1);

% Initialize the output to match the properties of the first array
% element.
sensorCombined = sensors(1);

%% Identify the saturated pixels and estimate the input.  

%  We consider a pixel saturated if it reaches maxVSwing of the true
%  voltage swing.
for ii=1:numel(sensors)
    
    % Calculate the relative spectral sensitivity of the QE.  We
    % account for pixel area separatly, below. We will adjust for the
    % spectral QE, using a sensitivity term relative to the first
    % sensor.
    r = sensorGet(sensors(ii),'spectral qe') ./ sensorGet(sensors(1),'spectral qe');
    sensitivity(ii) = mean(r(:),'all','omitnan');

    volts = sensorGet(sensors(ii),'volts');
    vSwing(ii) = sensorGet(sensors(ii),'pixel voltage swing');

    % These indices are considered saturated.
    idx(:,:,ii) = (volts > (saturated * vSwing(ii)));
    % fprintf('Sensor %d:  Saturated %d\n',ii, sum(idx(:,:,ii),'all'));

    electrondensity = sensorGet(sensors(ii),'electrons per area','um');

    input(:,:,ii) = electrondensity/sensitivity(ii);

    % We should check that the small pixel is NOT saturated in
    % locations where the large pixel is saturated.
    %{
      ieNewGraphWin; imagesc(idx(:,:,1));
      ieNewGraphWin; imagesc(idx(:,:,3));
      sum(idx(:,:,1) .* idx(:,:,3),'all')
    %}
end

%% Make the combined sensor

switch ieParamFormat(method)
    case 'average'
               
        % The number of non-saturated sensors at that pixel
        N = sum(idx,3);  
        % Save the number of pixels that contribute to the value at
        % each pixel.
        sensorCombined.metadata.npixels = N;

        % ieNewGraphWin; imagesc(N);
        
        if nnz(N(:) == 0) > 0
            warning('All sensors are saturated at some pixels');
        else
            % Calculate the mean of the virtual electrons, accounting
            % for the number of valid sensors.
            volts = sum(input,3) ./ N;
        end
        
    case 'bestsnr'
        % The saturated pixels are already set to zero. Choose the
        % pixel with the most real (virtual?) electrons and thus best
        % SNR.  Not sure this one makes sense.
        
        % We need to convert vElectrons back to electrons.  Then we
        % store the volts with the vElectron value from the best
        % electron.
        electrondensity = input;
        for ii=1:numel(sensors)
            electrondensity(:,:,ii) = input(:,:,ii)*sensitivity(ii);
        end
        [volts, bestPixel] = max(electrondensity,[],3);
        volts = volts ./ sensitivity(bestPixel);
        
        % Find the pixel with the most non-saturated electrons
        % [volts, bestPixel] = max(vElectrons,[],3);
        sensorCombined.metadata.bestPixel = bestPixel;        

    case 'saturated'
        % Start with the data from the LPD-LCG at locations it is not
        % saturated. This is the best input referred sensor estimate.
        volts   = input(:,:,1);

        % At locations where first and second are good, use
        % the average of LPD-LCG and LPD-HCG input referred estimates.
        good1 = ~idx(:,:,1); good2 = ~idx(:,:,2);
        good1and2 = logical(good1 .* good2);
        tmp1 = input(:,:,1); tmp2 = input(:,:,2);
        volts(good1and2) = 0.5*tmp1(good1and2) + 0.5*tmp2(good1and2);

        % If LPD-LCG is saturated, LPC-HCG will be, too.

        % Replace the LPD-LCG saturated pixels with estimates from the 3rd
        % OVT (or 3rd IMX490) which is SPD-LCG.  If it is IMX490, we could
        % do the average of SPD-LCG and SPD-HCG.
        sat1        = idx(:,:,1);
        tmp         = input(:,:,3);
        volts(sat1) = tmp(sat1);

    otherwise
        error('Unknown method %s\n',method);
end

%% Set up the combined sensor metadata


% Scale the volts to occupy the whole voltage swing.
vSwing = sensorGet(sensorCombined,'pixel voltage swing');

% Consider this method of scaling the volts.  If we think there is a
% large gap between the very bright pixels and most, we could bring
% the 95th percentile up to half of the voltage swing.
%{
 tst = prctile(volts(:),99.5);
 volts = (volts/tst)*0.50*vSwing;
 volts = ieClip(volts,0,vSwing);
%}

% Simple linear scale
volts = vSwing * ieScale(volts,1);

% This is an analog calculation
sensorCombined = sensorSet(sensorCombined,'quantization method','analog');
sensorCombined = sensorSet(sensorCombined,'volts',volts);

% The voltages are computed with this assumption.
sensorCombined = sensorSet(sensorCombined,'analog gain',1);
sensorCombined = sensorSet(sensorCombined,'analog offset',0);

% More metadata
sensorCombined.metadata.saturated = idx;

% The names are usually ovt-large or imx490-small.  So we split on the
% '-' to create the name.
tmp = split(sensorGet(sensors(1),'name'),'-'); thisDesign = tmp{1};

sensorCombined = sensorSet(sensorCombined,'name',sprintf('%s-%s',thisDesign,method));

end


