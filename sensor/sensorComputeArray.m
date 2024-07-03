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
%    sensorCompute, sensorCreateArray
%

%{
% Average seems OK, but not fully tested.
% best snr has problems
% 
scene = sceneCreate; scene = sceneSet(scene,'fov',25); oi = oiCreate('wvf'); 
oi = oiCompute(oi,scene,'crop',true);
sensorArray = sensorCreateArray('splitpixel','exp time',0.05);
[sA,s]=sensorComputeArray(sensorArray,oi,'method','average');
% sensorWindow(sA);
ip = ipCreate; ip = ipCompute(ip,sA); 
% ipWindow(ip)
% for ii=1:numel(s); sensorWindow(s(ii)); end       
% cm = [1 0 0; 1 0.5 0; 0 0 1; 0 0.5 1; 1 1 1];
% ieNewGraphWin; colormap(cm); image(sA.metadata.bestPixel);
%}

%% Parameters

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('sensorArray',@(x)(isstruct(x(:))));
p.addRequired('oi',@(x)(isstruct(x(:)) && isequal(x.type,'opticalimage')));

validMethods = {'average','sum','bestsnr'};
p.addParameter('method','sum',@(x)(ismember(ieParamFormat(x),validMethods)));

p.parse(sensorArray,oi,varargin{:});

method = p.Results.method;

%% Compute for each of the sensors in the array

for ii=1:numel(sensorArray)
    sensors(ii) = sensorCompute(sensorArray(ii),oi); %#ok<AGROW>
end

%%

switch ieParamFormat(method)
    case 'average'
        % Combine the input referred volts, excluding saturated values.
        rowcol = sensorGet(sensors(1),'size');       
        volts = zeros(rowcol(1),rowcol(2),numel(sensors));
        vSwing = zeros(numel(sensors),1);
        idx = volts;
        for ii=1:numel(sensors)
            volts(:,:,ii) = sensorGet(sensors(ii),'volts');
            vSwing(ii) = sensorGet(sensors(1),'pixel voltage swing');
            idx(:,:,ii) = volts(:,:,ii) < vSwing(ii);
        end
                
        % We average the not saturated pixels.  This is how many.
        N = sum(idx,3);

        % When all four measurements are saturated, N=0. We set those
        % pixels to the saturation level (1).  See below.

        % These are the input referred estimates. When all the
        % voltages are saturated the image is rendered as black.
        % volts per pixel -> (volts/m^2) * gain / (volts/electron)
        %                 -> electrons/m2
        % Maybe we want electrons / um^2 which would be 1e-12
        electrons = zeros(size(volts));
        for ii=1:numel(sensors)
            electrons(:,:,ii) = sensorGet(sensors(ii),'electrons per area','um');
        end

        %  The estimated input, which should be equal for a uniform
        %  field
        %  mean(in1(:)),mean(in2(:)),mean(in3(:)),mean(in4(:))
        %  min(in1(:)),min(in2(:)),min(in3(:)),min(in4(:))
        %  max(in1(:)),max(in2(:)),max(in3(:)),max(in4(:))

        % Set the voltage to the mean of the not saturated, input
        % referred electrons.
        cg = sensorGet(sensors(1),'pixel conversion gain');
        volts = cg*(sum(electrons,3) ./ N);

        vSwing = sensorGet(sensors(1),'pixel voltage swing');
        volts(isinf(volts)) = 1;
        volts = vSwing * ieScale(volts,1);
        % volts = ieClip(volts,0,vSwing);

        sensorCombined = sensors(1);
        sensorCombined = sensorSet(sensorCombined,'pixel voltage swing',max(volts(:)));
        sensorCombined = sensorSet(sensorCombined,'volts',volts);

        % The voltages are computed with this assumption.
        sensorCombined = sensorSet(sensorCombined,'analog gain',1);
        sensorCombined = sensorSet(sensorCombined,'analog offset',0);

        % Save the number of pixels that contribute to the value at
        % each pixel. 
        sensorCombined.metadata.npixels = N;

    case 'bestsnr'
        % Choose the pixel with the most electrons and thus best SNR.
        % Not done yet.  We need to correct to input referred based on
        % the conversion gain and spectral QE of that sensor.  We seem
        % to already be correcting based on the area.
        rowcol = sensorGet(sensors(1),'size');
        electrons = zeros(rowcol(1),rowcol(2),numel(sensors));
        idx = electrons;
        wellcapacity = zeros(numel(sensors),1);
        for ii=1:numel(sensors)
            electrons(:,:,ii) = sensorGet(sensors(ii),'electrons per area','um');
            wellcapacity(ii) = sensorGet(sensors(ii),'pixel well capacity');

            % Find pixels with electrons below well capacity. Set the
            % saturated levels to zero so they do not appear as max
            % e1(~idx1) = 0; e2(~idx2) = 0; e3(~idx3) = 0; e4(~idx4) = 0;
            idx(:,:,ii) = electrons(:,:,ii) < wellcapacity(ii);
            thisElectrons = electrons(:,:,ii); thisIDX = idx(:,:,ii);
            thisElectrons(~thisIDX) = 0;
            electrons(:,:,ii) = thisElectrons;
        end

        % Find the pixel with the most non-saturated electrons
        [val, bestPixel] = max(electrons,[],3);

        % We need to input-refer the electrons so that the voltage
        % from each pixel is an estimate of the light at that pixel.
        % This first calculation corrects for conversion gain.  
        cg = zeros(numel(sensors),1);
        for ii=1:numel(sensors)
            cg(ii) = sensorGet(sensors(ii),'pixel conversion gain');
        end

        % ieNewGraphWin; imagesc(cg(bestPixel)); 
        % ieNewGraphWin; imagesc(bestPixel);
        % ieNewGraphWin; imagesc(val);
        % Not working.  Not sure why.  Need a debugging system.
        volts = val ./ cg(bestPixel);
        
        % ieNewGraphWin; imagesc(volts); colormap(gray)
        % But for the OVT split pixel, we also need to estimate based on QE.

        % Prepare the combined sensor.
        sensorCombined = sensors(1);
        sensorCombined = sensorSet(sensorCombined,'pixel voltage swing',sensorGet(sensors(1),'pixel voltage swing')*4);
        sensorCombined.metadata.bestPixel = bestPixel;
        sensorCombined = sensorSet(sensorCombined,'analog gain',1);
        sensorCombined = sensorSet(sensorCombined,'analog offset',0);

        sensorCombined = sensorSet(sensorCombined,'volts',volts);

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
    otherwise
        error('Unknown method %s\n',method);
end

sensorCombined = sensorSet(sensorCombined,'name',sprintf('Combined-%s',method));

end