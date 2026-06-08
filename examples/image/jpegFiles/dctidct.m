function qBlock = dctidct(block,coefScaleFactor)
%
%
global dctMatrix
dctCoef = dctMatrix*block*dctMatrix';
qCoef = round(dctCoef .* coefScaleFactor) ./ coefScaleFactor;
%
% since idctMatrix = 4*dctMatrix', we have
%
qBlock = 16*(dctMatrix'*qCoef*dctMatrix);
