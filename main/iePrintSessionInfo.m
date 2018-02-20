function txt = iePrintSessionInfo
%Summarize session information in a text string
%
%    iePrintSessionInfo
%
% The general data in the vcSESSION structure are printed to the return
% variable, txt
%
% Copyright ImagEval Consultants, LLC, 2005.

txt = sprintf('Session %s\n--------------\n',ieSessionGet('name'));

nScenes = vcCountObjects('SCENE');
if nScenes == 0, sceneInfo = sprintf('No Scenes.\n');
else sceneInfo = sprintf('%.0f Scenes\n',nScenes);
end

nScenes = vcCountObjects('OPTICALIMAGE');
if nScenes == 0
    oiInfo = sprintf('No optical images.\n');
else
    oiInfo = sprintf('%.0f optical images\n',nScenes);
end

nISA = vcCountObjects('ISA');
if nISA == 0
    sensorInfo = sprintf('No Sensors.\n');
else
    sensorInfo = sprintf('%.0f Sensors\n',nISA);
end

nVCI = vcCountObjects('vci');
if nVCI == 0
    vciInfo = sprintf('No Processed images.\n');
else
    vciInfo = sprintf('%.0f Processed images\n',nVCI);
end

% txt = [txt,sceneInfo,oiInfo,sensorInfo,VideoInfo];
txt = [txt,sceneInfo,oiInfo,sensorInfo,vciInfo];

return;


