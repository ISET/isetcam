function sceneClose
% sceneClose - close SCENE window.
%
%    sceneClose 
%
% Removes scene window handle from vcSESSIon, as well.
%
% Copyright ImagEval Consultants, LLC, 2003.

global vcSESSION;

if checkfields(vcSESSION,'GUI','vcSceneWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'vcSceneWindow');
end

closereq;

return;