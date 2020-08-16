function sceneClose(sceneW)
% sceneClose - close SCENE window.
%
%    sceneClose 
%
% Removes scene window handle from vcSESSIOn, as well.
%
% Copyright ImagEval Consultants, LLC, 2003.

% global vcSESSION;

% If we are closing a selected window in the database, remove it from the
% database.
W = ieSessionGet('scene window');
if isequal(W,sceneW)
    ieSessionSet('scene window',[]);
end

% Close the window.
closereq;

end

%{
% Old code
%
% We used to remove the slot.  But now we just put an empty holder into the
% slot (see above).
if checkfields(vcSESSION,'GUI','vcSceneWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'vcSceneWindow');
end
%}