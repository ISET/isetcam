function [quantImg,quantizationError] = binAnalog2digital(ISA,method)
%Analog-to-digital conversion for voltage data in a sensory array
%
%  [qImage,qError] = binAnalog2digital(ISA,method)
%
%  Various quantization schemes are implemented. This routine calculates
%  the quantized image and the quantization error, if requested.
%
% Example:
%
% [qImage,qError] = binAnalog2digital(ISA,method);
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('ISA'),    ISA = vcGetObject('sensor'); end
if ieNotDefined('method'), method = sensorGet(ISA,'quantizationMethod'); end

%% Read voltage data
% Some algorithms put the intermediate voltage data into the dv field. An
% algorithm that uses this method is kodak2008
img          = sensorGet(ISA,'digitalValues');

% If this has not happened, the img value is just a single number and we
% get the data from the volt field. An algorithm that uses this method is
% averageAdjacentDigitalBlocks
if isscalar(img), img = sensorGet(ISA,'volts');    end

% If there is nothing anywhere, we have a problem.
if isempty(img),  error('No dv or voltage image'); end

voltageSwing = pixelGet(ISA.pixel,'voltageSwing');

%% Apply method
switch lower(method)
    
    case {'analog'}
        quantImg = img;
        if nargout == 2
            quantizationError = zeros(size(img)); 	% [mV]
        end
        
    case {'lin','linear'}
        nBits = sensorGet(ISA,'nbits');
        if isempty(nBits), nBits = 8; warning('ISET:Quantization0','Assuming %d bits.',nBits); end
        quantizationStep = voltageSwing / (2^nBits);	    % [mV/DN]
        quantImg = round(img/quantizationStep);             % [DV]
        if nargout == 2
            quantizationError = img - (quantImg * quantizationStep); 	% [mV]
        end
    otherwise
        warning('ISET:Quantization1','Unknown quantization method.')
end

return;
