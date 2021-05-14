function sensor = binPixelPost(sensor,bMethod)
%Apply second stage (digital) of pixel binning
%
%  sensor = binPixelPost(sensor,bMethod)
%
% Some algorithms combine data in the digital stage.  Others not.  This
% routine sorts through the algorithms and either returns with no change or
% combines the digital values.
%

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end
if ieNotDefined('bMethod'), error('Binning method required.'); end

switch lower(bMethod)
    case 'kodak2008'
        % We average digital values
        dv = sensorGet(sensor,'dv');
        
        % This is the averaging function
        binFun = @(dv) round(0.5*[ 1 0 1 0; 0 1 0 1]*dv);
        
        % Apply binFun to [4,2] sections in the digital data
        dv = blockproc(dv,[4 2],binFun);
        sensor = sensorSet(sensor,'digitalValues',dv);
    case 'averageadjacentdigitalblocks'
        % In this case we want to average a 4x4 block down to a 2x2 block.
        % The digital values have been computed already.
        dv = sensorGet(sensor,'dv');
        
        % This is the averaging function
        binFun = @(x) 0.25*[1 0 1 0; 0 1 0 1]*x*[ 1 0 1 0; 0 1 0 1]';
        
        % Apply binFun to [4,2] sections in the digital data
        dv = blockproc(dv,[4 4],binFun);
        sensor = sensorSet(sensor,'digitalValues',dv);
        
    otherwise
        % 'addAdjacentBlocks' % Reduces rows and cols x 2
        
        % Do nothing
end

return

