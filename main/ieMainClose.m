function ieMainClose
% Close the all the ISET windows and the ieMainwindow
%
% This looks like a big problem to me.  We need a better way to deal with
% it.
%
%     ieMainClose
%
% The routine checks for various fields, closes all the main windows
% properly. 
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

if ~checkfields(vcSESSION,'GUI'); closereq; return; end

if checkfields(vcSESSION.GUI,'vcSceneWindow','hObject')
    sceneWindow;
    sceneClose;
end

if checkfields(vcSESSION.GUI,'vcOptImgWindow','hObject')
    oiWindow;
    oiClose;
end

if checkfields(vcSESSION.GUI,'vcSensImgWindow','hObject')
    sensorWindow;
    sensorClose;
end

if checkfields(vcSESSION.GUI,'vcImageWindow','hObject')
    ipWindow;
    vcimageClose;
end

if checkfields(vcSESSION.GUI,'vcDisplayWindow','hObject')
    displayWindow;
    displayClose;
end

if checkfields(vcSESSION.GUI,'metricsWindow','hObject')
    metricsWindow;
    metricsClose;
end

vcSESSION.GUI = [];
closereq;

% Check that the window apps have been deleted
assert(isempty(ieSessionGet('scene window')));
assert(isempty(ieSessionGet('oi window')));
assert(isempty(ieSessionGet('sensor window')));
assert(isempty(ieSessionGet('ip window')));

%{
% We should write an ieSessionPrint function that lists what we have in
% different critical places in vcSESSION
%
   ieSessionGet('scene window')
   ieSessionGet('oi window')
   ieSessionGet('sensor window')
   ieSessionGet('ip window')
%}


end
