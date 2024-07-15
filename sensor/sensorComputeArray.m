function [sensorCombined,sensors] = sensorComputeArray(sensorArray,oi,varargin)
% Calculate sensor array response including a combined resonse
%
% Synopsis
%   [sensorCombined, sensorArray] = sensorComputeArray(sensorArray,oi,varargin)
%
% Brief:
%   Calculate response to oi, followed by the combined sensor.  Both a
%
% Input
%  sensorArray
%  oi
%
% Optional key/val
%
% Output
%   sensorCombined
%   sensorArray
%
% See also
%    sensorCompute, sensorCreateArray, s_sensorSplitPixel
%

%{
scene = sceneCreate('default',12); scene = sceneSet(scene,'fov',3); oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
sensorArray = sensorCreateArray('splitpixel','exp time',0.1,'size',[64 96]);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');
ip = ipCreate; ip = ipCompute(ip,sA); ipWindow(ip);
ieNewGraphWin; colormap(jet(4)); image(sA.metadata.npixels); colorbar;
%}
%{
scene = sceneCreate('default',12); scene = sceneSet(scene,'fov',3); oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
sensorArray = sensorCreateArray('splitpixel','exp time',0.2,'size',[64 96]);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','best snr');
ip = ipCreate; ip = ipCompute(ip,sA); ipWindow(ip);
ieNewGraphWin; colormap(jet(4)); image(sA.metadata.bestPixel); colorbar;
%}

%% Parameters

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('sensorArray',@(x)(isstruct(x(:))));
p.addRequired('oi',@(x)(isstruct(x(:)) && isequal(x.type,'opticalimage')));

validMethods = {'average','sum','bestsnr'};
p.addParameter('method','average',@(x)(ismember(ieParamFormat(x),validMethods)));

p.parse(sensorArray,oi,varargin{:});

method = p.Results.method;

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
idx         = zeros(rowcol(1),rowcol(2),numel(sensors));
vElectrons  = zeros(rowcol(1),rowcol(2),numel(sensors));
vSwing      = zeros(numel(sensors),1);
sensitivity = zeros(numel(sensors),1);

sensorCombined = sensors(1);

% Identify the saturated pixels.  Calculate the relative
% spectral sensitivity of the QE.  We account for pixel area
% separatly, below.
for ii=1:numel(sensors)
    vSwing(ii) = sensorGet(sensors(ii),'pixel voltage swing');
    r = sensorGet(sensors(ii),'spectral qe') ./ sensorGet(sensors(1),'spectral qe');
    sensitivity(ii) = mean(r(:),'all','omitnan');

    volts = sensorGet(sensors(ii),'volts');
    idx(:,:,ii) = (volts < (0.95 * vSwing(ii)));
end

% This accounts for area and relative sensitivty.
for ii=1:numel(sensors)
    % We get the electrons, but account for the area
    electrons = sensorGet(sensors(ii),'electrons per area','um');
    thisIDX = idx(:,:,ii);

    % Set saturated pixels to 0
    electrons(~thisIDX) = 0;

    % If the sensitivity is less than sensors(1), we scale up
    % the number of virtual electrons.  The virtual electrons
    % are like an input intensity referred value.
    vElectrons(:,:,ii) = electrons/sensitivity(ii);
end
% ieNewGraphWin; imagesc(vElectrons(:,:,4)); colormap(gray);
% colorbar;


%%
switch ieParamFormat(method)
    case 'average'
               
        % The number of non-saturated sensors at that pixel
        N = sum(idx,3);  
        % Save the number of pixels that contribute to the value at
        % each pixel.
        sensorCombined.metadata.npixels = N;

        % ieNewGraphWin; imagesc(N);
        
        if nnz(N(:) == 0) > 0
            error('All sensors are saturated at some pixels');
        else
            % Calculate the mean of the virtual electrons, accounting
            % for the number of valid sensors.
            volts = sum(vElectrons,3) ./ N;
        end

    case 'bestsnr'
        % Choose the pixel with the most real electrons and thus best SNR.
        
        % We need to convert vElectrons back to electrons.  Then we
        % store the volts with the vElectron value from the best
        % electron.
        electrons = vElectrons;
        for ii=1:numel(sensors)
            electrons(:,:,ii) = vElectrons(:,:,ii)*sensitivity(ii);
        end
        [volts, bestPixel] = max(electrons,[],3);
        volts = volts ./ sensitivity(bestPixel);

        % Find the pixel with the most non-saturated electrons
        % [volts, bestPixel] = max(vElectrons,[],3);
        sensorCombined.metadata.bestPixel = bestPixel;
    
    otherwise
        error('Unknown method %s\n',method);
end

% Scale the volts to occupy the whole voltage swing.
vSwing = sensorGet(sensorCombined,'pixel voltage swing');
volts = vSwing * ieScale(volts,1);

% This is an analog calculation
sensorCombined = sensorSet(sensorCombined,'quantization method','analog');
sensorCombined = sensorSet(sensorCombined,'volts',volts);

% The voltages are computed with this assumption.
sensorCombined = sensorSet(sensorCombined,'analog gain',1);
sensorCombined = sensorSet(sensorCombined,'analog offset',0);

sensorCombined = sensorSet(sensorCombined,'name',sprintf('Combined-%s',method));

end


%{
case 'sum'
        % I don't understand this one
        rowcol = sensorGet(sensors(1),'size');
        electrons = zeros(rowcol(1),rowcol(2),numel(sensors));
        vSwing = zeros(numel(sensors),1);
        cg = zeros(numel(sensors),1);

        for ii=1:numel(sensors)
            electrons(:,:,ii) = sensorGet(imx490Large1,'electrons per area','um');
            vSwing(ii) = sensorGet(sensors(ii),'pixel voltage swing');
            cg(ii) = sensorGet(sensors(ii),'pixel conversion gain');
        end

        % Set the voltage to the mean of the not saturated, input
        % referred electrons.
        cg = sensorGet(sensors(1),'pixel conversion gain');
        volts = cg*(sum(electrons,3));
        volts(isinf(volts)) = 1;
        volts = vSwing * ieScale(volts,1);

        sensorCombined = sensors(1);
        sensorCombined = sensorSet(sensorCombined,'volts',volts);

        % The voltages are computed with this assumption.
        sensorCombined = sensorSet(sensorCombined,'analog gain',1);
        sensorCombined = sensorSet(sensorCombined,'analog offset',0);

        nbits = 24;
        dv = 2^nbits*ieScale(volts,1);
        sensorCombined = sensorSet(sensorCombined,'dv',dv);
        return;
%}