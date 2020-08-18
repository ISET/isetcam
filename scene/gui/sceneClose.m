function sceneClose(sceneW)
% sceneClose - close SCENE window.
%
%    sceneClose 
%
% Removes scene window handle from vcSESSIOn, as well.
%
% Copyright ImagEval Consultants, LLC, 2003.

% If we are closing a selected window in the database, remove it from the
% database.
W = ieSessionGet('scene window');
if isequal(W,sceneW)
    ieSessionSet('scene window',[]);
end

% Close the window.
closereq;

end
