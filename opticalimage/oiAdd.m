function oiOut = oiAdd(in1,in2,addFlag)
% Add together the photons from two scenes
%
% Synopsis
%  oiOut = oiAdd(in1,in2,[addFlag='add'])
%
% Brief
%   Typically used to add the irradiance from two opticalimages that match
%   in all ways (row, col, wavelength, so forth).
%
%   Alternative use is to set in1 to a cell array of OIs that
%   are matched.  in2 should then be a vector of weights for
%   combining the scenes.
%
% Inputs
%
%  in1 - Typically just an OI, but can be a cell array of OIs 
%  in2 - Typically an OI, but if in1 is a cell array, this is a
%        vector of weights
%  addFlag - Defines the operation
%    add:     Sum the irradiance data from the two OIs (default)
%    remove spatial mean:  Remove mean from scene2 and then add to scene1
%
% Output
%  oiOut - The combined OIs
%
% See also:
%  s_scielabPatches

% Examples:
%{
  scenes{1} = sceneCreate('rings rays',[],[256 256]);
  hParms = harmonicP; hParms.row = 256; hParms.col = 256; hParms.freq = 4;
  scenes{2} = sceneCreate('harmonic',hParms);
  oi = oiCreate;
  ois{1} = oiCompute(oi,scenes{1});
  ois{2} = oiCompute(oi,scenes{2});
  oiOut = oiAdd(ois,[0.5 0.5],'add');
  oiWindow(oiOut);
%}


%% We should do more parameter checking rather than just let the thing break.
if ieNotDefined('in1'), error('in1 required'); end
if ieNotDefined('in2'), error('in2 required'); end
if ieNotDefined('addFlag'), addFlag = 'add'; end

addFlag = ieParamFormat(addFlag);

if ~iscell(in1)
    % Two scenes.  Add them.

    %% Get the photons and do the right thing
    p = oiGet(in1,'photons');
    s = oiGet(in2,'photons');
    nWave = oiGet(in2,'nwave');

    switch addFlag
        case 'add'
            % Just add
        case 'removespatialmean'
            % Remove the mean of scene2 before adding to scene1
            % This effectively adds the contrast of scene2 to scene1.
            for ww=1:nWave
                s(:,:,ww) = s(:,:,ww) - mean(mean(s(:,:,ww)));
            end
        otherwise
            error('Unknown addFlag %s',addFlag)
    end

    % Add p and s and return that as the photons in scene1
    oiOut = oiSet(in1,'photons',p+s);
else
    % Input format is cell array and weights.  So loop and add.

    nOIS = numel(in1);             % All the input scenes
    nWave = oiGet(in1{1},'nwave'); % Wave must be the same for all
    wgts = in2;                       % Weights
    assert(length(wgts) == nOIS);

    % Check that they all match in size
    sz = oiGet(in1{1},'size');
    for ii=2:nOIS
        if ~(isequal(oiGet(in1{ii},'size'),sz))
            error('OI row col sizes do not match.')
        end
    end

    p = wgts(1)*oiGet(in1{1},'photons');

    switch addFlag
        case 'add'
            for ss=2:nOIS
                p = p + wgts(ss)*oiGet(in1{ss},'photons');
            end
        case 'removespatialmean'
            for ss=2:nOIS
                s = oiGet(in1{ss},'photons');
                for ww=1:nWave
                    s(:,:,ww) = s(:,:,ww) - mean(mean(s(:,:,ww)));
                end
                p = p + wgts(ss)*s;
            end            
        otherwise
            error('Unknown addFlag %s',addFlag)
    end
    oiOut = oiSet(in1{1},'photons',p);
end

end
