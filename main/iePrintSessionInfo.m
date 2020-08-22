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
if isequal(objType,'all') || isequal(objType,'scene') || isequal(objType,'scenes')
    fprintf('\n');
    nScenes = vcCountObjects('SCENE');
    if nScenes == 0
        fprintf('No Scenes.\n');
    else
        names = vcGetObjectNames('scene');
        fprintf('Scenes:\n------------\n')
        for ii=1:numel(names)
            fprintf('%2.0f %s\n',ii,names{ii});
        end
    end
end

% OI
if isequal(objType,'all') || isequal(objType,'oi') || isequal(objType,'ois')
    fprintf('\n');
    nScenes = vcCountObjects('OPTICALIMAGE');
    if nScenes == 0
        fprintf('No OIs.\n');
    else
        names = vcGetObjectNames('oi');
        fprintf('OIs:\n------------\n')
        for ii=1:numel(names)
            fprintf('%2.0f %s\n',ii,names{ii});
        end
    end
end

% Sensors
if isequal(objType,'all') || isequal(objType,'sensor') || isequal(objType,'sensors')
    fprintf('\n');
    nScenes = vcCountObjects('ISA');
    if nScenes == 0
        fprintf('No Sensors.\n');
    else
        names = vcGetObjectNames('oi');
        fprintf('Sensors:\n------------\n')
        for ii=1:numel(names)
            fprintf('%2.0f %s\n',ii,names{ii});
        end
    end
end

% IPs
if isequal(objType,'all') || isequal(objType,'ip') || isequal(objType,'ips')
    fprintf('\n');
    nScenes = vcCountObjects('IPS');
    if nScenes == 0
        fprintf('No IPS.\n');
    else
        names = vcGetObjectNames('oi');
        fprintf('IPs:\n------------\n')
        for ii=1:numel(names)
            fprintf('%2.0f %s\n',ii,names{ii});
        end
    end
end

fprintf('\n\n');

end



