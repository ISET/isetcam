function sceneOut = sceneAdd(in1,in2,addFlag)
% Add together the photons from two scenes
%
% Synopsis
%  scene = sceneAdd(in1,in2,[addFlag='add'])
%
% Brief
%   Typically used to add the radiance from two scenes that match in
%   all ways (row, col, wavelength, so forth).
%
%   Alternative use is to set in1 to a cell array of scenes that
%   are matched.  in2 should then be a vector of weights for
%   combining the scenes.
%
% Inputs
%
%  in1 - Typically just a scene, but can be a cell array of scenes 
%  in2 - Typically a scene, but if scene1 is a cell array, this is a
%        vector of weights
%  addFlag - Defines the operation
%    add:     Add the radiance data from the two scenes(default)
%    remove spatial mean:  Remove mean from scene2 and then add to scene1
%
% Output
%  sceneOut - The combined scenes
%
% See also:
%  s_scielabPatches

% Examples:
%{
  scenes{1} = sceneCreate('rings rays',[],[256 256]);
  scenes{2} = sceneCreate('sweep frequency',256);
  tmp = sceneCreate; scenes{3} = sceneSet(tmp,'resize',[256 256]);
  sceneOut = sceneAdd(scenes,[0.5 0.5 0.3],'add');
  sceneWindow(sceneOut);
%}

%% We should do more parameter checking rather than just let the thing break.
if ieNotDefined('in1'), error('in1 required'); end
if ieNotDefined('in2'), error('in2 required'); end
if ieNotDefined('addFlag'), addFlag = 'add'; end

addFlag = ieParamFormat(addFlag);

if ~iscell(in1)
    % Two scenes.  Add them.

    %% Get the photons and do the right thing
    p = sceneGet(in1,'photons');
    s = sceneGet(in2,'photons');
    nWave = sceneGet(in2,'nwave');

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
    sceneOut = sceneSet(in1,'photons',p+s);
else
    % Input format is cell array and weights.  So loop and add.

    nScenes = numel(in1);             % All the input scenes
    nWave = sceneGet(in1{1},'nwave'); % Wave must be the same for all
    wgts = in2;                       % Weights
    assert(length(wgts) == nScenes);

    p = wgts(1)*sceneGet(in1{1},'photons');

    switch addFlag
        case 'add'
            for ss=2:nScenes
                p = p + wgts(ss)*sceneGet(in1{ss},'photons');
            end
        case 'removespatialmean'
            for ss=2:nScenes
                s = sceneGet(in1{ss},'photons');
                for ww=1:nWave
                    s(:,:,ww) = s(:,:,ww) - mean(mean(s(:,:,ww)));
                end
                p = p + wgts(ss)*s;
            end            
        otherwise
            error('Unknown addFlag %s',addFlag)
    end
    sceneOut = sceneSet(in1{1},'photons',p);
end

end
