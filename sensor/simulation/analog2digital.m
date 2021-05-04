function [quantImg,quantizationError] = analog2digital(sensor,method)
%Analog-to-digital conversion for voltage data in a sensory array
%  
%  [qImage,qError] = analog2digital(ISA,method)
%
%  Various quantization schemes are implemented. This routine calculates
%  the quantized image and the quantization error, if requested.. 
%   
% Example:
%
% [qImage,qError] = analog2digital(ISA,method);
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('method'), method = sensorGet(sensor,'quantizationMethod'); end

%% Get voltage data and range
voltageSwing = sensorGet(sensor,'pixel voltageSwing');
img          = sensorGet(sensor,'volts'); 
dn2volts = sensor.dn2volts;
if isempty(img), error('No voltage image'); end

%% Apply method
switch lower(method)
    
    case {'analog'}
        quantImg = img;
        if nargout == 2
            quantizationError = zeros(size(img)); 	% [mV]
        end
        
    case {'lin','linear'}
        % This assumes that the lowest value is 0 and the highest
        % value is voltageSwing, and we divide the volts evenly over
        % that range.
        nBits = sensorGet(sensor,'nbits'); 
        if isempty(nBits), nBits = 8; warning('ISET:Quantization0','Assuming %d bits.',nBits); end
        %quantizationStep = voltageSwing / (2^nBits);               % [V/DN]
        quantizationStep = dn2volts;     % [V/DN]
        quantImg = round(img/quantizationStep);                     % [DV]
        if nargout == 2
            quantizationError = img - (quantImg * quantizationStep); 	% [mV]
        end
                
    otherwise
        warning('ISET:Quantization1','Unknown quantization method.')
end

end
