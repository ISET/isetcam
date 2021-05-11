function iePrintSessionInfo(objType)
%Summarize session information in a text string
%
% Synopsis
%  iePrintSessionInfo(objType)
%
% The general data in the vcSESSION structure are printed to the return
% variable, txt
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('objType'), objType = 'all'; end

%%
objType = ieParamFormat(objType);

%% In addition to the name, we could get some info about each object

% Scene
if isequal(objType, 'all') || isequal(objType, 'scene') || isequal(objType, 'scenes')
    fprintf('\n');
    nObj = vcCountObjects('SCENE');
    if nObj == 0
        fprintf('No Scenes.\n');
    else
        names = vcGetObjectNames('scene');
        fprintf('Scenes:  (* selected)\n------------\n')
        for ii = 1:numel(names)
            selected = '';
            if isequal(ieGetSelectedObject('scene'), ii)
                selected = '*';
            end
            fprintf('%2.0f %s %s\n', ii, names{ii}, selected);
        end
    end
end

% OI
if isequal(objType, 'all') || isequal(objType, 'oi') || isequal(objType, 'ois')
    fprintf('\n');
    nObj = vcCountObjects('OPTICALIMAGE');
    if nObj == 0
        fprintf('No OIs.\n');
    else
        names = vcGetObjectNames('oi');
        fprintf('OIs  (* selected):\n------------\n')
        for ii = 1:numel(names)
            selected = '';
            if isequal(ieGetSelectedObject('oi'), ii)
                selected = '*';
            end
            fprintf('%2.0f %s %s\n', ii, names{ii}, selected);
        end
    end
end

% Sensors
if isequal(objType, 'all') || isequal(objType, 'sensor') || isequal(objType, 'sensors')
    fprintf('\n');
    nObj = vcCountObjects('ISA');
    if nObj == 0
        fprintf('No Sensors.\n');
    else
        names = vcGetObjectNames('isa');
        fprintf('Sensors (* selected):\n------------\n')
        for ii = 1:numel(names)
            selected = '';
            if isequal(ieGetSelectedObject('isa'), ii)
                selected = '*';
            end
            fprintf('%2.0f %s %s\n', ii, names{ii}, selected);
        end
    end
end

% IPs
if isequal(objType, 'all') || isequal(objType, 'ip') || isequal(objType, 'ips')
    fprintf('\n');
    nObj = vcCountObjects('IP');
    if nObj == 0
        fprintf('No IP.\n');
    else
        names = vcGetObjectNames('ip');
        fprintf('IPs  (* selected):\n------------\n')
        for ii = 1:numel(names)
            selected = '';
            if isequal(ieGetSelectedObject('ip'), ii)
                selected = '*';
            end
            fprintf('%2.0f %s %s\n', ii, names{ii}, selected);
        end
    end
end

fprintf('\n\n');

end
