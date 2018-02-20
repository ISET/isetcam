function sensor = binPixel(sensor,bMethod)
%Apply pixel binning algorithm to voltage image
%
%   sensor = binPixel(sensor,bMethod)
%
% The voltage image should already have shot noise, dark current, and
% etendue factored in.  It should not have read noise or the fixed pattern
% noises factored in.
%
% There are several different vendor methods for pixel binning.  We start
% with one implementation (kodak).  Others will follow.  See the Wiki page
% notes: http://white.stanford.edu/pdcwiki/index.php/Pixel_Binning
%
% Some of the binning methods require digital calculations after
% quantization.  These are handled in the related routine pixelBin2.
%
% Current algorithms:
%
%    kodak2008  - Adds columns in voltage, digitizes, averages digital rows
%    addAdjacentBlocks - Adds voltage values of all the R (G,B) pixels in a
%      4x4 region.
%    averageAdjacentDigitalblocks - Averages digital values of all the R
%     (G,B) pixels in a 4x4 to create a 2x2, shrinking the image size by a
%     factor of 4. Maybe this belongs in a complete post-processing
%     algorithm that would compete with sensor binning?  That group would
%     blur and sub-sample, like this.  This one blurs with a tophat
%     function.  There is also the issue of doing this prior or post
%     demosaicking.
%
% See also: binPixelPost, binSensorCompute, binSensorComputeImage
%

if ieNotDefined('sensor'), error('sensor required'); end
if ieNotDefined('bMethod'), bMethod = 'kodak2008'; end

% We define each binning function as a small matrix multiply that applies
% to the blocks of the voltage image.  In some cases the complete summing
% can happen here (e.g., addAdjacentBlocks).  In other cases we can only
% bin across the columns and the final shape of the binned image has to be
% computed in the sensorComputeBin routine, which averages the digital
% values after all the processing (e.g., kodak2008).
%
% We leave the voltage data unchanged at this point to maintain the sensor
% size and generally to inspect the voltage numbers later, if we wish. Note
% that these volts don't have the read noise.  From this point on the dv
% values become a hybrid of volts and digital values, only becoming the
% true digital values when we are done.
switch lower(bMethod)
    case 'kodak2008'  % Reduces number of columns x 2
        % sensor = vcGetObject('sensor');
        v = sensorGet(sensor,'volts');
        binFun = @(x) x*[ 1 0 1 0; 0 1 0 1]';
        dv = blkproc(v,[4 4],binFun);
        sensor = sensorSet(sensor,'digitalValues',dv);
        % On return, we need to average the digital values in the rows
        
    case 'addadjacentblocks' % Reduces rows and cols x 2
        % Combines 4x4 block into a 2x2 block
        %
        % The analog voltages in the corresponding 4 CFA positions are
        % added together.  The resulting sensor voltages are half the size
        % in each dimension, and the voltages from corresponding CFA
        % positions are summed. 
        %
        % sensor = vcGetObject('sensor');
        v = sensorGet(sensor,'volts');
        binFun = @(x) [1 0 1 0; 0 1 0 1]*x*[ 1 0 1 0; 0 1 0 1]';
        dv = blkproc(v,[4 4],binFun);
        sensor = sensorSet(sensor,'digitalValues',dv);
        % figure; imagesc(v); axis image;
        
    case 'averageadjacentdigitalblocks'
        % All of the processing is done in binPixelPost.  There we average
        % the quantized data using a method like the one above.
        %
        % To make sure the computation continues, we need to create a value
        % in dv.
        sensor = sensorSet(sensor,'digitalValues',1);
    otherwise
        error('Unknown binning method %s\n',bMethod);
end

return;